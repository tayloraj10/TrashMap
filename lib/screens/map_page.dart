import 'package:flutter/material.dart';
import 'package:trash_map/components/map_app_bar.dart';
import 'package:trash_map/components/map_drawer.dart';

import '../components/trash_map.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MapAppBar(),
      drawer: MapDrawer(),
      body: SafeArea(
        child: TrashMap(),
      ),
    );
  }
}
