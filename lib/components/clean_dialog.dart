import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trash_map/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CleanDialog extends StatefulWidget {
  final LatLng latlng;
  final FirebaseAuth auth;
  const CleanDialog({super.key, required this.latlng, required this.auth});

  @override
  State<CleanDialog> createState() => _CleanDialogState();
}

class _CleanDialogState extends State<CleanDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _bagsController = TextEditingController();
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
              controller: _groupController,
              decoration: const InputDecoration(labelText: 'Group Name'),
            ),
            TextFormField(
              controller: _bagsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '# of Bags'),
              // validator: (value) {
              //   if (value!.isEmpty || double.tryParse(value)! < 0) {
              //     return 'Please enter the # of bags cleaned up';
              //   }
              //   return null;
              // },
            ),
            TextFormField(
              readOnly: true,
              controller: _dateController,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(labelText: 'Date'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please select the date of the cleanup';
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
              Cleanup cleanupData = Cleanup(
                lat: widget.latlng.latitude,
                lng: widget.latlng.longitude,
                location: _locationController.text,
                group: _groupController.text,
                bags: _bagsController.text == ''
                    ? 0
                    : double.tryParse(_bagsController.text)!,
                date: DateTime.now(),
                user: widget.auth.currentUser!.displayName!,
                uid: widget.auth.currentUser!.uid,
              );
              FirebaseFirestore.instance
                  .collection("cleanups")
                  .add(cleanupData.toMap())
                  .then((value) => {
                        Navigator.pop(
                            context, {'id': value.id, 'type': 'cleanup'})
                      });
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
