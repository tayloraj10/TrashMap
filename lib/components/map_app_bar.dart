import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash_map/models/app_data.dart';
import 'package:trash_map/screens/login.dart';
import 'package:trash_map/screens/profile.dart';
import '../models/constants.dart';

class MapAppBar extends StatelessWidget implements PreferredSizeWidget {
  MapAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  final FirebaseAuth auth = FirebaseAuth.instance;

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
      title: Row(
        children: [
          if (auth.currentUser != null)
            IconButton(
                onPressed: () => {
                      Provider.of<AppData>(context, listen: false)
                          .toggleShowPanel(),
                    },
                icon: const Icon(Icons.menu)),
          const SizedBox(
            width: 10,
          ),
          const Text(
            appName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ],
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
                                  builder: (context) => const Login()),
                            )
                          })
                  : Text(getProfileName(auth))),
        )
      ],
    );
  }
}
