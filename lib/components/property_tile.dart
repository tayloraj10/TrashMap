import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trash_map/models/constants.dart';

class PropertyTile extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool show;
  const PropertyTile(
      {super.key,
      required this.title,
      required this.controller,
      this.show = true,
      this.keyboardType = TextInputType.text});

  Future<void> changeDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: stringToDate(controller.text),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      controller.text = dateToString(picked);
    }
  }

  Future<void> changeDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    final TimeOfDay? pickedTime = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      controller.text = dateTimeToString(DateTime(
        picked.year,
        picked.month,
        picked.day,
        pickedTime?.hour ?? 0,
        pickedTime?.minute ?? 0,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SizedBox.shrink();
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridTile(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (title != 'Change Date' && title != 'Change Date And Time')
              Text(
                title,
                textAlign: TextAlign.center,
              ),
            if (title == 'Change Date')
              ElevatedButton(
                  onPressed: () => {changeDate(context)},
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                  )),
            if (title == 'Change Date And Time')
              ElevatedButton(
                  onPressed: () => {changeDateTime(context)},
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                  )),
            // IntrinsicWidth(child:
            TextFormField(
              readOnly: title == 'Change Date',
              keyboardType: keyboardType,
              textAlign: TextAlign.center,
              controller: controller,
              inputFormatters: ['# of Bags', 'Pounds of Trash Cleaned']
                      .contains(title)
                  ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
                  : null,
            ),
            // ),
          ],
        )),
      );
    }
  }
}
