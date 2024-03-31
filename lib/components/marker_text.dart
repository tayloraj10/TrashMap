import 'package:flutter/material.dart';

class MarkerText extends StatelessWidget {
  final String leadingText;
  final String mainText;
  final TextStyle leadingStyle;
  final TextStyle mainStyle;
  const MarkerText(
      {super.key,
      required this.leadingText,
      required this.mainText,
      this.leadingStyle = const TextStyle(),
      this.mainStyle = const TextStyle()});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
              text: leadingText,
              style: leadingStyle,
            ),
            TextSpan(text: mainText, style: mainStyle)
          ]),
        ));
  }
}
