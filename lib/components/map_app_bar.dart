import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash_map/components/stat.dart';
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
      leading: (auth.currentUser != null)
          ? Padding(
              padding: const EdgeInsets.only(left: 10),
              child: IconButton(
                onPressed: () => {
                  Provider.of<AppData>(context, listen: false)
                      .toggleShowPanel(),
                },
                icon: const Icon(Icons.menu),
                tooltip: 'Manage Submissions',
              ),
            )
          : null,
      title: Row(
        children: [
          if (MediaQuery.of(context).size.width > 600 ||
              auth.currentUser == null)
            const Text(
              appName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          const Spacer(),
          Stat(
              message: 'Cleanups',
              icon: Icons.cleaning_services_outlined,
              data: Provider.of<AppData>(context, listen: false)
                  .getCleanupCount()
                  .toString()),
          const SizedBox(width: 4),
          Stat(
              message: 'Trash Reports',
              icon: Icons.delete_outline,
              data: Provider.of<AppData>(context, listen: false)
                  .getTrashCount()
                  .toString()),
          if (auth.currentUser != null) const SizedBox(width: 4),
          if (auth.currentUser != null)
            Stat(
              message: 'Your Cleanups',
              icon: Icons.cleaning_services_rounded,
              data: Provider.of<AppData>(context, listen: false)
                  .getYourCleanupCount()
                  .toString(),
              color: Colors.lightGreenAccent,
            ),
          if (auth.currentUser != null) const SizedBox(width: 4),
          if (auth.currentUser != null)
            Stat(
                message: 'Your Trash Reports',
                icon: Icons.delete,
                data: Provider.of<AppData>(context, listen: false)
                    .getYourTrashCount()
                    .toString(),
                color: Colors.lightGreenAccent),
          const Spacer(),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton(
              onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Profile()),
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
