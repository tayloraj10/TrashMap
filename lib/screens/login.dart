import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:trash_map/firebase_options.dart';
import 'package:trash_map/screens/map_page.dart';

class Login extends StatelessWidget {
  final FirebaseAuth auth;
  const Login({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    // bool newUser = false;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey,
        body: Column(children: [
          Expanded(
              child: SignInScreen(
            auth: auth,
            providerConfigs: const [
              EmailProviderConfiguration(),
              PhoneProviderConfiguration(),
              GoogleProviderConfiguration(
                  clientId: DefaultFirebaseOptions.googleClientID)
            ],
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapPage(
                      auth: auth,
                    ),
                  ),
                );
              }),
            ],
          ))
        ]),
      ),
    );
  }
}
