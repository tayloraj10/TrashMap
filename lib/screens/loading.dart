import 'package:flutter/material.dart';
import 'package:trash_map/screens/map_page.dart';

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Trash Map',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: const [
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
