import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trash_map/components/marker_dialog.dart';
import 'package:trash_map/components/path_marker_dialog.dart';

class AppData extends ChangeNotifier {
  //icons
  late Map icons;

  get getIcons {
    return icons;
  }

  void updateIcons(Map icons) {
    this.icons = icons;
    notifyListeners();
  }

  //markers
  Set<Marker> markers = {};
  Set<Polyline> routes = {};

  get getMarkers {
    return markers;
  }

  get getRoutes {
    return routes;
  }

  Marker getMarker(String markerID) {
    return markers
        .firstWhere((element) => element.markerId == MarkerId(markerID));
  }

  Marker getPreviousMarker(int tickNumber) {
    return markers.where((marker) {
      return marker.markerId.value.contains('route_') &&
          int.parse(marker.markerId.value.split('_').last) < tickNumber;
    }).reduce((a, b) {
      int aTick = int.parse(a.markerId.value.split('_').last);
      int bTick = int.parse(b.markerId.value.split('_').last);
      return (tickNumber - aTick).abs() < (tickNumber - bTick).abs() ? a : b;
    });
  }

  void removeMarker(String markerID) {
    markers.removeWhere((element) => element.markerId == MarkerId(markerID));
    notifyListeners();
  }

  void removePathMarker(String markerID) {
    markers.removeWhere(
        (marker) => marker.markerId.value.contains('pathpoint$markerID'));
    routes.removeWhere(
        (route) => route.polylineId.value.contains('pathold_$markerID'));
    notifyListeners();
  }

  void removeRouteMarker(String markerID) {
    markers.removeWhere(
        (marker) => marker.markerId.value.contains('routepoint$markerID'));
    routes.removeWhere(
        (route) => route.polylineId.value.contains('routeold_$markerID'));
    notifyListeners();
  }

  void addMarker(Marker marker) {
    markers.add(marker);
    notifyListeners();
  }

  void addRoute(Polyline route) {
    routes.add(route);
    notifyListeners();
  }

  bool hasRoute() {
    return markers.any((marker) => marker.markerId.value.contains('route_'));
  }

  List<Marker> getRoutePoints() {
    return markers
        .where((marker) => marker.markerId.value.contains('route_'))
        .toList();
  }

  List<Marker> getPathPoints() {
    return markers
        .where((marker) => marker.markerId.value.contains('path_'))
        .toList();
  }

  void clearRoute() {
    markers.removeWhere((marker) => marker.markerId.value.contains('route_'));
    routes.removeWhere((route) => route.polylineId.value.contains('route_'));
    notifyListeners();
  }

  void clearPaths() {
    markers.removeWhere((marker) => marker.markerId.value.contains('path_'));
    routes.removeWhere((route) => route.polylineId.value.contains('path_'));
    notifyListeners();
  }

  void updateMarkerIcon(String markerID, BitmapDescriptor newIcon) {
    markers = markers.map((marker) {
      if (marker.markerId.value == markerID) {
        return marker.copyWith(iconParam: newIcon);
      }
      return marker;
    }).toSet();
    notifyListeners();
  }

  int getPathCount() {
    return markers
        .where((marker) => marker.markerId.value.contains('path_'))
        .length;
  }

  void removeLastPathPoint() {
    markers.removeWhere((marker) {
      return marker.markerId.value.contains('path_') &&
          int.parse(marker.markerId.value.split('_').last) == getPathCount();
    });
    routes.removeWhere((route) {
      return route.polylineId.value.contains('path_') &&
          int.parse(route.polylineId.value.split('_').last) ==
              getPathCount() + 1;
    });
    notifyListeners();
  }

  //position
  late LatLng currentLatLng = const LatLng(0.0, 0.0);

  get getLatLng {
    return currentLatLng;
  }

  void updateLatLng(Position position) {
    currentLatLng = LatLng(position.latitude, position.longitude);
    markers.add(Marker(
      markerId: const MarkerId('current_location'),
      icon: icons['current'],
      position: currentLatLng,
    ));
    notifyListeners();
  }

  //side panel
  bool showPanel = false;

  get getShowPanel {
    return showPanel;
  }

  void toggleShowPanel() {
    showPanel = !showPanel;
    notifyListeners();
  }

  //map controller
  late GoogleMapController mapController;

  get getMapController {
    return mapController;
  }

  void updateMapController(GoogleMapController newMapController) {
    mapController = newMapController;
    notifyListeners();
  }

  //counts
  int cleanupCount = 0;
  int trashCount = 0;
  int yourCleanupCount = 0;
  int yourTrashCount = 0;
  int yourPounds = 0;
  int yourBags = 0;
  int pounds = 0;
  int bags = 0;

