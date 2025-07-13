import 'package:flutter/material.dart';

class MapText extends StatelessWidget {
  final String text;
  const MapText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Align(
        alignment: Alignment.topCenter,
        child: Card(
          elevation: 6,
          color: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.blueAccent, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: Colors.blueAccent.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
