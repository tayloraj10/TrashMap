import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trash_map/models/app_data.dart';
import 'package:trash_map/models/models.dart';

class RouteDialog extends StatefulWidget {
  const RouteDialog({super.key});

  @override
  State<RouteDialog> createState() => _RouteDialogState();
}

class _RouteDialogState extends State<RouteDialog> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _bagsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  submit() {
    if (_formKey.currentState!.validate()) {
      CleanupRoute route = CleanupRoute(
        routeName: _controller.text,
        date: DateTime.now(),
        uid: auth.currentUser!.uid,
        user: auth.currentUser!.displayName!,
        active: true,
        waypoints: createWaypoints(),
        bags: _bagsController.text == ''
            ? 0
            : double.tryParse(_bagsController.text)!,
        weight: _weightController.text == ''
            ? 0
            : double.tryParse(_weightController.text)!,
      );

      FirebaseFirestore.instance
          .collection("cleanup_routes")
          .add(route.toMap())
          .then((value) => {Navigator.pop(context, true)});
    }
  }

  List<CleanupWaypoint> createWaypoints() {
    List<CleanupWaypoint> waypoints = [];
    Provider.of<AppData>(context, listen: false)
        .getRoutePoints()
        .forEach((point) {
      CleanupWaypoint waypoint = CleanupWaypoint(
          lat: point.position.latitude,
          lng: point.position.longitude,
          number: int.parse(point.markerId.value.split('route_').last));
      waypoints.add(waypoint);
    });
    return waypoints;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Route Details'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(hintText: 'Route Name'),
              controller: _controller,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a route name';
                }
                return null;
              },
            ),
            TextFormField(
                controller: _bagsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '# of Bags'),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ]),
            TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Pounds of Trash'),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ]),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            submit();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