  void resetCounts() {
    cleanupCount = 0;
    trashCount = 0;
    yourCleanupCount = 0;
    yourTrashCount = 0;
    pounds = 0;
    bags = 0;
    yourPounds = 0;
    yourBags = 0;
    notifyListeners();
  }

  void incrementCleanupCount() {
    cleanupCount++;
    notifyListeners();
  }

  void incrementTrashCount() {
    trashCount++;
    notifyListeners();
  }

  void incrementYourCleanupCount() {
    yourCleanupCount++;
    notifyListeners();
  }

  void incrementYourTrashCount() {
    yourTrashCount++;
    notifyListeners();
  }

  void incrementPounds(int pounds) {
    this.pounds += pounds;
    notifyListeners();
  }

  void incrementBags(int bags) {
    this.bags += bags;
    notifyListeners();
  }

  void incrementYourPounds(int pounds) {
    yourPounds += pounds;
    notifyListeners();
  }

  void incrementYourBags(int bags) {
    yourBags += bags;
    notifyListeners();
  }

  getCleanupCount() {
    return cleanupCount;
  }

  getTrashCount() {
    return trashCount;
  }

  getYourCleanupCount() {
    return yourCleanupCount;
  }

  getYourTrashCount() {
    return yourTrashCount;
  }

  getPounds() {
    return pounds;
  }

  getBags() {
    return bags;
  }

  getYourPounds() {
    return yourPounds;
  }

  getYourBags() {
    return yourBags;
  }

  Future<void> loadIcons({context, mounted}) async {
    BitmapDescriptor currentLocationMarkerIcon =
        await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(40, 40)),
      'images/current-location.png',
    );
    BitmapDescriptor cleanMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(40, 40)),
      'images/clean.png',
    );
    BitmapDescriptor trashMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(40, 40)),
      'images/trash.png',
    );
    BitmapDescriptor trashCleanedMarkerIcon =
        await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(40, 40)),
      'images/trash_cleaned.png',
    );
    BitmapDescriptor routeIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(40, 40)),
      'images/tracking.png',
    );
    BitmapDescriptor drawIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(40, 40)),
      'images/draw.png',
    );
    if (mounted) {
      Provider.of<AppData>(context, listen: false).updateIcons({
        'current': currentLocationMarkerIcon,
        'cleanup': cleanMarkerIcon,
        'trash': trashMarkerIcon,
        'trash_cleaned': trashCleanedMarkerIcon,
        'route': routeIcon,
        'draw': drawIcon,
      });
    }
  }

  int dataRange = 30 * 6;

