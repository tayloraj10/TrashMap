import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trash_map/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CleanDialog extends StatefulWidget {
  final LatLng latlng;
  const CleanDialog({super.key, required this.latlng});

  @override
  State<CleanDialog> createState() => _CleanDialogState();
}

class _CleanDialogState extends State<CleanDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _bagsController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Details'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location/Address'),
            ),
            TextFormField(
              controller: _groupController,
              decoration: const InputDecoration(labelText: 'Group Name'),
            ),
            TextFormField(
              controller: _bagsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '# of Bags'),
              validator: (value) {
                if (value!.isEmpty || double.tryParse(value)! < 0) {
                  return 'Please enter the name of bags cleaned up';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _dateController,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(labelText: 'Date'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter the date of the cleanup';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            // Close the dialog when Cancel is pressed
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Validate form inputs
            if (_formKey.currentState!.validate()) {
              Cleanup cleanupData = Cleanup(
                  lat: widget.latlng.latitude,
                  lng: widget.latlng.longitude,
                  location: _locationController.text,
                  group: _groupController.text,
                  bags: double.tryParse(_bagsController.text)!,
                  date: DateTime.now());
              FirebaseFirestore.instance
                  .collection("cleanups")
                  .add(cleanupData.toMap());

              // Close the dialog
              Navigator.of(context).pop();
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
