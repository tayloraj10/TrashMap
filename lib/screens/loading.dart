import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trash_map/components/marker_dialog.dart';
import 'package:trash_map/models/app_data.dart';
import 'package:trash_map/models/constants.dart';
import 'package:trash_map/screens/map_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0,
      end: 100,
    ).animate(_controller);
    loadData();
  }

  Future<void> loadData() async {
    Provider.of<AppData>(context, listen: false).resetCounts();
    await loadIcons();
    await loadCleanups();
    await loadTrash();
    if (auth.currentUser != null) {
      await loadCleanupRoutes();
    }
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapPage(),
        ),
      );
    }
  }

  Future<void> loadIcons() async {
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
    if (mounted) {
      Provider.of<AppData>(context, listen: false).updateIcons({
        'current': currentLocationMarkerIcon,
        'cleanup': cleanMarkerIcon,
        'trash': trashMarkerIcon,
        'trash_cleaned': trashCleanedMarkerIcon
      });
    }
  }

  loadCleanups() async {
    await FirebaseFirestore.instance
        .collection("cleanups")
        .where('active', isEqualTo: true)
        // .where('date',
        //     isGreaterThan: DateTime.now().subtract(const Duration(days: 180)))
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

  loadTrash() async {
    await FirebaseFirestore.instance
        .collection("trash")
        .where('date',
            isGreaterThan: DateTime.now().subtract(const Duration(days: 180)))
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
                          ).then((value) => trashCleaned(value))),
                    ),
                  )
                }
            });
  }

  trashCleaned(String markerID) {
    // Provider.of<AppData>(context, listen: false).removeMarker(markerID);
    Provider.of<AppData>(context, listen: false).updateMarkerIcon(
        markerID,
        Provider.of<AppData>(context, listen: false)
            .getIcons['trash_cleaned']!);
  }

  loadCleanupRoutes() async {
    await FirebaseFirestore.instance
        .collection("cleanup_routes")
        .where('date',
            isGreaterThan: DateTime.now().subtract(const Duration(days: 180)))
        .get()
        .then((value) {
      for (var element in value.docs) {
        Provider.of<AppData>(context, listen: false).addRoute(
          Polyline(
            polylineId: PolylineId('path${element.id}'),
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
                  'waypoint${element.id}${waypoints.first['lat']}${waypoints.first['lng']}'),
              icon: Provider.of<AppData>(context, listen: false)
                  .getIcons['cleanup'],
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
                  'waypoint${element.id}${waypoints.last['lat']}${waypoints.last['lng']}'),
              icon: Provider.of<AppData>(context, listen: false)
                  .getIcons['cleanup'],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                appName,
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: primaryColor),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: 150,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            _animation.value,
                          ),
                          child: const Icon(
                            Icons.shopping_bag,
                            size: 50,
                            color: Colors.green,
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Icon(Icons.delete,
                        size: 150, color: Colors.black.withOpacity(1)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
