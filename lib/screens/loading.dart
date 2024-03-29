import 'package:flutter/material.dart';
import 'package:trash_map/screens/map_page.dart';

import '../models/constants.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MapPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            appName,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.delete,
                size: 150,
              ),
              CircularProgressIndicator()
            ],
          ),
        ],
      ),
    );
  }
}
