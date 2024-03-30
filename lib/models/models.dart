class Cleanup {
  final String location;
  final String group;
  final double bags;
  final DateTime date;
  final double lat;
  final double lng;
  final bool active;

  Cleanup(
      {this.location = '',
      this.group = '',
      this.bags = 0,
      this.active = true,
      required this.date,
      required this.lat,
      required this.lng});

  Map<String, dynamic> toMap() {
    return {
      'location': location,
      'group': group,
      'bags': bags,
      'date': date,
      'lat': lat,
      'lng': lng,
      'active': active
    };
  }

  factory Cleanup.fromMap(Map<String, dynamic> map) {
    return Cleanup(
        location: map['location'],
        group: map['group'],
        bags: map['bags'],
        date: map['date'],
        lat: map['lat'],
        lng: map['lng'],
        active: map['active']);
  }
}

class TrashReport {
  final String location;
  final DateTime date;
  final double lat;
  final double lng;
  final bool active;

  TrashReport(
      {this.location = '',
      this.active = true,
      required this.date,
      required this.lat,
      required this.lng});

  Map<String, dynamic> toMap() {
    return {
      'location': location,
      'date': date,
      'lat': lat,
      'lng': lng,
      'active': active
    };
  }

  factory TrashReport.fromMap(Map<String, dynamic> map) {
    return TrashReport(
        location: map['location'],
        date: map['date'],
        lat: map['lat'],
        lng: map['lng'],
        active: map['active']);
  }
}
