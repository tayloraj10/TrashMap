import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trash_map/components/marker_text.dart';

class MarkerDialog extends StatelessWidget {
  final Map data;
  final String type;
  const MarkerDialog({super.key, required this.data, required this.type});
  static const TextStyle leadingStyle = TextStyle(fontSize: 16);
  static const TextStyle mainStyle = TextStyle(fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(type),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['location'] != null && data['location'] != '')
            MarkerText(
              leadingText: "Location: ",
              mainText: data['location'],
              leadingStyle: leadingStyle,
              mainStyle: mainStyle,
            ),
          if (data['group'] != null && data['group'] != '')
            MarkerText(
              leadingText: "Group: ",
              mainText: data['group'],
              leadingStyle: leadingStyle,
              mainStyle: mainStyle,
            ),
          if (data['bags'] != null)
            MarkerText(
              leadingText: "Bags Cleaned: ",
              mainText: data['bags'].toString(),
              leadingStyle: leadingStyle,
              mainStyle: mainStyle,
            ),
          if (data['date'] != null)
            MarkerText(
              leadingText: "Date: ",
              mainText: DateFormat('yyyy-MM-dd').format(data['date'].toDate()),
              leadingStyle: leadingStyle,
              mainStyle: mainStyle,
            ),
        ],
      ),
    );
  }
}
