import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trash_map/components/marker_text_edit.dart';
import 'package:trash_map/models/constants.dart';

class PathMarkerDialog extends StatefulWidget {
  final Map data;
  final String id;
  const PathMarkerDialog({super.key, required this.data, required this.id});

  @override
  State<PathMarkerDialog> createState() => _PathMarkerDialogState();
}

class _PathMarkerDialogState extends State<PathMarkerDialog> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _bagsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    populateValues();
  }

  void populateValues() {
    if (widget.data['routeName'] != null) {
      _controller.text = widget.data['routeName'];
    }
    if (widget.data['bags'] != null) {
      _bagsController.text = widget.data['bags'].toString();
    }
    if (widget.data['weight'] != null) {
      _weightController.text = widget.data['weight'].toString();
    }
    if (widget.data['date'] != null) {
      _selectedDate = widget.data['date'].toDate();
      _dateController.text = dateTimeToString(_selectedDate);
    }
  }

  submit() {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance
          .collection("cleanup_paths")
          .doc(widget.id)
          .update({
        'routeName': _controller.text,
        'bags': _bagsController.text == ''
            ? 0
            : double.tryParse(_bagsController.text)!,
        'weight': _weightController.text == ''
            ? 0
            : double.tryParse(_weightController.text)!,
        'date': stringToDateTime(_dateController.text),
      }).then((value) => {Navigator.pop(context, true)});
    }
  }

  cancel() {
    Navigator.pop(context, false);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    final TimeOfDay? pickedTime = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
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
      title: const Text('Cleanup Route'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.data['routeName'] != null)
              MarkerTextEdit(
                  readOnly: widget.data['uid'] != auth.currentUser?.uid,
                  tooltip: "Name",
                  validation: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  icon: Icons.pin_drop,
                  controller: _controller),
            if (widget.data['bags'] != null)
              MarkerTextEdit(
                readOnly: widget.data['uid'] != auth.currentUser?.uid,
                tooltip: "# of Bags Cleaned",
                validation: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a number';
                  }
                  return null;
                },
                icon: Icons.restore_from_trash,
                controller: _bagsController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            if (widget.data['weight'] != null)
              MarkerTextEdit(
                readOnly: widget.data['uid'] != auth.currentUser?.uid,
                tooltip: "Pounds of Trash Cleaned",
                validation: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a number';
                  }
                  return null;
                },
                icon: Icons.fitness_center,
                controller: _weightController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
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
            if (widget.data['uid'] == auth.currentUser?.uid)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Pick Date')),
              ),
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
          child: const Text('Save'),
        ),
      ],
    );
  }
}
