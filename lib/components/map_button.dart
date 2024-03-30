import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class MapButton extends StatelessWidget {
  final String image;
  final Function callback;
  final String tooltip;
  final bool stroke;

  const MapButton({
    super.key,
    required this.image,
    required this.callback,
    required this.tooltip,
    required this.stroke,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: PointerInterceptor(
        child: GestureDetector(
          onTap: () => {callback()},
          child: Tooltip(
              message: tooltip,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                  border: stroke
                      ? Border.all(
                          color: Colors.green,
                          width: 4,
                        )
                      : null,
                ),
              )),
        ),
      ),
    );
  }
}
