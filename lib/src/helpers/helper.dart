import 'dart:async';
import 'dart:io';
//import 'dart:js';

import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:flutter_gen/gen_l10n/s.dart';
//import 'package:intl/intl.dart';
//import 'package:flutter_gen/gen_l10n/s.dart';

import '../elements/CircularLoadingWidget.dart';
import '../elements/CarouselContentWidget.dart';

final String defaultLocale = Platform.localeName; // = import 'dart:io';
final String apiLocaleSuffix = '?lang=' +
    Platform.localeName.substring(0, 2) +
    '-' +
    Platform.localeName.substring(3, 5);

// = Helper for missing context when use for AppLocalizations.of(context)!...

class Helper {
  BuildContext? context;
  DateTime? currentBackPressTime;

  Helper.of(BuildContext _context) {
    this.context = _context;
  }

  static OverlayEntry overlayLoader(context) {
    OverlayEntry loader = OverlayEntry(builder: (context) {
      final size = MediaQuery.of(context).size;
      return Positioned(
        height: size.height,
        width: size.width,
        top: 0,
        left: 0,
        child: Material(
          color: Theme.of(context).primaryColor.withOpacity(0.85),
          child: CircularLoadingWidget(height: 200),
        ),
      );
    });
    return loader;
  }

  static hideLoader(OverlayEntry? loader) {
    Timer(Duration(milliseconds: 500), () {
      try {
        loader?.remove();
      } catch (e) {}
    });
  }

  static datePickerFormat() {
    switch (defaultLocale) {
      case 'en_US':
        return 'MMMM-dd-yyyy'; // MM-dd-yyyy = 08-15-1996; MMMM-dd-yyyy = August 15, 1996
      default:
        return 'dd-MMMM-yyyy'; // dd-MM-yyyy = 15-8-1996; dd-MMMM-yyyy = 15. August. 1996
    }
  }

  static datePickerLocale() {
    switch (defaultLocale.substring(0, 2)) {
      case 'de':
        return DateTimePickerLocale.de;
      case 'zh':
        return DateTimePickerLocale.zh_cn;
      case 'pt':
        return DateTimePickerLocale.pt_br;
      case 'es':
        return DateTimePickerLocale.es;
      case 'ro':
        return DateTimePickerLocale.ro;
      case 'bn':
        return DateTimePickerLocale.bn;
      case 'ar':
        return DateTimePickerLocale.ar;
      case 'jp':
        return DateTimePickerLocale.jp;
      case 'ru':
        return DateTimePickerLocale.ru;
      case 'ko':
        return DateTimePickerLocale.ko;
      case 'it':
        return DateTimePickerLocale.it;
      case 'hu':
        return DateTimePickerLocale.hu;
      case 'he':
        return DateTimePickerLocale.he;
      case 'id':
        return DateTimePickerLocale.id;
      case 'tr':
        return DateTimePickerLocale.tr;
      case 'fr':
        return DateTimePickerLocale.fr;
      case 'th':
        return DateTimePickerLocale.th;
      default:
        return DateTimePickerLocale.en_us;
    }
  }

  static termsAndConditionsUrl() {
    switch (defaultLocale.substring(0, 2)) {
      case 'de':
        return 'assets/html/TermsAndConditions_de.html';

      case 'fr':
        return 'assets/html/TermsAndConditions_fr.html';

      default:
        return 'assets/html/TermsAndConditions_en.html';
    }
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context!)!.appInfoTapAgainToLeave); // Tap again to leave
      return Future.value(false);
    }
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return Future.value(true);
  }

  Future<void> showHintDialog(items) {
    return showDialog<void>(
      context: this.context!,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("A small help"),
          children: [
            CarouselContentWidget(items: items),
            TextButton(
              child: Text("OK, got it."),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static List<Widget> homeHelp() {
    return [
      Column(
        children: [
          Text(
              "You can swipe left and right to modify elements."), // "You can swipe left and right to modify elements."
          Image.asset("assets/img/slide_hint.gif"),
        ],
      ),
      Column(
        children: [
          Text("You can tap the helper button to get this small help."),
          Image.asset("assets/img/events_help_button.jpg"),
        ],
      )
    ];
  }

  textInputDecoration(labelText, hintText, {prefixIcon, filled, fillColor}) {
    final context = this.context!;
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Theme.of(context).accentColor),
      contentPadding: EdgeInsets.all(12),
      prefixIcon: prefixIcon,
      hintText: hintText,
      filled: filled,
      fillColor: fillColor,
      hintStyle:
          TextStyle(color: Theme.of(context).focusColor.withOpacity(0.7)),
      border: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
      focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).focusColor.withOpacity(0.5))),
      enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).focusColor.withOpacity(0.2))),
    );
  }
}
