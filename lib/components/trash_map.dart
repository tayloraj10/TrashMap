import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:trash_map/components/clean_dialog.dart';
import 'package:trash_map/components/map_button.dart';
import 'package:trash_map/components/map_text.dart';
import 'package:trash_map/components/marker_dialog.dart';
import 'package:trash_map/components/path_dialog.dart';
import 'package:trash_map/components/pin_confirmation.dart';
import 'package:trash_map/components/route_dialog.dart';
import 'package:trash_map/components/trash_dialog.dart';
import 'package:trash_map/models/app_data.dart';

class TrashMap extends StatefulWidget {
  const TrashMap({super.key});

  @override
  State<TrashMap> createState() => _TrashMapState();
}

class _TrashMapState extends State<TrashMap> {
  late LatLng droppedPostiion;
  late String droppedType;
  bool addClean = false;
  bool addTrash = false;
  bool addRoute = false;
  bool addDraw = false;
  bool pinDropped = false;
  bool confirmingRoute = false;
  bool showHelp = false;

  Timer? _inactivityTimer;

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    showHelp = false;
    setState(() {});
    _inactivityTimer = Timer(const Duration(seconds: 10), () {
      if (!addClean &&
          !addTrash &&
          !addRoute &&
          !addDraw &&
          !pinDropped &&
          !confirmingRoute) {
        setState(() {
          showHelp = true;
        });
      }
      setState(() {
        showHelp = true;
      });
    });
  }

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _resetInactivityTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  loadPosition() async {
    panToPosition();
    // await _loadCustomMarker().then((value) => {loadCleanups(), loadTrash()});
    await getCurrentLocation().then((value) => {setCurrentLocationMarker()});
    getLocationStream();
  }

  setCurrentLocationMarker() {
    setState(() {
      Provider.of<AppData>(context, listen: false)
          .removeMarker('current_location');
      Provider.of<AppData>(context, listen: false).addMarker(Marker(
        markerId: const MarkerId('current_location'),
        icon: Provider.of<AppData>(context, listen: false).getIcons['current'],
        position: Provider.of<AppData>(context, listen: false).getLatLng,
      ));
    });
    panToPosition();
  }

  static const CameraPosition _kStart = CameraPosition(
    target: LatLng(40.7798, -73.9676),
    zoom: 12,
  );

  panToPosition() {
    LatLng position = Provider.of<AppData>(context, listen: false).getLatLng;
    if (position.latitude != 0 && position.longitude != 0) {
      Provider.of<AppData>(context, listen: false)
          .getMapController
          .animateCamera(CameraUpdate.newLatLngZoom(
              LatLng(position.latitude, position.longitude), 15.6));
    }
  }

  void zoomToMarkers() {
    List<LatLng> positions = [];
    if (Provider.of<AppData>(context, listen: false).getMarkers.length > 1) {
      for (var element
          in Provider.of<AppData>(context, listen: false).getMarkers) {
        if (element.markerId != const MarkerId('current_location')) {
          positions.add(element.position);
        }
      }
      final southwestLat = positions.map((p) => p.latitude).reduce(
          (value, element) => value < element ? value : element); // smallest
      final southwestLon = positions
          .map((p) => p.longitude)
          .reduce((value, element) => value < element ? value : element);
      final northeastLat = positions.map((p) => p.latitude).reduce(
          (value, element) => value > element ? value : element); // biggest
      final northeastLon = positions
          .map((p) => p.longitude)
          .reduce((value, element) => value > element ? value : element);
      Provider.of<AppData>(context, listen: false)
          .getMapController
          .animateCamera(CameraUpdate.newLatLngBounds(
              LatLngBounds(
                  southwest: LatLng(southwestLat, southwestLon),
                  northeast: LatLng(northeastLat, northeastLon)),
              20));
    }
  }

  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    if (mounted) {
      Provider.of<AppData>(context, listen: false).updateLatLng(position);
      Provider.of<AppData>(context, listen: false)
          .getMapController
          .animateCamera(CameraUpdate.newLatLngZoom(
              Provider.of<AppData>(context, listen: false).getLatLng, 15.6));
    }
  }

  Future<void> getLocationStream() async {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 10,
    );
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      // log(position.toString());
      setState(() {
        Provider.of<AppData>(context, listen: false).updateLatLng(position!);
      });
      // _controller.animateCamera(CameraUpdate.newLatLngZoom(
      //     Provider.of<AppData>(context, listen: false).getPosition, 15.6));
    });
  }

  clickClean() {
    setState(() {
      addClean = !addClean;
      addRoute = false;
      addDraw = false;
      addTrash = false;
      showHelp = false;
    });
    // if (auth.currentUser != null) {
    //   setState(() {
    //     addClean = !addClean;
    //     addTrash = false;
    //   });
    // } else {
    //   Flushbar(
    //           // title: "Please login to add cleanups",
    //           messageText: const Center(
    //             child: Text(
    //               "Please login to add cleanups",
    //               style: TextStyle(fontSize: 20, color: Colors.white),
    //             ),
    //           ),
    //           duration: const Duration(seconds: 5),
    //           flushbarStyle: FlushbarStyle.FLOATING,
    //           flushbarPosition: FlushbarPosition.TOP,
    //           margin: const EdgeInsets.all(8),
    //           borderRadius: BorderRadius.circular(8),
    //           maxWidth: 300)
    //       .show(context);
    // }
  }

  newClean() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PointerInterceptor(
          child: CleanDialog(
            latlng: droppedPostiion,
          ),
        );
      },
    ).then((value) =>
        {if (value != null) successfulSubmit(value['id'], value['type'])});
  }

  clickTrash() {
    setState(() {
      addClean = false;
      addRoute = false;
      addDraw = false;
      addTrash = !addTrash;
      showHelp = false;
    });
    // if (auth.currentUser != null) {
    //   setState(() {
    //     addClean = false;
    //     addTrash = !addTrash;
    //   });
    // } else {
    //   Flushbar(
    //           // title: "Please login to add cleanups",
    //           messageText: const Center(
    //             child: Text(
    //               "Please login to report trash",
    //               style: TextStyle(fontSize: 20, color: Colors.white),
    //             ),
    //           ),
    //           duration: const Duration(seconds: 5),
    //           flushbarStyle: FlushbarStyle.FLOATING,
    //           flushbarPosition: FlushbarPosition.TOP,
    //           margin: const EdgeInsets.all(8),
    //           borderRadius: BorderRadius.circular(8),
    //           maxWidth: 300)
    //       .show(context);
    // }
  }

  clickRoute() {
    if (!confirmingRoute) {
      if (addRoute) {
        confirmingRoute = true;
      } else {
        confirmingRoute = false;
        cancel();
      }
      setState(() {
        addClean = false;
        addTrash = false;
        showHelp = false;
        addRoute = !addRoute;
      });
      if (addRoute) {
        recordRoute();
      }
    }
  }

  clickDraw() {
    if (addDraw) {
      cancel();
    } else {
      setState(() {
        addClean = false;
        addTrash = false;
        addRoute = false;
        showHelp = false;
        addDraw = !addDraw;
      });
    }
  }

  recordRoute() {
    int seconds = 60;
    Timer.periodic(Duration(seconds: seconds), (timer) async {
      if (addRoute) {
        LatLng currentLatLng =
            Provider.of<AppData>(context, listen: false).getLatLng;
        LatLng latLng = LatLng(currentLatLng.latitude, currentLatLng.longitude);
        // LatLng latLng = LatLng(
        //     currentLatLng.latitude +
        //         (Random().nextInt(401) + 100) /
        //             111320, // random number between 100 and 500 feet in latitude
        //     currentLatLng.longitude +
        //         (Random().nextInt(401) + 100) /
        //             111320); // random number between 100 and 500 feet in longitude
        setState(() {
          String markerID = 'route_${timer.tick}';
          Provider.of<AppData>(context, listen: false).addMarker(Marker(
              markerId: MarkerId(markerID),
              position: latLng,
              icon: BitmapDescriptor.defaultMarker,
              infoWindow: InfoWindow(
                title: '${timer.tick}',
              )));

          // Draw polyline connecting the markers
          List<LatLng> routePoints = [
            Provider.of<AppData>(context, listen: false)
                .getMarker('route_${timer.tick}')
                .position,
            timer.tick == 1
                ? Provider.of<AppData>(context, listen: false).getLatLng
                : Provider.of<AppData>(context, listen: false)
                    .getPreviousMarker(timer.tick)
                    .position,
          ];

          Provider.of<AppData>(context, listen: false).addRoute(Polyline(
            polylineId: PolylineId(markerID),
            points: routePoints,
            color: Colors.red,
            width: 5,
          ));
        });
      } else {
        timer.cancel();
      }
    });
  }

  newRoute() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PointerInterceptor(child: const RouteDialog());
      },
    ).then((value) => {if (value != null) successfulSubmit('', 'route')});
  }

  newPath() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents clicking outside the dialog
      builder: (BuildContext context) {
        return PointerInterceptor(child: const PathDialog());
      },
    ).then((value) => {if (value != null) successfulSubmit('', 'path')});
  }

  removeLastPathPoint() {
    setState(() {
      Provider.of<AppData>(context, listen: false).removeLastPathPoint();
    });
  }

  newTrash() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Return widget tree containing the AlertDialog
        return PointerInterceptor(
          child: TrashDialog(
            latlng: droppedPostiion,
          ),
        );
      },
    ).then((value) =>
        {if (value != null) successfulSubmit(value['id'], value['type'])});
  }

  clickMap(LatLng position) {
    if (addDraw) {
      int pathNumber =
          Provider.of<AppData>(context, listen: false).getPathCount() + 1;
      setState(() {
        Provider.of<AppData>(context, listen: false).addMarker(Marker(
            markerId: MarkerId('path_$pathNumber'),
            icon: pathNumber == 1
                ? Provider.of<AppData>(context, listen: false)
                    .getIcons['cleanup']
                : BitmapDescriptor.defaultMarker,
            position: position,
            draggable: false));

        if (pathNumber > 1) {
          Provider.of<AppData>(context, listen: false).addRoute(Polyline(
            polylineId: PolylineId('path_$pathNumber'),
            points: [
              Provider.of<AppData>(context, listen: false)
                  .getMarker('path_${pathNumber - 1}')
                  .position,
              position
            ],
            color: Colors.red,
            width: 5,
          ));
        }
      });
    } else if (addClean || addTrash) {
      if (addClean) {
        setState(() {
          Provider.of<AppData>(context, listen: false).addMarker(Marker(
              markerId: const MarkerId('new_clean'),
              icon: Provider.of<AppData>(context, listen: false)
                  .getIcons['cleanup'],
              position: position,
              draggable: false));
          addClean = false;
          pinDropped = true;
          droppedPostiion = position;
          droppedType = 'cleanup';
        });
      }
      if (addTrash) {
        setState(() {
          Provider.of<AppData>(context, listen: false).addMarker(Marker(
              markerId: const MarkerId('new_trash'),
              icon: Provider.of<AppData>(context, listen: false)
                  .getIcons['trash'],
              position: position,
              draggable: false));
          addTrash = false;
          pinDropped = true;
          droppedPostiion = position;
          droppedType = 'trash';
        });
      }
    }
  }

  newSubmit() {
    if (droppedType == 'cleanup') {
      newClean();
    } else if (droppedType == 'trash') {
      newTrash();
    }
  }

  cancel() {
    setState(() {
      addClean = false;
      addTrash = false;
      addDraw = false;
      addRoute = false;
      pinDropped = false;
      confirmingRoute = false;
      Provider.of<AppData>(context, listen: false).removeMarker('new_clean');
      Provider.of<AppData>(context, listen: false).removeMarker('new_trash');
      Provider.of<AppData>(context, listen: false).clearRoute();
      Provider.of<AppData>(context, listen: false).clearPaths();
    });
  }

  successfulSubmit(String newID, String type) {
    setState(() {
      addClean = false;
      addTrash = false;
      addRoute = false;
      addDraw = false;
      pinDropped = false;
      confirmingRoute = false;
      if (type == 'route') {
        Provider.of<AppData>(context, listen: false).clearRoute();
      }
      if (type == 'path') {
        Provider.of<AppData>(context, listen: false).clearPaths();
      }
      if (type == 'cleanup') {
        Provider.of<AppData>(context, listen: false).removeMarker('new_clean');

        FirebaseFirestore.instance
            .collection("cleanups")
            .doc(newID)
            .get()
            .then((value) => {
                  Provider.of<AppData>(context, listen: false).addMarker(
                    Marker(
                      markerId: MarkerId('cleanup${value.id}'),
                      icon: Provider.of<AppData>(context, listen: false)
                          .getIcons['cleanup'],
                      position:
                          LatLng(value.data()!['lat'], value.data()!['lng']),
                      onTap: (() => showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // Return widget tree containing the AlertDialog
                              return PointerInterceptor(
                                child: MarkerDialog(
                                  data: value.data()!,
                                  id: value.id,
                                  type: 'Cleanup',
                                ),
                              );
                            },
                          )),
                    ),
                  )
                });
      } else if (type == 'trash') {
        Provider.of<AppData>(context, listen: false).removeMarker('new_trash');
        FirebaseFirestore.instance
            .collection("trash")
            .doc(newID)
            .get()
            .then((value) => {
                  Provider.of<AppData>(context, listen: false).addMarker(
                    Marker(
                      markerId: MarkerId('trash${value.id}'),
                      icon: Provider.of<AppData>(context, listen: false)
                          .getIcons['trash'],
                      position:
                          LatLng(value.data()!['lat'], value.data()!['lng']),
                      onTap: (() => showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // Return widget tree containing the AlertDialog
                              return PointerInterceptor(
                                child: MarkerDialog(
                                  data: value.data()!,
                                  id: value.id,
                                  type: 'Trash Report',
                                ),
                              );
                            },
                          ).then((value) => trashCleaned(value))),
                    ),
                  )
                });
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
            onTap: ((position) {
              clickMap(position);
            }),
            initialCameraPosition: _kStart,
            // markers: _markers,
            markers: Provider.of<AppData>(context, listen: true).getMarkers,
            polylines: Provider.of<AppData>(context, listen: true).getRoutes,
            onMapCreated: (controller) async {
              setState(() {
                Provider.of<AppData>(context, listen: false)
                    .updateMapController(controller);
              });
              await loadPosition();
            }),
        if (showHelp)
          const MapText(text: "Click a button on the left to get started"),
        if (addClean || addTrash)
          MapText(
            text: addClean
                ? "Click map to add a cleanup location"
                : addTrash
                    ? "Click map to report trash"
                    : "",
          ),
        if (addRoute)
          const MapText(
            text: "Recording Route Every Minute, \nClick Button Again To Stop",
          ),
        if (addDraw)
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const MapText(
                    text: "Click map to draw a route",
                  ),
                  Tooltip(
                    message: 'Remove Last Point',
                    child: PointerInterceptor(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          child: IconButton(
                            onPressed: () => {removeLastPathPoint()},
                            icon: const Icon(
                              Icons.remove,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              PinConfirmation(
                submit: newPath,
                cancel: cancel,
              ),
            ],
          ),

        if (pinDropped)
          PinConfirmation(
            submit: newSubmit,
            cancel: cancel,
          ),
        if (confirmingRoute)
          PinConfirmation(
            submit: newRoute,
            cancel: cancel,
          ),
        // if (auth.currentUser != null)
        Positioned(
          top: 16,
          left: 16,
          child: Column(
            children: [
              MapButton(
                image: 'images/clean.png',
                callback: clickClean,
                tooltip: 'Add A Cleanup',
                stroke: addClean,
              ),
              MapButton(
                image: 'images/trash.png',
                callback: clickTrash,
                tooltip: 'Report Trash',
                stroke: addTrash,
              ),
              if (auth.currentUser != null)
                MapButton(
                  image: 'images/tracking.png',
                  callback: clickRoute,
                  tooltip: 'Record Route (beta)',
                  stroke: addRoute,
                ),
              if (auth.currentUser != null)
                MapButton(
                  image: 'images/draw.png',
                  callback: clickDraw,
                  tooltip: 'Draw Route (beta)',
                  stroke: addDraw,
                )
            ],
          ),
        ),
        Positioned(
          bottom: 120,
          right: 10,
          child: Tooltip(
            message: 'Zoom to Location',
            child: Container(
              color: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.location_searching),
                onPressed: () => {panToPosition()},
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 175,
          right: 10,
          child: Tooltip(
            message: 'Zoom to Data',
            child: Container(
              color: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.zoom_in_map),
                onPressed: () => {zoomToMarkers()},
              ),
            ),
          ),
        )
      ],
    );
  }
}
