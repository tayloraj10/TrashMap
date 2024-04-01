import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trash_map/components/marker_text.dart';

class MarkerDialog extends StatelessWidget {
  final Map data;
  final String type;
  const MarkerDialog({super.key, required this.data, required this.type});
  static const TextStyle style = TextStyle(fontSize: 16);

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
                tooltip: "Location",
                text: data['location'],
                style: style,
                icon: Icons.pin_drop),
          if (data['group'] != null && data['group'] != '')
            MarkerText(
                tooltip: "Group",
                text: data['group'],
                style: style,
                icon: Icons.group),
          if (data['bags'] != null)
            MarkerText(
                tooltip: "Bags Cleaned",
                text: data['bags'].toString(),
                style: style,
                icon: Icons.restore_from_trash),
          if (data['date'] != null)
            MarkerText(
                tooltip: "Date",
                text: DateFormat('yyyy-MM-dd').format(data['date'].toDate()),
                style: style,
                icon: Icons.date_range),
        ],
      ),
    );
  }
}
