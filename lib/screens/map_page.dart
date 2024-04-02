import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trash_map/components/map_app_bar.dart';
import 'package:trash_map/components/trash_map.dart';

class MapPage extends StatelessWidget {
  final FirebaseAuth auth;
  const MapPage({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MapAppBar(
        auth: auth,
      ),
      // drawer: const MapDrawer(),

      body: SafeArea(
        child: TrashMap(
          auth: auth,
        ),
      ),
    );
  }
}
