import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash_map/components/stat.dart';
import 'package:trash_map/components/stats_dialog.dart';
import 'package:trash_map/models/app_data.dart';
import 'package:trash_map/models/constants.dart';
import 'package:trash_map/screens/login.dart';
import 'package:trash_map/screens/map_page.dart';
import 'package:trash_map/screens/profile.dart';
import 'package:trash_map/screens/zipcode_map_page.dart';

class MapAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String pageName;
  MapAppBar({Key? key, required this.pageName}) : super(key: key);

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
      backgroundColor: pageName != appName ? Colors.blue : null,
      automaticallyImplyLeading: false,
      leading: (auth.currentUser != null && pageName == appName)
          ? Padding(
              padding: const EdgeInsets.only(left: 10),
              child: IconButton(
                onPressed: () => {
                  Provider.of<AppData>(context, listen: false)
                      .toggleShowPanel(),
                },
                icon: const Icon(Icons.assignment_turned_in),
                tooltip: 'Manage Submissions',
              ),
            )
          : null,
      title: Row(
        children: [
          if (MediaQuery.of(context).size.width > 600 ||
              auth.currentUser == null)
            Text(
              pageName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 2,
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                shadowColor: Colors.green.withOpacity(0.3),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        pageName == appName ? ZipCodeMapPage() : MapPage(),
                  ),
                );
              },
              child: MediaQuery.of(context).size.width > 600
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          pageName == appName ? 'ZipCode Map' : 'Cleanup Map',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        // const SizedBox(width: 8),
                        // if (MediaQuery.of(context).size.width > 600)
                        const Icon(Icons.keyboard_double_arrow_right, size: 20),
                      ],
                    )
                  : const Tooltip(
                      message: "Change Map",
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.map, size: 20),
                        SizedBox(width: 2),
                        Icon(Icons.compare_arrows, size: 20),
                      ]),
                    ),
            ),
          ),
          const Spacer(),
          if (pageName == appName)
            Tooltip(
              message: 'View Stats',
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const StatsDialog();
                    },
                  );
                },
                child: MediaQuery.of(context).size.width > 600
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stat(
                            icon: Icons.cleaning_services_outlined,
                            data: Provider.of<AppData>(context, listen: false)
                                .getCleanupCount()
                                .toString(),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 1,
                            height: 24,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 8),
                          Stat(
                            icon: Icons.delete_outline,
                            data: Provider.of<AppData>(context, listen: false)
                                .getTrashCount()
                                .toString(),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cleaning_services_outlined),
                          Text("Stats"),
                        ],
                      ),
              ),
            ),
          if (pageName == zipPageName)
            Builder(
              builder: (context) {
                final completed = Provider.of<AppData>(context, listen: true)
                    .getCompletedZipCodes();
                final total = Provider.of<AppData>(context, listen: true)
                    .getTotalZipCodes();
                final percent = total > 0
                    ? ((completed / total) * 100).toStringAsFixed(1)
                    : '0';
                final isMobile = MediaQuery.of(context).size.width < 600;
                if (isMobile) {
                  // Mobile: show only completed/total
                  return Tooltip(
                    message: '$percent% completed',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: Colors.blue.shade200, width: 1),
                      ),
                      child: Text(
                        '$completed / $total',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  );
                } else {
                  // Desktop/tablet: show icon, completed/total, percent
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.blue.shade200, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_pin,
                            color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          '$completed / $total',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$percent%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          const Spacer(),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ElevatedButton(
              onPressed: () => {
                    if (auth.currentUser != null)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Profile()),
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
                  : Tooltip(
                      message: 'View Profile',
                      child: Text(getProfileName(auth)),
                    )),
        )
      ],
    );
  }
}
