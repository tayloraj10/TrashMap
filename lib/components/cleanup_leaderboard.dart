import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash_map/models/app_data.dart';

class CleanupLeaderboard extends StatelessWidget {
  const CleanupLeaderboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        // Leaderboard
        Text(
          "Leaderboard (Bags Cleaned)",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange[700],
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: Colors.orange[50],
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Consumer<AppData>(
              builder: (context, appData, _) {
                final groupCounts = appData.getCleanupCountByGroup();
                final sortedGroups = groupCounts.entries.toList()
                  ..sort((MapEntry<String, int> a, MapEntry<String, int> b) =>
                      b.value.compareTo(a.value));
                if (sortedGroups.isEmpty) {
                  return const Text("No group data available.");
                }
                return Column(
                  children: List.generate(sortedGroups.length, (index) {
                    final entry = sortedGroups[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Text(
                            "${index + 1}.",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.key,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entry.value.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
