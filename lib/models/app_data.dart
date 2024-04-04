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
  //cleanup data

  //trash data

  //auth
}
