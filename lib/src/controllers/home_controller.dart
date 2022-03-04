import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class HomeController extends ControllerMVC {
  GlobalKey<ScaffoldState>? scaffoldKey;

  HomeController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }
}
