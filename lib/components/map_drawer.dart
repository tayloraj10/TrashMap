import 'package:flutter/material.dart';
import 'package:trash_map/models/constants.dart';

class MapDrawer extends StatelessWidget {
  const MapDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: primaryColor,
            ),
            child: Container(),
          ),
          GestureDetector(
            child: ListTile(
              title: const Text('Placeholder Item'),
              onTap: () => {Scaffold.of(context).openEndDrawer()},
            ),
          ),
        ],
      ),
    );
  }
}
