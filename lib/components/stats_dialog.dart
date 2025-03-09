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
        'Stats',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(),
            1: FixedColumnWidth(32),
            2: FlexColumnWidth(),
          },
          children: [
            TableRow(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Cleanups',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.cleaning_services_outlined,
                            color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          Provider.of<AppData>(context, listen: false)
                              .getCleanupCount()
                              .toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Trash Reports',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.delete_outline, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          Provider.of<AppData>(context, listen: false)
                              .getTrashCount()
                              .toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            TableRow(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Weight',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.scale, color: Colors.green),
                        const SizedBox(width: 8),
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
                const SizedBox(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Bags',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined,
                            color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          Provider.of<AppData>(context, listen: false)
                              .getBags()
                              .toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (auth.currentUser != null) ...[
              const TableRow(
                children: [
                  SizedBox(height: 8),
                  SizedBox(),
                  SizedBox(height: 8),
                ],
              ),
              TableRow(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Cleanups',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.cleaning_services_rounded,
                              color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            Provider.of<AppData>(context, listen: false)
                                .getYourCleanupCount()
                                .toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Trash Reports',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.delete, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            Provider.of<AppData>(context, listen: false)
                                .getYourTrashCount()
                                .toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              TableRow(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Weight',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.scale, color: Colors.blue),
                          const SizedBox(width: 8),
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
                  const SizedBox(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Bags',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.shopping_bag, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            Provider.of<AppData>(context, listen: false)
                                .getYourBags()
                                .toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
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
