import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:trash_map/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrashDialog extends StatefulWidget {
  final FirebaseAuth auth;
  final LatLng latlng;
  const TrashDialog({super.key, required this.latlng, required this.auth});

  @override
  State<TrashDialog> createState() => _CleanDialogState();
}

class _CleanDialogState extends State<TrashDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  late final DateTime _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

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
              readOnly: true,
              controller: _dateController,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(labelText: 'Date'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please select a date';
                }
                return null;
              },
            ),
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
            // Close the dialog when Cancel is pressed
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Validate form inputs
            if (_formKey.currentState!.validate()) {
              TrashReport trashData = TrashReport(
                lat: widget.latlng.latitude,
                lng: widget.latlng.longitude,
                location: _locationController.text,
                date: DateTime.now(),
                user: widget.auth.currentUser!.displayName!,
                uid: widget.auth.currentUser!.uid,
              );
              FirebaseFirestore.instance
                  .collection("trash")
                  .add(trashData.toMap());

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
