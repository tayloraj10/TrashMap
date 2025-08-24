import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trash_map/components/attendee_avatar.dart';
import 'package:trash_map/components/marker_text_edit.dart';
import 'package:trash_map/models/app_data.dart';
import 'package:trash_map/models/constants.dart';

class PathMarkerDialog extends StatefulWidget {
  final Map data;
  final String id;
  final String markerID;
  final BuildContext context;
  const PathMarkerDialog(
      {super.key,
      required this.data,
      required this.id,
      required this.markerID,
      required this.context});

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
      }).then((value) async => {
                Provider.of<AppData>(context, listen: false)
                    .removePathMarker(widget.markerID),
                await Provider.of<AppData>(context, listen: false)
                    .loadCleanupPaths(context: widget.context),
                if (mounted) {Navigator.pop(context, true)}
              });
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

  createUserInfo() {
    return {
      'email': auth.currentUser?.email,
      'displayName': auth.currentUser?.displayName,
      'photoURL': auth.currentUser?.photoURL,
    };
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
            //RSVP Buttons
            if (auth.currentUser?.uid != null &&
                (widget.data['attendees'] == null ||
                    !(widget.data['attendees']
                        ?.containsKey(auth.currentUser?.uid))))
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade50,
                    foregroundColor: Colors.green,
                    elevation: 0,
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.event_available, color: Colors.green),
                  label: const Text(
                    'RSVP',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    setState(() {
                      if (widget.data['attendees'] == null) {
                        widget.data['attendees'] = {
                          auth.currentUser?.uid: createUserInfo()
                        };
                      } else {
                        widget.data['attendees'][auth.currentUser?.uid] =
                            createUserInfo();
                      }
                    });

                    FirebaseFirestore.instance
                        .collection("cleanup_paths")
                        .doc(widget.id)
                        .update({
                      'attendees.${auth.currentUser?.uid}': createUserInfo()
                    });

                    Provider.of<AppData>(context, listen: false)
                        .removePathMarker(widget.markerID);
                    await Provider.of<AppData>(context, listen: false)
                        .loadCleanupPaths(context: widget.context);
                  },
                ),
              ),
            if (auth.currentUser?.uid != null &&
                (widget.data['attendees'] != null &&
                    widget.data['attendees']
                        .containsKey(auth.currentUser?.uid)))
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    elevation: 0,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  label: const Text(
                    'Remove RSVP',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    setState(() {
                      (widget.data['attendees'] as Map)
                          .remove(auth.currentUser?.uid);
                    });

                    FirebaseFirestore.instance
                        .collection("cleanup_paths")
                        .doc(widget.id)
                        .update({
                      'attendees.${auth.currentUser?.uid}': FieldValue.delete()
                    });

                    Provider.of<AppData>(context, listen: false)
                        .removePathMarker(widget.markerID);
                    await Provider.of<AppData>(context, listen: false)
                        .loadCleanupPaths(context: widget.context);
                  },
                ),
              ),

            // Attendees List
            if (auth.currentUser?.uid != null &&
                widget.data['attendees'] != null &&
                widget.data['attendees'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.group, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Attendees (${widget.data['attendees'].length})',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const Divider(thickness: 1, height: 16),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      width: 250, // Set a max width for the attendee list
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.data['attendees'].keys
                              .map<Widget>((userID) {
                            return AttendeeAvatar(
                                userData: widget.data['attendees'][userID]);
                          }).toList(),
                        ),
                      ),
                    )
                  ],
                ),
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
