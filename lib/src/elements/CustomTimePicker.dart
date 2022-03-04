import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class CustomTimePicker extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool? disabled;
  final bool? filled;

  CustomTimePicker(
      {Key? key,
      required this.controller,
      required this.label,
      this.disabled,
      this.filled})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.datetime,
      readOnly: true,
      validator: (input) => (input!.length > 0 && input.length != 5) ||
              !RegExp(r'(([01]\d|2[0-3]):([0-5]\d))').hasMatch(input)
          ? 'Invalid format'
          : null,
      controller: controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onTap: () async {
        if (disabled == true) return;
        final time = controller.text;
        DatePicker.showTimePicker(
          context,
          showTitleActions: true,
          showSecondsColumn: false,
          onChanged: (date) {},
          onConfirm: (date) {
            final DateFormat timeFormatter = DateFormat('HH:mm');
            controller.text = timeFormatter.format(date);
          },
          currentTime: DateTime(2000, 1, 1, int.parse(time.split(":")[0]),
              int.parse(time.split(":")[1])),
        );
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).accentColor),
        contentPadding: EdgeInsets.all(12),
        filled: disabled == true && filled != false,
        fillColor: Theme.of(context).hintColor.withOpacity(0.05),
        hintText: 'YYYY-MM-DD',
        hintStyle:
            TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
        border: OutlineInputBorder(
            borderSide: BorderSide(
                color: Theme.of(context).focusColor.withOpacity(0.2))),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Theme.of(context).focusColor.withOpacity(0.5))),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Theme.of(context).focusColor.withOpacity(0.2))),
      ),
    );
  }
}
