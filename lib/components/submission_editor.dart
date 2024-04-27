import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:trash_map/components/property_tile.dart';
import 'package:trash_map/models/app_data.dart';
import 'package:trash_map/models/constants.dart';

class SubmissionEditor extends StatefulWidget {
  final dynamic data;
  final String id;
  final String type;
  const SubmissionEditor(
      {super.key, required this.data, required this.type, required this.id});

  @override
  State<SubmissionEditor> createState() => _SubmissionEditorState();
}

class _SubmissionEditorState extends State<SubmissionEditor> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _bagsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setDefaultValues();
  }

  setDefaultValues() {
    _dateController.text = timestampToString(widget.data['date']);
    _locationController.text = widget.data['location'];
    if (widget.type == 'cleanups') {
      _groupController.text = widget.data['group'];
      _bagsController.text = widget.data['bags'].toString();
      _weightController.text = widget.data['weight'].toString();
    }
  }

  delete(String id) {
    FirebaseFirestore.instance.collection(widget.type).doc(id).delete();
    String markerName = widget.type == 'cleanups' ? 'cleanup' : 'trash';
    Provider.of<AppData>(context, listen: false)
        .removeMarker(markerName + widget.id);
  }

  updateData(String id) {
    if (widget.type == 'cleanups') {
      FirebaseFirestore.instance.collection(widget.type).doc(id).update({
        'date': stringToDate(_dateController.text),
        'location': _locationController.text,
        'group': _groupController.text,
        'bags': double.tryParse(_bagsController.text),
        'weight': double.tryParse(_weightController.text)
      });
    } else if (widget.type == 'trash') {
      FirebaseFirestore.instance.collection(widget.type).doc(id).update({
        'date': stringToDate(_dateController.text),
        'location': _locationController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Form(
          onChanged: () => {updateData(widget.id)},
          key: _formKey,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // Set border radius
              side: const BorderSide(
                color: Colors.grey, // Set border color
                width: 1, // Set border width
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  direction: Axis.horizontal,
                  // shrinkWrap: true,
                  // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  //     crossAxisCount: 3, childAspectRatio: 1.5),
                  children: [
                    GridTile(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Zoom To',
                            textAlign: TextAlign.center,
                          ),
                          IconButton(
                              onPressed: () => {
                                    Provider.of<AppData>(context, listen: false)
                                        .getMapController
                                        .animateCamera(
                                            CameraUpdate.newLatLngZoom(
                                                LatLng(widget.data['lat'],
                                                    widget.data['lng']),
                                                18))
                                  },
                              icon: const Icon(Icons.location_searching))
                        ],
                      ),
                    ),
                    PropertyTile(
                        title: 'Change Date',
                        controller: _dateController,
                        keyboardType: TextInputType.datetime),
                    PropertyTile(
                      title: 'Location',
                      controller: _locationController,
                    ),
                    if (widget.type == 'cleanups')
                      PropertyTile(
                        title: 'Group',
                        controller: _groupController,
                      ),
                    if (widget.type == 'cleanups')
                      PropertyTile(
                          title: '# of Bags',
                          controller: _bagsController,
                          keyboardType: TextInputType.number),
                    if (widget.type == 'cleanups')
                      PropertyTile(
                          title: 'Pounds of Trash Cleaned',
                          controller: _weightController,
                          keyboardType: TextInputType.number),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () => {delete(widget.id)},
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          )),
                    ),
                  ]),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}
