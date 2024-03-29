import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trash_map/components/clean_dialog.dart';
import 'package:trash_map/components/map_button.dart';

class TrashMap extends StatefulWidget {
  const TrashMap({super.key});

  @override
  State<TrashMap> createState() => _TrashMapState();
}

class _TrashMapState extends State<TrashMap> {
  late GoogleMapController _controller;
  LatLng _currentPosition = const LatLng(0.0, 0.0);
  late BitmapDescriptor currentLocationMarkerIcon;

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
  }

  static const CameraPosition _kStart = CameraPosition(
    target: LatLng(40.7798, -73.9676),
    zoom: 12,
  );

  void _getCurrentLocation() async {
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
      // ignore: unused_local_variable
      StreamSubscription<Position> positionStream =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((Position? position) {
        setState(() {
          _currentPosition = LatLng(position!.latitude, position.longitude);
        });
        _controller.animateCamera(CameraUpdate.newLatLngZoom(
            LatLng(position!.latitude, position.longitude), 15.6));
      });
    } catch (e) {
      log("Error: $e");
    }
  }

  void _loadCustomMarker() async {
    // Load your custom marker icon here
    currentLocationMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(40, 40)), // Adjust the size if needed
      'images/current-location.png', // Replace with your custom marker image path
    );
  }

  newClean() {
    log('clean');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Return widget tree containing the AlertDialog
        return const CleanDialog();
      },
    );
  }

  newTrash() {
    log('trash');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
            initialCameraPosition: _kStart,
            markers: _currentPosition.latitude != 0.0 &&
                    _currentPosition.longitude != 0.0
                ? {
                    Marker(
                      markerId: const MarkerId('current_location'),
                      icon: currentLocationMarkerIcon,
                      position: _currentPosition,
                    ),
                  }
                : {},
            onMapCreated: (controller) {
              setState(() {
                _controller = controller;
              });
              _getCurrentLocation();
            }),
        Positioned(
          top: 16,
          left: 16,
          child: Column(
            children: [
              MapButton(
                image: 'images/clean.png',
                callback: newClean,
                tooltip: 'Add Cleanup',
              ),
              MapButton(
                  image: 'images/trash.png',
                  callback: newTrash,
                  tooltip: 'Report Trash')
            ],
          ),
        ),
      ],
    );
  }
}
