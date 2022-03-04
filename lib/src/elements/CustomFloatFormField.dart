import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';

import '../helpers/floatInputFormatter.dart';

class CustomFloatFormField extends StatelessWidget {
  final double? value;
  final Function onBlur;
  final bool disabled;

  TextEditingController _con = new TextEditingController();
  FocusNode _textFocus = new FocusNode();

  CustomFloatFormField({Key? key, required this.value, required this.onBlur, required this.disabled})
      : super(key: key) {
    _con.text = value.toString();
    _textFocus.addListener(() {
      if (!_textFocus.hasFocus) {
        String text = _con.text;
        if (text.endsWith('.')) {
          text = text.substring(0, text.length - 1);
        }
        double val = 240;
        try {
          val = double.parse(text);
        } catch (e) {
          print(e);
        }
        if (val < 0.01) {
          val = 0.01;
        }
        onBlur(val);
      }
    });
  }

  @override
  Widget build(context) {
    return TextFormField(
      keyboardType: TextInputType.text,
      controller: _con,
      focusNode: _textFocus,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.appInputPrice,                                 //"Price",
        labelStyle: TextStyle(color: Theme.of(context).accentColor),
        contentPadding: EdgeInsets.all(12),
        hintText: '12.34',
        hintStyle:
            TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).focusColor.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).focusColor.withOpacity(0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).focusColor.withOpacity(0.2),
          ),
        ),
      ),
      inputFormatters: [new FloatInputFormatter()],
      readOnly: disabled,
      enabled: !disabled,
    );
  }
}
