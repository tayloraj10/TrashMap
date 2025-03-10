import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MarkerTextEdit extends StatelessWidget {
  final String tooltip;
  final TextStyle style;
  final IconData icon;
  final TextEditingController controller;
  final Function validation;
  final List<TextInputFormatter>? inputFormatters;

  const MarkerTextEdit(
      {super.key,
      required this.tooltip,
      this.style = const TextStyle(),
      required this.icon,
      required this.controller,
      required this.validation,
      this.inputFormatters});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Tooltip(
        message: tooltip,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(hintText: tooltip),
                controller: controller,
                style: style,
                inputFormatters: inputFormatters,
              ),
            )
          ],
        ),
      ),
    );
  }
}
