import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class PinConfirmation extends StatelessWidget {
  final Function submit;
  final Function cancel;

  const PinConfirmation(
      {super.key, required this.submit, required this.cancel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Submit",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            PointerInterceptor(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                      onPressed: () => {submit()},
                      icon: const Icon(
                        Icons.check_box,
                        size: 30,
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  CircleAvatar(
                    radius: 23,
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    child: IconButton(
                        onPressed: () => {cancel()},
                        icon: const Icon(
                          Icons.cancel,
                          size: 30,
                        )),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
