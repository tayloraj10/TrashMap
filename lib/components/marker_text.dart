import 'package:flutter/material.dart';

class MarkerText extends StatelessWidget {
  final String tooltip;
  final String text;
  final TextStyle style;
  final IconData icon;
  const MarkerText(
      {super.key,
      required this.tooltip,
      required this.text,
      this.style = const TextStyle(),
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Tooltip(
          message: tooltip,
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(
                width: 8,
              ),
              Text(
                text,
                style: style,
              )
            ],
          ),
        )
        // RichText(
        //   text: TextSpan(children: [
        //     TextSpan(
        //       text: leadingText,
        //       style: leadingStyle,
        //     ),
        //     TextSpan(text: mainText, style: mainStyle)
        //   ]),
        // )
        );
  }
}
