import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trash_map/components/map_app_bar.dart';
import 'package:trash_map/components/map_drawer.dart';
import 'package:trash_map/components/trash_map.dart';
import 'package:trash_map/models/app_data.dart';

class MapPage extends StatelessWidget {
  MapPage({super.key});
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MapAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(child: TrashMap()),
            if (Provider.of<AppData>(context, listen: true).getShowPanel)
              SlidingUpPanel(
                panel: const MapDrawer(),
                parallaxEnabled: false,
                minHeight: MediaQuery.of(context).size.height * .55,
                maxHeight: MediaQuery.of(context).size.height * .55,
              )
          ],
        ),
      ),
    );
  }
}
