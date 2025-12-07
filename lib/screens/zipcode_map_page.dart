import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trash_map/components/map_app_bar.dart';
import 'package:trash_map/components/zipcode_map.dart';
import 'package:trash_map/models/constants.dart';

class ZipCodeMapPage extends StatelessWidget {
  ZipCodeMapPage({super.key});
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MapAppBar(pageName: zipPageName,),
      body: const SafeArea(
        child: Column(
          children: [
            Expanded(child: ZipCodeMap()),
          ],
        ),
      ),
    );
  }
}
