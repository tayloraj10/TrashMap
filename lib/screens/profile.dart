import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:trash_map/firebase_options.dart';
import 'package:trash_map/screens/map_page.dart';

class Profile extends StatelessWidget {
  Profile({super.key});
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey,
        body: Column(children: [
          Expanded(
              child: ProfileScreen(
            auth: auth,
            actions: [
              SignedOutAction((context) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapPage(),
                  ),
                );
              }),
            ],
            providerConfigs: const [
              PhoneProviderConfiguration(),
              GoogleProviderConfiguration(
                  clientId: DefaultFirebaseOptions.googleClientID)
            ],
            children: [
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: (() => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapPage(),
                        ),
                      )),
                  child: const Text('Home'))
            ],
          ))
        ]),
      ),
    );
  }
}
