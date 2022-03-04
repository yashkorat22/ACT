import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import '../helpers/helper.dart';

class CustomDatePicker extends StatelessWidget {
  final TextEditingController controller = new TextEditingController();
  final String label;
  final String value;
  final bool? disabled;
  final bool? filled;
  final Function onChange;

  CustomDatePicker({
    Key? key,
    required this.label,
    required this.value,
    this.disabled,
    this.filled,
    required this.onChange,
  }) : super(key: key) {}

  String localize(String date) {
    return date.length == 10 &&
            RegExp(r'([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))')
                .hasMatch(date)
        ? DateFormat.yMMMd(defaultLocale).format(DateTime.parse(value))
        : '';
  }

  @override
  Widget build(BuildContext context) {
    controller.text = localize(value);
    return TextFormField(
      keyboardType: TextInputType.datetime,
      readOnly: true,
      controller: controller,
      onTap: () async {
        if (disabled == true) return;
        final date = value;
        final newDate = await DatePicker.showSimpleDatePicker(
          context,
          initialDate: date.length == 10 &&
                  RegExp(r'([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))')
                      .hasMatch(date)
              ? DateTime.parse(value)
              : DateTime(2000),
          dateFormat: Helper.datePickerFormat(),
          locale: Helper.datePickerLocale(),
          looping: true,
          confirmText: AppLocalizations.of(context)!.appButtonOk, // "OK",
          cancelText: AppLocalizations.of(context)!.appButtonCancel, //"Cancel",
          textColor: Theme.of(context).accentColor,
          backgroundColor: Theme.of(context).primaryColor,
        );
        if (newDate != null) {
          final newText = DateFormat('yyyy-MM-dd').format(newDate);
          onChange(newText);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).accentColor),
        contentPadding: EdgeInsets.all(12),
        filled: disabled == true && filled != false,
        fillColor: Theme.of(context).hintColor.withOpacity(0.05),
        hintText: Helper.datePickerFormat().toUpperCase(),
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
