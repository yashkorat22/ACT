import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;

class SplashScreenController extends ControllerMVC {
  ValueNotifier<Map<String, double>> progress = new ValueNotifier(new Map());
  GlobalKey<ScaffoldState>? scaffoldKey;
  String connectionStatus = 'Unknown';
  BuildContext? context;

  SplashScreenController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    // Should define these variables before the app loaded
    progress.value = {"Setting": 0, "User": 0, "Connectivity": 0};
  }

  @override
  void initState() {
    super.initState();
    context = state!.context;
    settingRepo.setting.addListener(() {
      if (settingRepo.setting.value.appName != null &&
          settingRepo.setting.value.appName != '' &&
          settingRepo.setting.value.mainColor != null) {
        progress.value["Setting"] = 20;
        progress.notifyListeners();
      }
    });
    userRepo.currentUser.addListener(() {
      if (userRepo.currentUser.value.auth != null) {
        progress.value["User"] = 40;
        progress.notifyListeners();
      }
    });
    settingRepo.initSettings();
    userRepo.getCurrentUser();

    Timer(Duration(seconds: 20), () {
      double progressValue = 0;
      String progressValues = "";
      progress.value.forEach((key, _progress) {
        progressValue += _progress;
        progressValues += "$key: $_progress, ";
      });
      if (progressValue < 70) {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          // content: Text("Something went wrong while loading the app."),
          content: Text(progressValues),
        ));
      }
    });
  }

  Future<void> initConnectivity() async {
    try {
      final response = await InternetAddress.lookup('www.google.com');
      if (response.isNotEmpty) {
        setState(() => {connectionStatus = "Connected"});
        progress.value["Connectivity"] = 40;
      }
    } on SocketException catch (err) {
      setState(() => {connectionStatus = 'none'});
      progress.value["Connectivity"] = 20;
      print(err);
    }
    progress.notifyListeners();
  }
}
