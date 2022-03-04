import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import 'package:global_configuration/global_configuration.dart';

import '../repository/settings_repository.dart';
import '../repository/user_repository.dart';

var appVer = GlobalConfiguration().getValue('app_ver') ?? "0.0.0";
var appEnv = GlobalConfiguration().getValue('app_env') ?? "inofficial";

class DrawerWidget extends StatefulWidget {
  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends StateMVC<DrawerWidget> {
  String? society;
  int? societyId;
  _DrawerWidgetState() : super() {
    if (currentUserSocieties.value.length != 0) {
      society = currentUserSocieties.value
          .firstWhere((so) => so.isPrimary == true)
          .name;
    }
    currentUserSocieties.addListener(() {
      if (currentUserSocieties.value.length != 0) {
        setState(() {
          society = currentUserSocieties.value
              .firstWhere((so) => so.isPrimary == true)
              .name;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/Profile');
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).hintColor.withOpacity(0.1),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.person,
                          size: 32,
                          color: Theme.of(context).accentColor.withOpacity(1),
                        ),
                        SizedBox(width: 30),
                        if (currentUser.value.firstName != null &&
                            currentUser.value.lastName != null)
                          Text(
                            currentUser.value.firstName! +
                                " " +
                                currentUser.value.lastName!,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                      ],
                    ),
                  ),
                ),
                // if (currentUserSocieties.value.length != 0)
                //   ListTile(
                //     onTap: () {
                //       _showSocietyDialog();
                //     },
                //     leading: Icon(
                //       Icons.group,
                //       color: Theme.of(context).focusColor.withOpacity(1),
                //     ),
                //     title: Text(
                //       society!,
                //       style: Theme.of(context).textTheme.subtitle1,
                //     ),
                //   ),
                ListTile(
                  onTap: () {
                    setBrightness(
                        Theme.of(context).brightness == Brightness.light);
                    setting.value.isDark =
                        Theme.of(context).brightness == Brightness.light;
                  },
                  leading: Icon(
                    Icons.brightness_6,
                    color: Theme.of(context).focusColor.withOpacity(1),
                  ),
                  title: Text(
                    Theme.of(context).brightness == Brightness.dark
                        ? AppLocalizations.of(context)!.appThemeModeLight                       // = Light Mode
                        : AppLocalizations.of(context)!.appThemeModeDark,                       // = Dark Mode
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                ListTile(
                  onTap: () {
                    logout().then((value) {
                      Navigator.of(context).pushNamed('/Login');
                    });
                  },
                  leading: Icon(
                    Icons.exit_to_app,
                    color: Theme.of(context).focusColor.withOpacity(1),
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.appButtonLogout,                              // = Logout
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 20, bottom: 10),
            child: ListTile(
              title: Text("Version: " + appVer + " (" + appEnv + ")",
                  style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }
}
