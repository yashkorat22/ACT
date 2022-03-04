import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class FloatInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String oldText = oldValue.text;
    final String text = newValue.text;
    String result = text;
    int selectionIndex = newValue.selection.end;
    if (oldText == text) {
      return newValue;
    }
    if (text.endsWith('.')) {
      if (oldText.endsWith('.')) return oldValue;
      return newValue;
    }
    if (text.contains('.')) {
      if (text.split('.')[1].length > 2) return oldValue;
    }
    if (text.length == 0) {
      result = '0';
      selectionIndex = 1;
    } else {
      try {
        double val = double.parse(text);
        if (val > 10000) {
          result = 10000.toString();
          selectionIndex = 5;
        } else if (text.startsWith('0') && text != '0') {
          result = text;
          while (result.startsWith('0') && !result.startsWith('0.') && result != '0') {
            result = result.substring(1);
            if (selectionIndex > 0)
              selectionIndex --;
          }
        }
      } catch (e) {
        return oldValue;
      }
    }
    return newValue.copyWith(
      text: result,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
