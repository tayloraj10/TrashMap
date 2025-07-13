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
    if (widget.type == 'trash' || widget.type == 'cleanups') {
      _locationController.text = widget.data['location'];
      _dateController.text = timestampToString(widget.data['date']);
    }
    if (widget.type == 'cleanup_paths' || widget.type == 'cleanup_routes') {
      _dateController.text = datetimeTimestampToString(widget.data['date']);
      _locationController.text = widget.data['routeName'] ?? '';
    }
    if (widget.type == 'cleanups') {
      _groupController.text = widget.data['group'];
    }
    if (widget.type == 'cleanups' ||
        widget.type == 'cleanup_paths' ||
        widget.type == 'cleanup_routes') {
      _bagsController.text = widget.data['bags']?.toString() ?? '';
      _weightController.text = widget.data['weight']?.toString() ?? '';
    }
  }

  delete(String id) {
    FirebaseFirestore.instance.collection(widget.type).doc(id).delete();
    String markerName = widget.type == 'cleanups'
        ? 'cleanup'
        : widget.type == 'trash'
            ? 'trash'
            : '';
    if (widget.type == 'cleanup_paths') {
      Provider.of<AppData>(context, listen: false).removePathMarker(widget.id);
    } else if (widget.type == 'cleanup_routes') {
      Provider.of<AppData>(context, listen: false).removeRouteMarker(widget.id);
    } else {
      Provider.of<AppData>(context, listen: false)
          .removeMarker(markerName + widget.id);
    }
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
    } else if (widget.type == 'cleanup_paths') {
      FirebaseFirestore.instance.collection(widget.type).doc(id).update({
        'routeName': _locationController.text,
        'date': stringToDateTime(_dateController.text),
        'bags': double.tryParse(_bagsController.text),
        'weight': double.tryParse(_weightController.text),
      });
    } else if (widget.type == 'cleanup_routes') {
      FirebaseFirestore.instance.collection(widget.type).doc(id).update({
        'routeName': _locationController.text,
        'date': stringToDateTime(_dateController.text),
        'bags': double.tryParse(_bagsController.text),
        'weight': double.tryParse(_weightController.text),
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    // Small screen layout
                    return Column(
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
                                        Provider.of<AppData>(context,
                                                listen: false)
                                            .getMapController
                                            .animateCamera(
                                                CameraUpdate.newLatLngZoom(
                                                    LatLng(
                                                      widget.data['lat'] ??
                                                          widget.data[
                                                                  'waypoints']
                                                              [0]['lat'],
                                                      widget.data['lng'] ??
                                                          widget.data[
                                                                  'waypoints']
                                                              [0]['lng'],
                                                    ),
                                                    18))
                                      },
                                  icon: const Icon(Icons.location_searching))
                            ],
                          ),
                        ),
                        Table(
                          columnWidths: const <int, TableColumnWidth>{},
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            TableRow(children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                    onPressed: () => {delete(widget.id)},
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    )),
                              ),
                              if (widget.type == 'cleanups' ||
                                  widget.type == 'trash')
                                PropertyTile(
                                    title: 'Change Date',
                                    controller: _dateController,
                                    keyboardType: TextInputType.datetime),
                              if (widget.type == 'cleanup_paths' ||
                                  widget.type == 'cleanup_routes')
                                PropertyTile(
                                    title: 'Change Date And Time',
                                    controller: _dateController,
                                    keyboardType: TextInputType.datetime),
                              PropertyTile(
                                title: 'Location',
                                controller: _locationController,
                              ),
                            ]),
                            if (widget.type == 'cleanups' ||
                                widget.type == 'cleanup_paths' ||
                                widget.type == 'cleanup_routes')
                              TableRow(children: [
                                PropertyTile(
                                  title: 'Group',
                                  controller: _groupController,
                                  show: widget.type == 'cleanups',
                                ),
                                PropertyTile(
                                    title: '# of Bags',
                                    controller: _bagsController,
                                    keyboardType: TextInputType.number),
                                PropertyTile(
                                    title: 'Pounds of Trash Cleaned',
                                    controller: _weightController,
                                    keyboardType: TextInputType.number),
                              ]),
                          ],
                        ),
                      ],
                    );
                  } else {
                    // Large screen layout
                    return Table(
                      columnWidths: const <int, TableColumnWidth>{},
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(children: [
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
                                          Provider.of<AppData>(context,
                                                  listen: false)
                                              .getMapController
                                              .animateCamera(
                                                CameraUpdate.newLatLngZoom(
                                                    LatLng(
                                                      widget.data['lat'] ??
                                                          widget.data[
                                                                  'waypoints']
                                                              [0]['lat'],
                                                      widget.data['lng'] ??
                                                          widget.data[
                                                                  'waypoints']
                                                              [0]['lng'],
                                                    ),
                                                    18),
                                              )
                                        },
                                    icon: const Icon(Icons.location_searching))
                              ],
                            ),
                          ),
                          if (widget.type == 'cleanups' ||
                              widget.type == 'trash')
                            PropertyTile(
                                title: 'Change Date',
                                controller: _dateController,
                                keyboardType: TextInputType.datetime),
                          if (widget.type == 'cleanup_paths' ||
                              widget.type == 'cleanup_routes')
                            PropertyTile(
                                title: 'Change Date And Time',
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
                          if (widget.type == 'cleanups' ||
                              widget.type == 'cleanup_paths' ||
                              widget.type == 'cleanup_routes')
                            PropertyTile(
                                title: '# of Bags',
                                controller: _bagsController,
                                keyboardType: TextInputType.number),
                          if (widget.type == 'cleanups' ||
                              widget.type == 'cleanup_paths' ||
                              widget.type == 'cleanup_routes')
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
                        ])
                      ],
                    );
                  }
                },
              ),
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
