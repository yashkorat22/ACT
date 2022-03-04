import 'dart:io';

import 'package:act/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:global_configuration/global_configuration.dart';

import 'route_generator.dart';
import 'src/helpers/app_config.dart' as config;
import 'src/helpers/custom_trace.dart';
import 'src/models/setting.dart';
import 'src/repository/settings_repository.dart' as settingRepo;
import 'package:flutter_gen/gen_l10n/s.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GlobalConfiguration().loadFromAsset("environment");

  bool isInRelease;

  assert(() { isInRelease = false; return true; }());

  if (GlobalConfiguration().getValue('app_env') == 'dev') {

    await GlobalConfiguration().loadFromAsset("configurations.dev");

    isInRelease = false;                                                        // = Flag to "play" around with debugPrint in a 'dev' environment
    if (isInRelease) {
      debugPrint = (String? message, { int? wrapWidth }) {}; //
    }

  } else {
    await GlobalConfiguration().loadFromAsset("configurations.prd");

    isInRelease = true;                                                         // = Do not modify flag for 'prod' environment
    if (isInRelease) {
      debugPrint = (String? message, { int? wrapWidth }) {}; //
    }

  }

  HttpOverrides.global = new MyHttpOverrides();
  debugPrint(
    CustomTrace(
      StackTrace.current,
      message:
          "api_base_url: ${GlobalConfiguration().getValue('api_base_url')}",
    ).toString(),
  );

  debugPrint( "languageCode=" +Platform.localeName.substring( 0,2 ) );
  debugPrint( "countryCode =" +Platform.localeName.substring( 3,5 ) );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: settingRepo.setting,
        builder: (context, Setting _setting, _) {
          return MaterialApp(
            navigatorKey: settingRepo.navigatorKey,
            title: _setting.appName ?? "Athletic Circuit Training",
            initialRoute: '/Splash',
            onGenerateRoute: RouteGenerator.generateRoute,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: L10n.all,

            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocaleLanguage in supportedLocales) {
                if (supportedLocaleLanguage.languageCode  == Platform.localeName.substring( 0,2 ) &&
                    supportedLocaleLanguage.countryCode   == Platform.localeName.substring( 3,5 ) ) {
                  return supportedLocaleLanguage;
                }
              }

              // If device not support with locale to get language code then default get first on from the list
              return supportedLocales.first;
            },

            theme: _setting.isDark != true
                ? ThemeData(
                    fontFamily: 'ProductSans',
                    primaryColor: Colors.white,
                    floatingActionButtonTheme: FloatingActionButtonThemeData(
                        elevation: 0, foregroundColor: Colors.white),
                    brightness: Brightness.light,
                    accentColor: config.Colors().mainColor(1),
                    dividerColor: config.Colors().accentColor(0.1),
                    focusColor: config.Colors().accentColor(1),
                    hintColor: config.Colors().secondColor(1),
                    textTheme: TextTheme(
                      headline5: TextStyle(
                          fontSize: 22.0,
                          color: config.Colors().secondColor(1),
                          height: 1.3),
                      headline4: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                          color: config.Colors().secondColor(1),
                          height: 1.3),
                      headline3: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w700,
                          color: config.Colors().secondColor(1),
                          height: 1.3),
                      headline2: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w700,
                          color: config.Colors().mainColor(1),
                          height: 1.4),
                      headline1: TextStyle(
                          fontSize: 26.0,
                          fontWeight: FontWeight.w300,
                          color: config.Colors().secondColor(1),
                          height: 1.4),
                      subtitle1: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                          color: config.Colors().secondColor(1),
                          height: 1.3),
                      headline6: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w700,
                          color: config.Colors().mainColor(1),
                          height: 1.3),
                      bodyText2: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: config.Colors().secondColor(1),
                          height: 1.2),
                      bodyText1: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: config.Colors().secondColor(1),
                          height: 1.3),
                      caption: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w300,
                          color: config.Colors().accentColor(1),
                          height: 1.2),
                    ),
                  )
                : ThemeData(
                    fontFamily: 'ProductSans',
                    primaryColor: Color(0xFF252525),
                    brightness: Brightness.dark,
                    scaffoldBackgroundColor: Color(0xFF2C2C2C),
                    accentColor: config.Colors().mainDarkColor(1),
                    dividerColor: config.Colors().accentColor(0.1),
                    hintColor: config.Colors().secondDarkColor(1),
                    focusColor: config.Colors().accentDarkColor(1),
                    textTheme: TextTheme(
                      headline5: TextStyle(
                          fontSize: 22.0,
                          color: config.Colors().secondDarkColor(1),
                          height: 1.3),
                      headline4: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w700,
                          color: config.Colors().secondDarkColor(1),
                          height: 1.3),
                      headline3: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w700,
                          color: config.Colors().secondDarkColor(1),
                          height: 1.3),
                      headline2: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w700,
                          color: config.Colors().mainDarkColor(1),
                          height: 1.4),
                      headline1: TextStyle(
                          fontSize: 26.0,
                          fontWeight: FontWeight.w300,
                          color: config.Colors().secondDarkColor(1),
                          height: 1.4),
                      subtitle1: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                          color: config.Colors().secondDarkColor(1),
                          height: 1.3),
                      headline6: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w700,
                          color: config.Colors().mainDarkColor(1),
                          height: 1.3),
                      bodyText2: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: config.Colors().secondDarkColor(1),
                          height: 1.2),
                      bodyText1: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: config.Colors().secondDarkColor(1),
                          height: 1.3),
                      caption: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w300,
                          color: config.Colors().secondDarkColor(0.6),
                          height: 1.2),
                    ),
                  ),
          );
        });
  }
}
