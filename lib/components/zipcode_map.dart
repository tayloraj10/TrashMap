import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:trash_map/components/zip_code_info.dart';
import 'package:trash_map/components/zip_code_submission.dart';
import 'package:trash_map/models/app_data.dart';
import 'package:trash_map/models/models.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

class PolygonData {
  final String id;
  final List<LatLng> points;
  late final LatLngBounds bounds;

  PolygonData({required this.id, required this.points}) {
    bounds = _computeBounds(points);
  }

  LatLngBounds _computeBounds(List<LatLng> pts) {
    double minLat = pts.first.latitude;
    double maxLat = pts.first.latitude;
    double minLng = pts.first.longitude;
    double maxLng = pts.first.longitude;

    for (var p in pts) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  bool intersects(LatLngBounds viewport) {
    return !(bounds.northeast.latitude < viewport.southwest.latitude ||
        bounds.southwest.latitude > viewport.northeast.latitude ||
        bounds.northeast.longitude < viewport.southwest.longitude ||
        bounds.southwest.longitude > viewport.northeast.longitude);
  }
}

class ZipCodeMap extends StatefulWidget {
  const ZipCodeMap({super.key});

  @override
  State<ZipCodeMap> createState() => _ZipCodeMapState();
}

class _ZipCodeMapState extends State<ZipCodeMap> {
  bool showHelp = false;
  List<PolygonData> allPolygons = [];
  Set<Marker> markers = {};
  Set<Polygon> polygons = {};
  String selectedPolygonId = '';
  String hoveredPolygonId = '';
  Map<String, ZipCodeSubmission> zipcodeSubmissions = {};

  late AppData appData;
  StreamSubscription<Position>? _positionSubscription;

  static const CameraPosition _kStart = CameraPosition(
    target: LatLng(40.7818, -77.6426), // Center of Pennsylvania
    zoom: 8,
    // target: LatLng(40.7798, -73.9676),
    // zoom: 12,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appData = Provider.of<AppData>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadZipCodeSubmissions();
      await loadAllPolygonsData();
      await loadPosition();
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadZipCodeSubmissions() async {
    final zipcodeSubmissionsData =
        await FirebaseFirestore.instance.collection("zipcode_cleanups").get();
    zipcodeSubmissions.clear();
    for (var doc in zipcodeSubmissionsData.docs) {
      final data = doc.data();
      final ZipCodeSubmission submission = ZipCodeSubmission.fromJson(data);
      zipcodeSubmissions[submission.zipCode] = submission;
    }
    if (mounted) {
      Provider.of<AppData>(context, listen: false)
          .setCompletedZipCodes(zipcodeSubmissions.length);
    }
  }

  Future<void> loadAllPolygonsData() async {
    try {
      final data = await DefaultAssetBundle.of(context)
          .loadString('data/zipcode_data_simple.json');
      final List<dynamic> jsonList = json.decode(data);

      allPolygons = [];
      for (final item in jsonList) {
        final id = item['polygonId'] as String;
        final multipolygons = item['multipolygons'] ?? [item['points']];
        for (final polyPoints in multipolygons) {
          final points = (polyPoints as List)
              .where((p) => p is List && p.length == 2)
              .map<LatLng>((p) => LatLng(p[0] as double, p[1] as double))
              .toList();
          if (points.isNotEmpty) {
            allPolygons.add(PolygonData(id: id, points: points));
          }
        }
      }
      if (mounted) {
        final uniqueZipCodes = allPolygons.map((p) => p.id).toSet().length;
        Provider.of<AppData>(context, listen: false)
            .setTotalZipCodes(uniqueZipCodes);
      }

      filterPolygonsInViewport();
    } catch (e) {
      debugPrint('Error loading polygons: $e');
    }
  }

  Future<void> loadPosition() async {
    panToPosition();
    await getCurrentLocation();
    setCurrentLocationMarker();
    getLocationStream();
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      if (!mounted) return;

      appData.updateLatLng(position);
      appData.getMapController.animateCamera(
        CameraUpdate.newLatLngZoom(appData.getLatLng, 15.6),
      );
      filterPolygonsInViewport();
    } catch (e) {
      debugPrint('Error getting current location: $e');
    }
  }

  void getLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 10,
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((position) {
      if (!mounted) return;
      appData.updateLatLng(position);
    });
  }

