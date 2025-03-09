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

  void clearRoute() {
    markers.removeWhere((marker) => marker.markerId.value.contains('route_'));
    routes.clear();
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
}