//loading function
  loadCleanups({context, auth}) async {
    await FirebaseFirestore.instance
        .collection("cleanups")
        .where('active', isEqualTo: true)
        // .where('date',
        //     isGreaterThan:
        // DateTime.now().subtract(const Duration(days: dataRange)))
        .get()
        .then((value) => {
              for (var element in value.docs)
                {
                  Provider.of<AppData>(context, listen: false)
                      .incrementCleanupCount(),
                  if (element.data()['weight'] != null)
                    Provider.of<AppData>(context, listen: false)
                        .incrementPounds(element.data()['weight']),
                  if (element.data()['bags'] != null)
                    Provider.of<AppData>(context, listen: false)
                        .incrementBags(element.data()['bags']),
                  if (auth.currentUser != null &&
                      auth.currentUser!.uid == element.data()['uid'])
                    {
                      Provider.of<AppData>(context, listen: false)
                          .incrementYourCleanupCount(),
                      if (element.data()['weight'] != null)
                        Provider.of<AppData>(context, listen: false)
                            .incrementYourPounds(element.data()['weight']),
                      if (element.data()['bags'] != null)
                        Provider.of<AppData>(context, listen: false)
                            .incrementYourBags(element.data()['bags']),
                    },
                  Provider.of<AppData>(context, listen: false).addMarker(
                    Marker(
                      markerId: MarkerId('cleanup${element.id}'),
                      icon: Provider.of<AppData>(context, listen: false)
                          .getIcons['cleanup'],
                      position:
                          LatLng(element.data()['lat'], element.data()['lng']),
                      onTap: (() => showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // Return widget tree containing the AlertDialog
                              return MarkerDialog(
                                data: element.data(),
                                id: element.id,
                                type: 'Cleanup',
                              );
                            },
                          )),
                    ),
                  )
                }
            });
  }

  loadTrash({context, auth}) async {
    await FirebaseFirestore.instance
        .collection("trash")
        .where('date',
            isGreaterThan: DateTime.now().subtract(Duration(days: dataRange)))
        .get()
        .then((value) => {
              for (var element in value.docs)
                {
                  Provider.of<AppData>(context, listen: false)
                      .incrementTrashCount(),
                  if (auth.currentUser != null &&
                      auth.currentUser!.uid == element.data()['uid'])
                    Provider.of<AppData>(context, listen: false)
                        .incrementYourTrashCount(),
                  Provider.of<AppData>(context, listen: false).addMarker(
                    Marker(
                      markerId: MarkerId('trash${element.id}'),
                      icon: element['active'] == true
                          ? Provider.of<AppData>(context, listen: false)
                              .getIcons['trash']
                          : Provider.of<AppData>(context, listen: false)
                              .getIcons['trash_cleaned'],
                      position:
                          LatLng(element.data()['lat'], element.data()['lng']),
                      onTap: (() => showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return MarkerDialog(
                                data: element.data(),
                                id: element.id,
                                type: 'Trash Report',
                              );
                            },
                          ).then((value) =>
                              trashCleaned(markerID: value, context: context))),
                    ),
                  )
                }
            });
  }

  trashCleaned({required String markerID, context}) {
    // Provider.of<AppData>(context, listen: false).removeMarker(markerID);
    Provider.of<AppData>(context, listen: false).updateMarkerIcon(
        markerID,
        Provider.of<AppData>(context, listen: false)
            .getIcons['trash_cleaned']!);
  }

  generateSnippet(Map data, String type) {
    String content = '<div id="bodyContent">';
    if (data['date'] != null) {
      content +=
          "<p><b>Date:</b> ${data['date'].toDate().toLocal().toString().split(' ')[0]}</p>";
    }
    if (data['bags'] != null && data['bags'] > 0) {
      content += "<p><b>Bags:</b> ${data['bags']}</p>";
    }
    if (data['weight'] != null && data['weight'] > 0) {
      content += "<p><b>Weight:</b> ${data['weight']} lbs</p>";
    }
    content += "</div></div>";
    return content;
  }

  loadCleanupRoutes({context}) async {
    await FirebaseFirestore.instance
        .collection("cleanup_routes")
        .where('date',
            isGreaterThan: DateTime.now().subtract(Duration(days: dataRange)))
        .get()
        .then((value) {
      for (var element in value.docs) {
        Provider.of<AppData>(context, listen: false).addRoute(
          Polyline(
            polylineId: PolylineId('routeold_${element.id}'),
            color: Colors.blue,
            width: 5,
            points: element
                .data()['waypoints']
                .map<LatLng>((point) => LatLng(point['lat'], point['lng']))
                .toList(),
          ),
        );
        var waypoints = element.data()['waypoints'];
        if (waypoints.isNotEmpty) {
          Provider.of<AppData>(context, listen: false).addMarker(
            Marker(
              markerId: MarkerId(
                  'routepoint${element.id}${waypoints.first['lat']}${waypoints.first['lng']}'),
              icon: Provider.of<AppData>(context, listen: false)
                  .getIcons['route'],
              position: LatLng(waypoints.first['lat'], waypoints.first['lng']),
              infoWindow: InfoWindow(
                title: '${element.data()['routeName']}: Start Point',
                snippet: generateSnippet(element.data(), 'Start'),
              ),
            ),
          );
          Provider.of<AppData>(context, listen: false).addMarker(
            Marker(
              markerId: MarkerId(
                  'routepoint${element.id}${waypoints.last['lat']}${waypoints.last['lng']}'),
              icon: Provider.of<AppData>(context, listen: false)
                  .getIcons['route'],
              position: LatLng(waypoints.last['lat'], waypoints.last['lng']),
              infoWindow: InfoWindow(
                title: '${element.data()['routeName']}: End Point',
                snippet: generateSnippet(element.data(), 'End'),
              ),
            ),
          );
        }
      }
    });
  }

  loadCleanupPaths({context}) async {
    await FirebaseFirestore.instance
        .collection("cleanup_paths")
        .where('date',
            isGreaterThan: DateTime.now().subtract(Duration(days: dataRange)))
        .get()
        .then((value) {
      for (var element in value.docs) {
        Provider.of<AppData>(context, listen: false).addRoute(
          Polyline(
            polylineId: PolylineId('pathold_${element.id}'),
            color: Colors.blue,
            width: 5,
            points: element
                .data()['waypoints']
                .map<LatLng>((point) => LatLng(point['lat'], point['lng']))
                .toList(),
          ),
        );
        var waypoints = element.data()['waypoints'];
        if (waypoints.isNotEmpty) {
          Provider.of<AppData>(context, listen: false).addMarker(
            Marker(
              markerId: MarkerId(
                  'pathpoint${element.id}${waypoints.first['lat']}${waypoints.first['lng']}'),
              icon:
                  Provider.of<AppData>(context, listen: false).getIcons['draw'],
              position: LatLng(waypoints.first['lat'], waypoints.first['lng']),
              onTap: (() => showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // Return widget tree containing the AlertDialog
                      return PathMarkerDialog(
                        data: element.data(),
                        id: element.id,
                      );
                    },
                  )),
            ),
          );
        }
      }
    });
  }
}
