import 'package:flutter/material.dart';

class Stat extends StatelessWidget {
  final IconData icon;
  final String data;
  final Color? color;

  const Stat({super.key, required this.icon, required this.data, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
        ),
        Text(
          data,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: color),
        ),
      ],
    );
  }
}
