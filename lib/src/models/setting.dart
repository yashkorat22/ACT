import 'package:global_configuration/global_configuration.dart';
import 'package:flutter/foundation.dart';
import '../helpers/custom_trace.dart';

class Setting {
  String? appName;
  String? mainColor;
  late String mainDarkColor;
  late String secondColor;
  late String secondDarkColor;
  late String accentColor;
  late String accentDarkColor;
  String? scaffoldDarkColor;
  late String scaffoldColor;
  bool? isDark;

  Setting() {
    isDark = false;
  }

  Setting.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      appName = GlobalConfiguration().getValue('app_name') ??
          "Athletic Circuit Training";
      mainColor = jsonMap['main_color'] ?? null;
      mainDarkColor = jsonMap['main_dark_color'] ?? '';
      secondColor = jsonMap['second_color'] ?? '';
      secondDarkColor = jsonMap['second_dark_color'] ?? '';
      accentColor = jsonMap['accent_color'] ?? '';
      accentDarkColor = jsonMap['accent_dark_color'] ?? '';
      scaffoldDarkColor = jsonMap['scaffold_dark_color'] ?? '';
      scaffoldColor = jsonMap['scaffold_color'] ?? '';
      isDark = false;
    } catch (e) {
      debugPrint(CustomTrace(StackTrace.current, message: e.toString()).toString());
    }
  }

//  ValueNotifier<Locale> initMobileLanguage(String defaultLanguage) {
//    SharedPreferences.getInstance().then((prefs) {
//      return new ValueNotifier(Locale(prefs.get('language') ?? defaultLanguage, ''));
//    });
//    return new ValueNotifier(Locale(defaultLanguage ?? "en", ''));
//  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["app_name"] = appName;
    return map;
  }
}
