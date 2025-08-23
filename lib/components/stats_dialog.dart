import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash_map/models/app_data.dart';

class StatsDialog extends StatefulWidget {
  const StatsDialog({super.key});

  @override
  State<StatsDialog> createState() => _StatsDialogState();
}

class _StatsDialogState extends State<StatsDialog> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Stats for Last 6 Months',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Stats
            Text(
              "Overall Stats",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.green[50],
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cleaning_services_outlined,
                            color: Colors.green),
                        const SizedBox(width: 8),
                        const Text("Total Cleanups:"),
                        const Spacer(),
                        Text(
                          Provider.of<AppData>(context, listen: false)
                              .getCleanupCount()
                              .toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Icon(Icons.delete_outline, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text("Total Trash Reports:"),
                        const Spacer(),
                        Text(
                          Provider.of<AppData>(context, listen: false)
                              .getTrashCount()
                              .toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined,
                            color: Colors.green),
                        const SizedBox(width: 8),
                        const Text("Total Bags:"),
                        const Spacer(),
                        Text(
                          Provider.of<AppData>(context, listen: false)
                              .getBags()
                              .toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Icon(Icons.scale, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text("Total Weight:"),
                        const Spacer(),
                        Text(
                          Provider.of<AppData>(context, listen: false)
                              .getPounds()
                              .toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // User Stats
            if (auth.currentUser != null) ...[
              Text(
                "Your Stats",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.blue[50],
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.cleaning_services_rounded,
                              color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text("Your Cleanups:"),
                          const Spacer(),
                          Text(
                            Provider.of<AppData>(context, listen: false)
                                .getYourCleanupCount()
                                .toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          const Icon(Icons.delete, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text("Your Trash Reports:"),
                          const Spacer(),
                          Text(
                            Provider.of<AppData>(context, listen: false)
                                .getYourTrashCount()
                                .toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          const Icon(Icons.shopping_bag, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text("Your Bags:"),
                          const Spacer(),
                          Text(
                            Provider.of<AppData>(context, listen: false)
                                .getYourBags()
                                .toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          const Icon(Icons.scale, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text("Your Weight:"),
                          const Spacer(),
                          Text(
                            Provider.of<AppData>(context, listen: false)
                                .getYourPounds()
                                .toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
