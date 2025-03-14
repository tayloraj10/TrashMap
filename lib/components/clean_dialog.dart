import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trash_map/models/constants.dart';
import 'package:trash_map/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CleanDialog extends StatefulWidget {
  final LatLng latlng;
  const CleanDialog({super.key, required this.latlng});

  @override
  State<CleanDialog> createState() => _CleanDialogState();
}

class _CleanDialogState extends State<CleanDialog> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _bagsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateController.text = dateToString(_selectedDate);
  }

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
        _dateController.text = dateToString(_selectedDate);
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
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ]),
            TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Pounds of Trash'),
                // validator: (value) {
                //   if (value!.isEmpty || double.tryParse(value)! < 0) {
                //     return 'Please enter the # of bags cleaned up';
                //   }
                //   return null;
                // },
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ]),
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
                weight: _weightController.text == ''
                    ? 0
                    : double.tryParse(_weightController.text)!,
                date: stringToDate(_dateController.text),
              );
              if (auth.currentUser != null) {
                cleanupData.user = auth.currentUser!.displayName!;
                cleanupData.uid = auth.currentUser!.uid;
              }

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
