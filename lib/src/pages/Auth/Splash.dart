import 'dart:async';

import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'dart:io' show Platform;

import '../../repository/settings_repository.dart' as settingsRepo;
import '../../repository/user_repository.dart' as userRepo;
import '../../controllers/splash_screen_controller.dart';
import '../../elements/BlockButtonWidget.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends StateMVC<SplashScreen>
    with WidgetsBindingObserver {
  late SplashScreenController _con;
  bool failed = false;

  SplashScreenState() : super(SplashScreenController()) {
    _con = controller as SplashScreenController;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    Timer(Duration(seconds: 3), () {
      loadData();
      // userRepo.getCurrentUser();
      _con.initConnectivity();
    });
  }

  void loadData() {
    _con.progress.addListener(() async {
      double progress = 0;
      _con.progress.value.values.forEach((_progress) {
        progress += _progress;
      });
      if (progress == 100) {
        try {
          if (userRepo.currentUser.value.auth == true) {
            Navigator.of(context).pushReplacementNamed('/Home');
          } else {
            if (userRepo.currentUser.value.email != null &&
                userRepo.currentUser.value.email != '') {
              setState(() => failed = true);
            } else {
//              Navigator.of(context).pushReplacementNamed('/Login');
              Navigator.of(context).pushReplacementNamed('/SignUp');            // Show signup instead for login when no credentials are available.
            }
          }
        } catch (e) {}
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (Platform.isIOS && settingsRepo.settingOpened) {
      if (state == AppLifecycleState.resumed) {
        settingsRepo.settingOpened = false;
        Navigator.of(context).pop();
        try {
          Navigator.of(context).pushReplacementNamed('/Home', arguments: 2);
        } catch (e) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: _con.connectionStatus != 'none'
                ? (!failed
                    ? <Widget>[
                        // Image.asset(
                        //   'assets/img/logo.png',
                        //   width: 150,
                        //   fit: BoxFit.cover,
                        // ),
                        Text(
                          AppLocalizations.of(context)!.appInfoLoading,                         // 'Loading ... ',
                          style: Theme.of(context).textTheme.subtitle1!.merge(
                              TextStyle(color: Theme.of(context).accentColor)),
                        ),
                        SizedBox(height: 50),
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).accentColor),
                        )
                      ]
                    : <Widget>[
                        Text(
                          AppLocalizations.of(context)!.appInfoErrorOccured,                    // 'Something went wrong.',
                          style: Theme.of(context).textTheme.subtitle1!.merge(
                                TextStyle(color: Theme.of(context).accentColor),
                              ),
                        ),
                        SizedBox(height: 50),
                        BlockButtonWidget(
                          text: Text(
                            AppLocalizations.of(context)!.appInfoGotoLogin,                     // "Go to Login",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                          color: Theme.of(context).accentColor,
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed('/Login');
                          },
                        ),
                      ])
                : <Widget>[
                    Text(
                      AppLocalizations.of(context)!.appInfoNoConnection,                        // 'No internet',
                      style: Theme.of(context).textTheme.subtitle1!.merge(
                            TextStyle(color: Theme.of(context).accentColor),
                          ),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
