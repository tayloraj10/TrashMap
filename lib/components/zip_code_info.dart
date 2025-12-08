import 'package:flutter/material.dart';
import 'package:trash_map/models/models.dart';

class ZipCodeInfoDialog extends StatelessWidget {
  final ZipCodeSubmission zipCodeData;

  const ZipCodeInfoDialog({
    Key? key,
    required this.zipCodeData,
  }) : super(key: key);

  static Future<void> show(
      BuildContext context, ZipCodeSubmission zipCodeData) {
    return showDialog(
      context: context,
      builder: (context) => ZipCodeInfoDialog(
        zipCodeData: zipCodeData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white.withOpacity(0.95),
      elevation: 8,
      title: Text(
        'Zip Code: ${zipCodeData.zipCode}',
      ),
      content: SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (zipCodeData.imageUrl != null) ...[
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: NetworkImage(zipCodeData.imageUrl!),
                      backgroundColor: Colors.grey[200],
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: Text(
                      zipCodeData.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (zipCodeData.smallBags != null)
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text(
                          "Small Bags:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          zipCodeData.smallBags.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  if (zipCodeData.smallBags != null) const SizedBox(height: 12),
                  if (zipCodeData.largeBags != null)
                    Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text(
                          "Large Bags:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          zipCodeData.largeBags.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  if (zipCodeData.largeBags != null) const SizedBox(height: 12),
                  if (zipCodeData.pounds != null)
                    Row(
                      children: [
                        const Icon(Icons.scale, color: Colors.red),
                        const SizedBox(width: 8),
                        const Text(
                          "Pounds:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          zipCodeData.pounds.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        "Date:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        "${zipCodeData.date.year}-${zipCodeData.date.month.toString().padLeft(2, '0')}-${zipCodeData.date.day.toString().padLeft(2, '0')}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              )
            ]),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          label: const Text('Close'),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
