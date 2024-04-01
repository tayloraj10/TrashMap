import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trash_map/components/clean_dialog.dart';
import 'package:trash_map/components/map_button.dart';
import 'package:trash_map/components/map_text.dart';
import 'package:trash_map/components/pin_confirmation.dart';
import 'package:trash_map/components/trash_dialog.dart';

import 'marker_dialog.dart';

class TrashMap extends StatefulWidget {
  final FirebaseAuth auth;
  const TrashMap({super.key, required this.auth});

  @override
  State<TrashMap> createState() => _TrashMapState();
}

class _TrashMapState extends State<TrashMap> {
  late GoogleMapController _controller;
  LatLng _currentPosition = const LatLng(0.0, 0.0);
  late LatLng droppedPostiion;
  late String droppedType;
  late BitmapDescriptor currentLocationMarkerIcon;
  late BitmapDescriptor cleanMarkerIcon;
  late BitmapDescriptor trashMarkerIcon;
  bool addClean = false;
  bool addTrash = false;
  bool pinDropped = false;

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  loadInitialData() async {
    await _loadCustomMarker().then((value) => {loadCleanups(), loadTrash()});
    await _getCurrentLocation().then((value) => {setCurrentLocationMarker()});
  }

  setCurrentLocationMarker() {
    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId('current_location'),
        icon: currentLocationMarkerIcon,
        position: _currentPosition,
      ));
    });
  }

  loadCleanups() async {
    await FirebaseFirestore.instance
        .collection("cleanups")
        .where('active', isEqualTo: true)
        .snapshots()
        .forEach((element) {
      for (var element in element.docs) {
        _markers.add(
          Marker(
            markerId: MarkerId('cleanup${element.id}'),
            icon: cleanMarkerIcon,
            position: LatLng(element.data()['lat'], element.data()['lng']),
            onTap: (() => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // Return widget tree containing the AlertDialog
                    return MarkerDialog(data: element.data(), type: 'Cleanup');
                  },
                )),
          ),
        );
      }
    });
  }

  loadTrash() async {
    await FirebaseFirestore.instance
        .collection("trash")
        .where('active', isEqualTo: true)
        .snapshots()
        .forEach((element) {
      for (var element in element.docs) {
        _markers.add(
          Marker(
            markerId: MarkerId('trash${element.id}'),
            icon: trashMarkerIcon,
            position: LatLng(element.data()['lat'], element.data()['lng']),
            onTap: (() => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // Return widget tree containing the AlertDialog
                    return MarkerDialog(
                        data: element.data(), type: 'Trash Report');
                  },
                )),
          ),
        );
      }
    });
  }

  static const CameraPosition _kStart = CameraPosition(
    target: LatLng(40.7798, -73.9676),
    zoom: 12,
  );

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _controller.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude), 15.6));
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
      Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position? position) {
        log(position.toString());
        setState(() {
          _currentPosition = LatLng(position!.latitude, position.longitude);
        });
        // _controller.animateCamera(CameraUpdate.newLatLngZoom(
        //     LatLng(position!.latitude, position.longitude), 15.6));
      });
    } catch (e) {
      log("Error: $e");
    }
  }

  Future<void> _loadCustomMarker() async {
    // Load your custom marker icon here
    currentLocationMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(40, 40)),
      'images/current-location.png',
    );
    cleanMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(40, 40)),
      'images/clean.png',
    );
    trashMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(40, 40)),
      'images/trash.png',
    );
  }

  clickClean() {
    if (widget.auth.currentUser != null) {
      setState(() {
        addClean = !addClean;
        addTrash = false;
      });
    }
  }

  newClean() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Return widget tree containing the AlertDialog
        return CleanDialog(
          latlng: droppedPostiion,
        );
      },
    ).then((value) => successfulSubmit());
  }

  clickTrash() {
    if (widget.auth.currentUser != null) {
      setState(() {
        addClean = false;
        addTrash = !addTrash;
      });
    }
  }

  newTrash() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Return widget tree containing the AlertDialog
        return TrashDialog(
          latlng: droppedPostiion,
        );
      },
    ).then((value) => successfulSubmit());
  }

  clickMap(LatLng position) {
    if (addClean || addTrash) {
      if (addClean) {
        setState(() {
          _markers.add(Marker(
              markerId: const MarkerId('new_clean'),
              icon: cleanMarkerIcon,
              position: position,
              draggable: true));
          addClean = false;
          pinDropped = true;
          droppedPostiion = position;
          droppedType = 'cleanup';
        });
      }
      if (addTrash) {
        setState(() {
          _markers.add(Marker(
              markerId: const MarkerId('new_trash'),
              icon: trashMarkerIcon,
              position: position,
              draggable: true));
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
      _markers.removeWhere(
          (element) => element.markerId == const MarkerId('new_clean'));
      _markers.removeWhere(
          (element) => element.markerId == const MarkerId('new_trash'));
    });
  }

  successfulSubmit() {
    setState(() {
      addClean = false;
      addTrash = false;
      pinDropped = false;
    });
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
            markers: _markers,
            onMapCreated: (controller) async {
              setState(() {
                _controller = controller;
              });
              await loadInitialData();
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
      ],
    );
  }
}
