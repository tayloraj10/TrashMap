import 'package:flutter/material.dart';
import '../models/constants.dart';

class MapAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MapAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Padding(
        padding: EdgeInsets.all(10),
        child: Text(
          appName,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
    );
  }
}
