import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trash_map/components/submission_editor.dart';

class MapDrawer extends StatefulWidget {
  const MapDrawer({super.key});

  @override
  State<MapDrawer> createState() => _MapDrawerState();
}

class _MapDrawerState extends State<MapDrawer> {
  bool showCleanups = true;

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
                  'Manage Your Submissions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.swap_horiz),
                label: Text(showCleanups ? 'Cleanups' : 'Trash Reports',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                onPressed: () {
                  setState(() {
                    showCleanups = !showCleanups;
                  });
                },
              )
            ],
          ),
          if (showCleanups) ...[
            Container(
              color: Colors.green,
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
                    color: Colors.green,
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
          if (!showCleanups) ...[
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
          ]
        ],
      ),
    );
  }
}
