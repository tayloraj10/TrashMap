class Cleanup {
  final String location;
  final String group;
  final double bags;
  final double weight;
  final DateTime date;
  final double lat;
  final double lng;
  final bool active;
  String uid;
  String user;

  Cleanup(
      {this.location = '',
      this.group = '',
      this.bags = 0,
      this.weight = 0,
      this.active = true,
      required this.date,
      required this.lat,
      required this.lng,
      this.uid = '',
      this.user = ''});

  Map<String, dynamic> toMap() {
    return {
      'location': location,
      'group': group,
      'bags': bags,
      'weight': weight,
      'date': date,
      'lat': lat,
      'lng': lng,
      'active': active,
      'uid': uid,
      'user': user,
    };
  }

  factory Cleanup.fromMap(Map<String, dynamic> map) {
    return Cleanup(
        location: map['location'],
        group: map['group'],
        bags: map['bags'],
        weight: map['weight'],
        date: map['date'],
        lat: map['lat'],
        lng: map['lng'],
        active: map['active'],
        uid: map['uid'],
        user: map['user']);
  }
}

class TrashReport {
  final String location;
  final DateTime date;
  final double lat;
  final double lng;
  final bool active;
  String uid;
  String user;

  TrashReport(
      {this.location = '',
      this.active = true,
      required this.date,
      required this.lat,
      required this.lng,
      this.uid = '',
      this.user = ''});

  Map<String, dynamic> toMap() {
    return {
      'location': location,
      'date': date,
      'lat': lat,
      'lng': lng,
      'active': active,
      'uid': uid,
      'user': user,
    };
  }

  factory TrashReport.fromMap(Map<String, dynamic> map) {
    return TrashReport(
        location: map['location'],
        date: map['date'],
        lat: map['lat'],
        lng: map['lng'],
        active: map['active'],
        uid: map['uid'],
        user: map['user']);
  }
}

class CleanupRoute {
  final String routeName;
  final List<CleanupWaypoint> waypoints;
  final DateTime date;
  final bool active;
  final double bags;
  final double weight;
  String uid;
  String user;

  CleanupRoute(
      {this.routeName = '',
      this.active = true,
      required this.date,
      this.waypoints = const [],
      this.bags = 0,
      this.weight = 0,
      this.uid = '',
      this.user = ''});

  Map<String, dynamic> toMap() {
    return {
      'routeName': routeName,
      'waypoints': waypoints.map((cleanup) => cleanup.toMap()).toList(),
      'date': date,
      'active': active,
      'bags': bags,
      'weight': weight,
      'uid': uid,
      'user': user,
    };
  }

  factory CleanupRoute.fromMap(Map<String, dynamic> map) {
    return CleanupRoute(
        routeName: map['routeName'],
        waypoints: (map['waypoints'] as List)
            .map((cleanup) => CleanupWaypoint.fromMap(cleanup))
            .toList(),
        date: map['date'],
        active: map['active'],
        bags: map['bags'],
        weight: map['weight'],
        uid: map['uid'],
        user: map['user']);
  }
}

class CleanupWaypoint {
  final double lat;
  final double lng;
  final int number;

  CleanupWaypoint({this.lat = 0, this.lng = 0, this.number = 0});
  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'lng': lng,
      'number': number,
    };
  }

  factory CleanupWaypoint.fromMap(Map<String, dynamic> map) {
    return CleanupWaypoint(
        lat: map['lat'], lng: map['lng'], number: map['number']);
  }
}
