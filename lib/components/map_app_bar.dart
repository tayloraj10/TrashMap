import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trash_map/screens/login.dart';
import 'package:trash_map/screens/profile.dart';
import '../models/constants.dart';

class MapAppBar extends StatelessWidget implements PreferredSizeWidget {
  final FirebaseAuth auth;
  const MapAppBar({super.key, required this.auth});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  getProfileName(FirebaseAuth auth) {
    String name = '';
    if (auth.currentUser!.displayName != null) {
      name = auth.currentUser!.displayName!;
    } else if (auth.currentUser!.email != null) {
      name = auth.currentUser!.email!;
    } else if (auth.currentUser!.phoneNumber != null) {
      name = auth.currentUser!.phoneNumber!;
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Padding(
        padding: EdgeInsets.all(10),
        child: Text(
          appName,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton(
              onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Profile(auth: auth)),
                    )
                  },
              child: auth.currentUser == null
                  ? GestureDetector(
                      child: const Text('Log In'),
                      onTap: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Login(auth: auth)),
                            )
                          })
                  : Text(getProfileName(auth))),
        )
      ],
    );
  }
}
