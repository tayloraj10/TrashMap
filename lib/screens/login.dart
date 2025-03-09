import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:trash_map/firebase_options.dart';
import 'package:trash_map/screens/loading.dart';

class Login extends StatefulWidget {
  const Login({
    super.key,
  });

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth auth = FirebaseAuth.instance;

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
                    builder: (context) => const LoadingPage(),
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
