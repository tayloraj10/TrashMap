import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ZipCodeInfoDialog extends StatelessWidget {
  final String zipCode;

  const ZipCodeInfoDialog({
    Key? key,
    required this.zipCode,
  }) : super(key: key);

  static Future<void> show(BuildContext context, String zipCode) {
    return showDialog(
      context: context,
      builder: (context) => ZipCodeInfoDialog(zipCode: zipCode),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();
    final TextEditingController smallBagsController = TextEditingController();
    final TextEditingController largeBagsController = TextEditingController();
    final TextEditingController poundsController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          elevation: 0,
          title: Text('Zip Code: $zipCode'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Your Name',
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter your name'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Image URL',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return null;
                      final uri = Uri.tryParse(value);
                      if (uri == null ||
                          !(uri.isAbsolute &&
                              (uri.hasScheme &&
                                  (uri.scheme == 'http' ||
                                      uri.scheme == 'https')))) {
                        return 'Enter a valid URL or leave blank';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: smallBagsController,
                    decoration: const InputDecoration(
                      labelText: 'Small Bags Cleaned Up',
                      helperText: '(about a plastic shopping bag)',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: largeBagsController,
                    decoration: const InputDecoration(
                      labelText: 'Large Bags Cleaned Up',
                      helperText: '(about a plastic garbage bag)',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: poundsController,
                    decoration:
                        const InputDecoration(labelText: 'Pounds Cleaned Up'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // You can handle the claim logic here, e.g., send data to backend
                  Navigator.of(context).pop({
                    'zipCode': zipCode,
                    'name': nameController.text,
                    'imageUrl': imageUrlController.text,
                    'smallBags': int.tryParse(smallBagsController.text) ?? 0,
                    'largeBags': int.tryParse(largeBagsController.text) ?? 0,
                    'pounds': double.tryParse(poundsController.text) ?? 0.0,
                  });
                }
              },
              child: const Text('Claim Zip Code'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}
