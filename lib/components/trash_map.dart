import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trash_map/components/clean_dialog.dart';
import 'package:trash_map/components/map_button.dart';
import 'package:trash_map/components/map_text.dart';
import 'package:trash_map/components/marker_dialog.dart';
import 'package:trash_map/components/pin_confirmation.dart';
import 'package:trash_map/components/trash_dialog.dart';
import 'package:trash_map/models/app_data.dart';

class TrashMap extends StatefulWidget {
  final FirebaseAuth auth;
  const TrashMap({super.key, required this.auth});

  @override
  State<TrashMap> createState() => _TrashMapState();
}

class _TrashMapState extends State<TrashMap> {
  late GoogleMapController _controller;
  late LatLng droppedPostiion;
  late String droppedType;
  bool addClean = false;
  bool addTrash = false;
  bool pinDropped = false;

  // final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
  }

  loadPosition() async {
    panToPosition();
    // await _loadCustomMarker().then((value) => {loadCleanups(), loadTrash()});
    await getCurrentLocation().then((value) => {setCurrentLocationMarker()});
    getLocationStream();
  }

  setCurrentLocationMarker() {
    setState(() {
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
      _controller.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude), 15.6));
    }
  }

  void zoomToMarkers() {
    List<LatLng> positions = [];
    for (var element
        in Provider.of<AppData>(context, listen: false).getMarkers) {
      positions.add(element.position);
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
    _controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(southwestLat, southwestLon),
            northeast: LatLng(northeastLat, northeastLon)),
        50));
  }

  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    if (mounted) {
      Provider.of<AppData>(context, listen: false).updateLatLng(position);
      _controller.animateCamera(CameraUpdate.newLatLngZoom(
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
      log(position.toString());
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
      addTrash = false;
    });
  }

  newClean() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Return widget tree containing the AlertDialog
        return CleanDialog(
          auth: widget.auth,
          latlng: droppedPostiion,
        );
      },
    ).then((value) =>
        {if (value != null) successfulSubmit(value['id'], value['type'])});
  }

  clickTrash() {
    setState(() {
      addClean = false;
      addTrash = !addTrash;
    });
  }

  newTrash() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Return widget tree containing the AlertDialog
        return TrashDialog(
          auth: widget.auth,
          latlng: droppedPostiion,
        );
      },
    ).then((value) =>
        {if (value != null) successfulSubmit(value['id'], value['type'])});
  }

  clickMap(LatLng position) {
    if (addClean || addTrash) {
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
      pinDropped = false;
      Provider.of<AppData>(context, listen: false).removeMarker('new_clean');
      Provider.of<AppData>(context, listen: false).removeMarker('new_trash');
    });
  }

  successfulSubmit(String newID, String type) {
    setState(() {
      addClean = false;
      addTrash = false;
      pinDropped = false;
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
                              return MarkerDialog(
                                data: value.data()!,
                                id: value.id,
                                type: 'Cleanup',
                                auth: widget.auth,
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
                              return MarkerDialog(
                                data: value.data()!,
                                id: value.id,
                                type: 'Trash Report',
                                auth: widget.auth,
                              );
                            },
                          ).then((value) => hideCleanedTrash(value))),
                    ),
                  )
                });
      }
    });
  }

  hideCleanedTrash(String markerId) {
    Provider.of<AppData>(context, listen: false).removeMarker(markerId);
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
            onMapCreated: (controller) async {
              setState(() {
                _controller = controller;
              });
              await loadPosition();
            }),
        if (addClean || addTrash)
          MapText(
            text: addClean
                ? "Click map to add a cleanup location"
                : addTrash
                    ? "Click map to report trash"
                    : "",
          ),
        if (pinDropped)
          PinConfirmation(
            submit: newSubmit,
            cancel: cancel,
          ),
        if (widget.auth.currentUser != null)
          Positioned(
            top: 16,
            left: 16,
            child: Column(
              children: [
                MapButton(
                  image: 'images/clean.png',
                  callback: clickClean,
                  tooltip: 'Add Cleanup',
                  stroke: addClean,
                ),
                MapButton(
                  image: 'images/trash.png',
                  callback: clickTrash,
                  tooltip: 'Report Trash',
                  stroke: addTrash,
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
