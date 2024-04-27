class Cleanup {
  final String location;
  final String group;
  final double bags;
  final double weight;
  final DateTime date;
  final double lat;
  final double lng;
  final bool active;
  final String uid;
  final String user;

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
  final String uid;
  final String user;

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
