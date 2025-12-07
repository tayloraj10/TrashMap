import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trash_map/models/models.dart';

class ZipCodeSubmissionDialog extends StatefulWidget {
  final String zipCode;

  const ZipCodeSubmissionDialog({
    Key? key,
    required this.zipCode,
  }) : super(key: key);

  static Future<void> show(BuildContext context, String zipCode) {
    return showDialog(
      context: context,
      builder: (context) => ZipCodeSubmissionDialog(zipCode: zipCode),
    );
  }

  @override
  State<ZipCodeSubmissionDialog> createState() =>
      _ZipCodeSubmissionDialogState();
}

class _ZipCodeSubmissionDialogState extends State<ZipCodeSubmissionDialog> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController smallBagsController = TextEditingController();
  final TextEditingController largeBagsController = TextEditingController();
  final TextEditingController poundsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (auth.currentUser?.displayName != null) {
      nameController.text = auth.currentUser!.displayName!;
    }
  }

  Future<void> submitCleanup(
      ZipCodeSubmission data, BuildContext context) async {
    // Check if this zip code already exists in the collection
    final existing = await FirebaseFirestore.instance
        .collection("zipcode_cleanups")
        .where('zipCode', isEqualTo: data.zipCode)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      // Show error dialog if already claimed
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Already Claimed'),
          content: const Text('This zip code has already been claimed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection("zipcode_cleanups")
        .add(data.toMap())
        .then((value) {
      Navigator.of(context).pop({
        'type': 'submission',
        'zipCode': widget.zipCode,
        'name': data.name,
        'imageUrl': data.imageUrl,
        'smallBags': data.smallBags,
        'largeBags': data.largeBags,
        'pounds': data.pounds,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          elevation: 0,
          title: Text('Zip Code: ${widget.zipCode}'),
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
                  ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxHeight: 80, maxWidth: 250),
                    child: TextFormField(
                      controller: imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL',
                      ),
                      maxLines: null,
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        if (value.startsWith('data:image')) return null;
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
                    validator: (value) {
                      // Only validate here if all are empty
                      if ((value == null || value.isEmpty) &&
                          (largeBagsController.text.isEmpty) &&
                          (poundsController.text.isEmpty)) {
                        return 'Enter at least one cleanup value';
                      }
                      return null;
                    },
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
                    validator: (value) {
                      if ((value == null || value.isEmpty) &&
                          (smallBagsController.text.isEmpty) &&
                          (poundsController.text.isEmpty)) {
                        return 'Enter at least one cleanup value';
                      }
                      return null;
                    },
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
                    validator: (value) {
                      if ((value == null || value.isEmpty) &&
                          (smallBagsController.text.isEmpty) &&
                          (largeBagsController.text.isEmpty)) {
                        return 'Enter at least one cleanup value';
                      }
                      return null;
                    },
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
                  submitCleanup(
                    ZipCodeSubmission(
                      zipCode: widget.zipCode,
                      userID: FirebaseAuth.instance.currentUser?.uid,
                      name: nameController.text,
                      imageUrl: imageUrlController.text.isEmpty
                          ? null
                          : imageUrlController.text,
                      smallBags: smallBagsController.text.isEmpty
                          ? null
                          : int.tryParse(smallBagsController.text),
                      largeBags: largeBagsController.text.isEmpty
                          ? null
                          : int.tryParse(largeBagsController.text),
                      pounds: poundsController.text.isEmpty
                          ? null
                          : double.tryParse(poundsController.text),
                    ),
                    context,
                  );
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
