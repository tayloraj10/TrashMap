import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash_map/components/map_app_bar.dart';
import 'package:trash_map/components/map_drawer.dart';
import 'package:trash_map/components/trash_map.dart';
import 'package:trash_map/models/app_data.dart';

class MapPage extends StatelessWidget {
  final FirebaseAuth auth;
  const MapPage({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MapAppBar(),
      body: SafeArea(
        child: Row(
          children: [
            if (Provider.of<AppData>(context, listen: true).getShowPanel)
              const MapDrawer(),
            Expanded(
              child: TrashMap(
                auth: auth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
