import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/home_controller.dart';
import '../../elements/DrawerWidget.dart';
import '../../elements/HelpButtonWidget.dart';

import '../../repository/user_repository.dart' as user_repo;
import '../../repository/member_repository.dart' as member_repo;
import '../../repository/settings_repository.dart';
import '../../helpers/helper.dart';

import '../../models/user.dart';

class HomeWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  HomeWidget({Key? key, this.parentScaffoldKey}) : super(key: key);
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends StateMVC<HomeWidget> {
  late HomeController _con;
  bool isSocietyLoaded = false;
  SharedPreferences? prefs;

  String? firstName = user_repo.currentUser.value.firstName;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  User userData = User();

  _HomeWidgetState() : super(HomeController()) {
    _con = controller as HomeController;
  }

  void _onRefresh() async {
    await user_repo.login(user_repo.currentUser.value);
    await user_repo.getProfile();

    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    debugPrint(Intl.getCurrentLocale());

    SharedPreferences.getInstance().then((instance) {
      prefs = instance;
      if (!(prefs!.getBool("home_visited") ?? false)) {
        Future.delayed(const Duration(seconds: 1), () {
          prefs!.setBool("home_visited", true);
          Helper.of(context).showHintDialog(Helper.homeHelp());
        });
      }
    });

    userData = user_repo.currentUser.value;
    user_repo.currentUser.addListener(() {
      setState(() {
        userData = user_repo.currentUser.value;
      });
    });

    isSocietyLoaded = user_repo.currentUserSocieties.value.length != 0;
    user_repo.currentUserSocieties.addListener(() {
      setState(() {
        isSocietyLoaded = user_repo.currentUserSocieties.value.length != 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
        key: _con.scaffoldKey,
        drawer: DrawerWidget(),
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.sort, color: Theme.of(context).primaryColor),
            onPressed: () => _con.scaffoldKey?.currentState?.openDrawer(),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).accentColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            setting.value.appName ?? 'ACT',
            style: Theme.of(context).textTheme.headline6!.merge(
                  TextStyle(
                    letterSpacing: 1.3,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
          ),
        ),
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: ClassicHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
            child: Stack(
              children: [
                Column(
                  children: <Widget>[
                    if (userData.firstName != null)
                      Text(
                        AppLocalizations.of(context)!.homeUserWelcome +
                            " " +
                            userData.firstName! +
                            "!", // = Welcome
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    if (isSocietyLoaded)
                      Expanded(
                          child: GridView.count(
                        primary: false,
                        padding: const EdgeInsets.all(20),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        crossAxisCount: 2,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              if (isSocietyLoaded) {
                                member_repo.createdId = -1;
                                Navigator.of(context)
                                    .pushReplacementNamed('/Classes');
                              }
                            },
                            child: Column(
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset('assets/img/groups.jpg'),
                                ),
                                SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.homeTileClasses, // = Classes
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                  ),
                                )
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (isSocietyLoaded) {
                                member_repo.createdId = -1;
                                Navigator.of(context)
                                    .pushReplacementNamed('/Members');
                              }
                            },
                            child: Column(
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset('assets/img/members.jpg'),
                                ),
                                SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.homeTileMembers, // = Members
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                  ),
                                )
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (isSocietyLoaded) {
                                member_repo.createdId = -1;
                                Navigator.of(context)
                                    .pushReplacementNamed('/Events');
                              }
                            },
                            child: Column(
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset('assets/img/events.jpg'),
                                ),
                                SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.homeTileEvents, // = Events
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                  ),
                                )
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (isSocietyLoaded) {
                                member_repo.createdId = -1;
                                Navigator.of(context)
                                    .pushReplacementNamed('/Locations');
                              }
                            },
                            child: Column(
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child:
                                      Image.asset('assets/img/locations.jpg'),
                                ),
                                SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    AppLocalizations
                                        .of(context)
                                        !.homeTileLocations, // = Locations
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                  ),
                                )
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (isSocietyLoaded) {
                                member_repo.createdId = -1;
                                Navigator.of(context)
                                    .pushReplacementNamed('/ShoppingCarts');
                              }
                            },
                            child: Column(
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset('assets/img/invoices.jpg'),
                                ),
                                SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    AppLocalizations
                                        .of(context)
                                        !.homeTileInvoices, // = Invoices
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                  ),
                                )
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (isSocietyLoaded) {
                                member_repo.createdId = -1;
                                Navigator.of(context)
                                    .pushReplacementNamed('/Subscriptions');
                              }
                            },
                            child: Column(
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset(
                                      'assets/img/subscriptions.jpg'),
                                ),
                                SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    AppLocalizations
                                        .of(context)
                                        !.homeTileSubscriptions, // = Subscriptions
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      )),
                    if (!isSocietyLoaded)
                      new Expanded(
                          child: Center(child: CircularProgressIndicator())),
                  ],
                ),
                if (isSocietyLoaded)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: HelpButtonWidget(
                      showHelpDialog: () =>
                          Helper.of(context).showHintDialog(Helper.homeHelp()),
                      color: Theme.of(context).accentColor,
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