  void setCurrentLocationMarker() {
    if (!mounted) return;

    appData.removeMarker('current_location');
    appData.addMarker(Marker(
      markerId: const MarkerId('current_location'),
      icon: appData.getIcons['current'],
      position: appData.getLatLng,
    ));
    panToPosition();
  }

  void panToPosition() {
    if (!mounted) return;

    final position = appData.getLatLng;
    if (position.latitude != 0 && position.longitude != 0) {
      appData.getMapController.animateCamera(
        CameraUpdate.newLatLngZoom(position, 15.6),
      );
    }
  }

  void zoomToMarkers() async {
    if (appData.getMapController == null) return;

    // Approximate bounds for Pennsylvania
    final bounds = LatLngBounds(
      southwest: const LatLng(39.7198, -80.5199), // Southwest corner of PA
      northeast: const LatLng(42.2696, -74.6895), // Northeast corner of PA
    );
    // final bounds = LatLngBounds(
    //   southwest: const LatLng(24.396308, -125.0), // Southernmost, Westernmost
    //   northeast:
    //       const LatLng(49.384358, -66.93457), // Northernmost, Easternmost
    // );

    await appData.getMapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 40),
    );
  }

  void clickMap(LatLng position) {}

  bool _pointInPolygon(LatLng point, List<LatLng> polygon) {
    bool inside = false;
    int n = polygon.length;

    if (n < 3) return false;

    for (int i = 0, j = n - 1; i < n; j = i++) {
      final LatLng pi = polygon[i];
      final LatLng pj = polygon[j];

      final double xi = pi.longitude;
      final double yi = pi.latitude;
      final double xj = pj.longitude;
      final double yj = pj.latitude;

      final double px = point.longitude;
      final double py = point.latitude;

      // Check if point is exactly on a polygon edge
      if (_pointOnSegment(px, py, xi, yi, xj, yj)) {
        return true;
      }

      // Ray-casting intersection test
      final bool intersect = ((yi > py) != (yj > py)) &&
          (px <
              (xj - xi) * (py - yi) / ((yj - yi) == 0 ? 1e-10 : (yj - yi)) +
                  xi);

      if (intersect) inside = !inside;
    }

    return inside;
  }

  bool _pointOnSegment(
    double px,
    double py,
    double x1,
    double y1,
    double x2,
    double y2,
  ) {
    const double epsilon = 1e-9;

    // Cross product must be near zero for collinearity
    final double cross = (py - y1) * (x2 - x1) - (px - x1) * (y2 - y1);
    if (cross.abs() > epsilon) return false;

    // Check if within bounding box
    final double dot = (px - x1) * (px - x2) + (py - y1) * (py - y2);
    return dot <= epsilon;
  }

  void _onHover(LatLng position) {
    String foundId = '';

    for (final poly in allPolygons) {
      if (_pointInPolygon(position, poly.points)) {
        foundId = poly.id;
        break;
      }
    }

    if (foundId != hoveredPolygonId) {
      setState(() {
        hoveredPolygonId = foundId;
      });

      // Optional: re-filter to repaint colors
      filterPolygonsInViewport();
    }
  }

  /// Filter polygons and keep tap highlight logic
  void filterPolygonsInViewport() async {
    if (!mounted || appData.getMapController == null) return;
    final bounds = await appData.getMapController.getVisibleRegion();

    final visiblePolygons = <Polygon>{};
    final polygonIdToPolygons = <String, List<Polygon>>{};

    for (final p in allPolygons) {
      if (!p.intersects(bounds)) continue;
      final bool completed = zipcodeSubmissions.containsKey(p.id);
      final String? imageUrl =
          completed ? (zipcodeSubmissions[p.id]?.imageUrl) : null;
      final String? name = completed ? (zipcodeSubmissions[p.id]?.name) : null;
      final bool isSelected = selectedPolygonId == p.id;
      final bool isHovered = hoveredPolygonId == p.id;
      final poly = Polygon(
        polygonId: PolygonId('${p.id}_${p.points.hashCode}'),
        points: p.points,
        strokeWidth: completed ? 2 : 1,
        strokeColor: isSelected
            ? Colors.yellow
            : isHovered
                ? Colors.orange
                : completed
                    ? Colors.green
                    : const Color(0xFF2196F3),
        fillColor: isSelected
            ? Colors.yellow.withOpacity(0.4)
            : isHovered
                ? Colors.orange.withOpacity(0.25)
                : zipcodeSubmissions.containsKey(p.id)
                    ? Colors.green.withOpacity(0.25)
                    : const Color(0x332196F3),
        consumeTapEvents: true,
        onTap: () {
          if (!mounted) return;
          setState(() {
            selectedPolygonId = p.id;

            final highlightPolygons = allPolygons
                .where((pd) => pd.id == p.id && pd.intersects(bounds))
                .map((pd) => Polygon(
                      polygonId:
                          PolygonId('${pd.id}_${pd.points.hashCode}_highlight'),
                      points: pd.points,
                      strokeWidth: 2,
                      strokeColor: Colors.yellow,
                      fillColor: Colors.yellow.withOpacity(0.4),
                      consumeTapEvents: false,
                    ))
                .toSet();

            polygons = {
              ...visiblePolygons.where(
                  (poly) => !poly.polygonId.value.endsWith('_highlight')),
              ...highlightPolygons,
            };
          });

          showDialog(
            context: context,
            builder: (_) => PointerInterceptor(
              child: completed
                  ? ZipCodeInfoDialog(zipCodeData: zipcodeSubmissions[p.id]!)
                  : ZipCodeSubmissionDialog(zipCode: p.id),
            ),
          ).then((data) async {
            if (!mounted) return;
            setState(() {
              polygons = polygons
                  .where((poly) => !poly.polygonId.value.endsWith('_highlight'))
                  .toSet();
              selectedPolygonId = '';
            });
            if (data != null && data['type'] == 'submission') {
              await loadZipCodeSubmissions();
              await loadAllPolygonsData();
            }
          });
        },
      );

      // If completed, add an image marker at the polygon's centroid
      if (completed && p.points.isNotEmpty) {
        // Calculate centroid
        double lat = 0, lng = 0;
        for (final pt in p.points) {
          lat += pt.latitude;
          lng += pt.longitude;
        }
        lat /= p.points.length;
        lng /= p.points.length;

        BitmapDescriptor? bitmap;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          bitmap = await bitmapFromUrl(
            url: imageUrl,
            width: 40, // Smaller icon size
          );
          markers.add(Marker(
            markerId: MarkerId('completed_${p.id}_${p.points.hashCode}'),
            position: LatLng(lat, lng),
            icon: bitmap,
            anchor: const Offset(0.5, 0.5),
            infoWindow: InfoWindow(
              title: 'Claimed By $name',
              snippet: 'Zip Code: ${p.id}',
            ),
          ));
        }
      }

      visiblePolygons.add(poly);
      polygonIdToPolygons.putIfAbsent(p.id, () => []).add(poly);
    }

    if (!mounted) return;
    setState(() => polygons = visiblePolygons);
  }

  Future<BitmapDescriptor> bitmapFromUrl(
      {required String url, required int width}) async {
    final response = await http.get(Uri.parse(url));
    final codec =
        await ui.instantiateImageCodec(response.bodyBytes, targetWidth: width);
    final fi = await codec.getNextFrame();
    final byteData = await fi.image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    final currentMarker = appData.getMarker('current_location');
    markers.add(currentMarker);

    return Stack(
      children: [
        MouseRegion(
          onHover: (event) async {
            if (!mounted || appData.getMapController == null) return;

            // Convert screen position to map LatLng
            final RenderBox box = context.findRenderObject() as RenderBox;
            final Offset localPosition = box.globalToLocal(event.position);

            final ScreenCoordinate screenCoordinate = ScreenCoordinate(
              x: localPosition.dx.round(),
              y: localPosition.dy.round(),
            );

            final LatLng latLng =
                await appData.getMapController.getLatLng(screenCoordinate);

            _onHover(latLng);
          },
          child: GoogleMap(
            initialCameraPosition: _kStart,
            zoomControlsEnabled: false,
            markers: markers,
            polygons: polygons,
            onTap: clickMap,
            onCameraIdle: filterPolygonsInViewport,
            onMapCreated: (controller) async {
              if (!mounted) return;
              appData.updateMapController(controller);
              await loadPosition();
            },
          ),
        ),
        Positioned(
          bottom: 120,
          right: 10,
          child: PointerInterceptor(
            child: Tooltip(
              message: 'Zoom to Location',
              child: Container(
                color: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.location_searching),
                  onPressed: panToPosition,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 175,
          right: 10,
          child: PointerInterceptor(
            child: Tooltip(
              message: 'Zoom to Data',
              child: Container(
                color: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.zoom_in_map),
                  onPressed: zoomToMarkers,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
