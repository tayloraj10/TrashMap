import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash_map/components/submission_editor.dart';
import 'package:trash_map/models/app_data.dart';

class MapDrawer extends StatefulWidget {
  const MapDrawer({super.key});

  @override
  State<MapDrawer> createState() => _MapDrawerState();
}

class _MapDrawerState extends State<MapDrawer> {
  // bool showCleanups = true;
  List<Map<String, String>> types = [
    {'key': 'cleanups', 'label': 'Cleanups'},
    {'key': 'trash', 'label': 'Trash Reports'},
    {'key': 'cleanup_routes', 'label': 'Tracked Routes'},
    {'key': 'cleanup_paths', 'label': 'Drawn Routes'},
  ];
  int currentTypeIndex = 0;

  final Stream<QuerySnapshot> _cleanupsStream = FirebaseFirestore.instance
      .collection('cleanups')
      .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where('active', isEqualTo: true)
      .orderBy('date', descending: true)
      .snapshots();
  final Stream<QuerySnapshot> _trashStream = FirebaseFirestore.instance
      .collection('trash')
      .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where('active', isEqualTo: true)
      .orderBy('date', descending: true)
      .snapshots();
  final Stream<QuerySnapshot> _pathsStream = FirebaseFirestore.instance
      .collection('cleanup_paths')
      .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where('active', isEqualTo: true)
      .orderBy('date', descending: true)
      .snapshots();
  final Stream<QuerySnapshot> _routesStream = FirebaseFirestore.instance
      .collection('cleanup_routes')
      .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where('active', isEqualTo: true)
      .orderBy('date', descending: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width < 500
          ? MediaQuery.of(context).size.width * .4
          : MediaQuery.of(context).size.width * .25,
      child: ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'Manage Your',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.swap_horiz),
                label: Text(types[currentTypeIndex]['label']!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                onPressed: () {
                  setState(() {
                    currentTypeIndex = currentTypeIndex + 1;
                    if (currentTypeIndex >= types.length) {
                      currentTypeIndex = 0;
                    }
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: IconButton(
                  icon: Icon(Icons.cancel, color: Colors.red[400]),
                  tooltip: 'Close',
                  onPressed: () {
                    Provider.of<AppData>(context, listen: false)
                        .toggleShowPanel();
                  },
                ),
              ),
            ],
          ),
          if (types[currentTypeIndex]['key'] == 'cleanups') ...[
            Container(
              color: Colors.blue,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Text(
                  'Your Cleanups',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            StreamBuilder(
              key: UniqueKey(),
              stream: _cleanupsStream,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  return Container(
                    color: Colors.blue,
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      primary: false,
                      key: UniqueKey(),
                      shrinkWrap: true,
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        data['id'] = document.id;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: SubmissionEditor(
                              data: data, id: document.id, type: 'cleanups'),
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            ),
          ],
          if (types[currentTypeIndex]['key'] == 'trash') ...[
            Container(
              color: Colors.red,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Text(
                  'Your Trash Reports',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            Container(
              color: Colors.red,
              child: StreamBuilder(
                key: UniqueKey(),
                stream: _trashStream,
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    return ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      primary: false,
                      key: UniqueKey(),
                      shrinkWrap: true,
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: SubmissionEditor(
                              data: data, id: document.id, type: 'trash'),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ],
          if (types[currentTypeIndex]['key'] == 'cleanup_paths') ...[
            Container(
              color: Colors.green,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Text(
                  'Your Cleanup Routes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            Container(
              color: Colors.green,
              child: StreamBuilder(
                key: UniqueKey(),
                stream: _pathsStream,
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: SelectableText('Error: ${snapshot.error}'),
                    );
                  } else {
                    return ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      primary: false,
                      key: UniqueKey(),
                      shrinkWrap: true,
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: SubmissionEditor(
                              data: data,
                              id: document.id,
                              type: 'cleanup_paths'),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ],
          if (types[currentTypeIndex]['key'] == 'cleanup_routes') ...[
            Container(
              color: Colors.purple,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Text(
                  'Your Recorded Cleanup Routes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            Container(
              color: Colors.purple,
              child: StreamBuilder(
                key: UniqueKey(),
                stream: _routesStream,
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: SelectableText('Error: ${snapshot.error}'),
                    );
                  } else {
                    return ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      primary: false,
                      key: UniqueKey(),
                      shrinkWrap: true,
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: SubmissionEditor(
                              data: data,
                              id: document.id,
                              type: 'cleanup_routes'),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ]
        ],
      ),
    );
  }
}
