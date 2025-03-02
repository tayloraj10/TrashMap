import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  get getMarkers {
    return markers;
  }

  void removeMarker(String markerID) {
    markers.removeWhere((element) => element.markerId == MarkerId(markerID));
    notifyListeners();
  }

  void addMarker(Marker marker) {
    markers.add(marker);
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

  void resetCounts() {
    cleanupCount = 0;
    trashCount = 0;
    yourCleanupCount = 0;
    yourTrashCount = 0;
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

  //cleanup data

  //trash data

  //auth
}
