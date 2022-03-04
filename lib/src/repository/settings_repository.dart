import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../models/setting.dart';

ValueNotifier<Setting> setting = new ValueNotifier(new Setting());
final navigatorKey = GlobalKey<NavigatorState>();

bool settingOpened = false;

Future<Setting> initSettings() async {
  Setting _setting;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    _setting = Setting.fromJSON({
      "app_name": "Athletic Circuit Training",
      "main_color": "#2196F3",
      "main_dark_color": "#E3F2FD",
      "second_color": "#043832",
      "second_dark_color": "#ccccdd",
      "accent_color": "#8c98a8",
      "accent_dark_color": "#9999aa",
      "scaffold_color": "#2c2c2c",
      "scaffold_dark_color": "#fafafa",
    });
    bool? isDark = prefs.getBool('isDark') ?? null;
    if (isDark == null) {
      isDark =
          (WidgetsBinding.instance!.window.platformBrightness == Brightness.dark);
      prefs.setBool('isDark', isDark);
    }

    _setting.isDark = isDark;
    setting.value = _setting;

    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    setting.notifyListeners();
  } catch (e) {
    debugPrint(CustomTrace(StackTrace.current,
        message: "Something went wrong while initiating settings.").toString());
    bool isDark = false;
    try {
      isDark =
          (WidgetsBinding.instance!.window.platformBrightness == Brightness.dark)
              ? true
              : false;
    } catch (er) {}
    setting.value.isDark = isDark;
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    setting.notifyListeners();
  }
  return setting.value;
}

void setBrightness(bool isDark) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('isDark', isDark);
}
