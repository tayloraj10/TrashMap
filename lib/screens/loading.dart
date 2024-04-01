import 'package:flutter/material.dart';
import 'package:trash_map/models/constants.dart';
import 'package:trash_map/screens/login.dart';
import 'package:trash_map/screens/map_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  late FirebaseAuth auth;

  @override
  void initState() {
    super.initState();
    checkLoggedIn();
  }

  checkLoggedIn() {
    auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Login(
              auth: FirebaseAuth.instance,
            ),
          ),
        );
      } else {
        getData(user);
      }
    });
  }

  Future<void> getData(User user) async {
    // await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapPage(
            auth: auth,
          ),
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
