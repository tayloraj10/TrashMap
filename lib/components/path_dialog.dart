import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trash_map/models/app_data.dart';
import 'package:trash_map/models/constants.dart';
import 'package:trash_map/models/models.dart';

class PathDialog extends StatefulWidget {
  const PathDialog({super.key});

  @override
  State<PathDialog> createState() => _PathDialogState();
}

class _PathDialogState extends State<PathDialog> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _bagsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateController.text = dateTimeToString(_selectedDate);
  }

  submit() {
    if (_formKey.currentState!.validate()) {
      CleanupRoute route = CleanupRoute(
        routeName: _controller.text,
        date: stringToDateTime(_dateController.text),
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
          .collection("cleanup_paths")
          .add(route.toMap())
          .then((value) => {Navigator.pop(context, true)});
    }
  }

  List<CleanupWaypoint> createWaypoints() {
    List<CleanupWaypoint> waypoints = [];
    Provider.of<AppData>(context, listen: false)
        .getPathPoints()
        .forEach((point) {
      CleanupWaypoint waypoint = CleanupWaypoint(
          lat: point.position.latitude,
          lng: point.position.longitude,
          number: int.parse(point.markerId.value.split('path_').last));
      waypoints.add(waypoint);
    });
    return waypoints;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    final TimeOfDay? pickedTime = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime?.hour ?? 0,
          pickedTime?.minute ?? 0,
        );
        _dateController.text = dateTimeToString(_selectedDate);
      });
    }
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
              decoration: const InputDecoration(hintText: 'Name'),
              controller: _controller,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a name';
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
            TextFormField(
                readOnly: true,
                controller: _dateController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(labelText: 'Date and Time'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please select the date of the cleanup';
                  }
                  return null;
                }),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Pick Date')),
            )
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
