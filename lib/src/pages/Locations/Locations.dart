import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/location_controller.dart';

import '../../elements/MemberLocationWidget.dart';
import '../../elements/HelpButtonWidget.dart';

import '../../helpers/helper.dart';

import '../../models/location.dart';

import '../../repository/user_repository.dart' as user_repo;
import '../../repository/location_repository.dart' as location_repo;

class LocationsWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  LocationsWidget({Key? key, this.parentScaffoldKey}) : super(key: key);
  @override
  _LocationsWidgetState createState() => _LocationsWidgetState();
}

class _LocationsWidgetState extends StateMVC<LocationsWidget> {
  late LocationController _con;
  List<ActLocation> locations = [];
  List<ActLocation> myLocations = [];
  bool isFetching = false;
  int? societyId;
  String locationSearchText = '';
  String myLocationSearchText = '';

  final focusKey = new GlobalKey();
  SharedPreferences? prefs;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  _LocationsWidgetState() : super(LocationController()) {
    _con = controller as LocationController;
    societyId = user_repo.currentUserSocieties.value
        .firstWhere((so) => so.isPrimary == true)
        .id;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    location_repo.locations.addListener(() {
      setState(() => locations = location_repo.locations.value);
    });
    location_repo.myLocations.addListener(() {
      setState(() => myLocations = location_repo.myLocations.value);
    });
    _initData();
  }

  void _initData() async {
    setState(() => isFetching = true);
    await Future.wait([
      SharedPreferences.getInstance().then((instance) => prefs = instance),
      _getData(),
    ]);
    setState(() => isFetching = false);
    if (!(prefs!.getBool("locations_visited") ?? false)) {
      Future.delayed(const Duration(seconds: 1), () {
        prefs!.setBool("locations_visited", true);
        Helper.of(context).showHintDialog(Helper.homeHelp());
      });
    }
  }

  void _onRefresh() async {
    try {
      await _getData();
    } catch (e) {
      print(e.toString());
    }

    _refreshController.refreshCompleted();
  }

  Future<void> _getData() async {
    var futures = <Future>[];
    futures.add(getMyLocations());
    futures.add(getTrainerLocations());
    await Future.wait(futures);
  }

  Future<void> getTrainerLocations() async {
    await location_repo.getLocations(null);
    if (location_repo.createdId != -1) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        Scrollable.ensureVisible(focusKey.currentContext!);
        location_repo.createdId = -1;
      });
    }
  }

  Future<void> getMyLocations() async {
    await _con.getMyLocations();
  }

  Future<void> _showMyDialog(int? locationId) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.appDialogTitleConfirmation),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations
                    .of(context)
                    !.locationRemoveLocationConfirmText), // 'Are you sure to remove this location?'
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.appButtonOk), // Ok
              onPressed: () async {
                Navigator.of(context).pop();
                if (await _con.deleteLocation(locationId)) {
                  setState(() => locations = locations
                      .where((lo) => lo.locationId != locationId)
                      .toList());
                }
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.appButtonCancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void deleteLocation(int? locationId) {
    _showMyDialog(locationId);
  }

  Widget _trainerLocationList() {
    return SingleChildScrollView(
      child: Column(
          children: locations
              .where((location) =>
                  location.name!.contains(locationSearchText.toLowerCase()))
              .map((location) => MemberLocationWidget(
                    key: location.locationId == location_repo.createdId
                        ? focusKey
                        : Key(location.locationId.toString()),
                    location: location,
                    onEdit: () {
                      Navigator.of(context)
                          .pushNamed('/EditLocation', arguments: location)
                          .then((value) {});
                    },
                    onDelete: () {
                      deleteLocation(location.locationId);
                    },
                  ))
              .toList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacementNamed('/Home');
        return true;
      },
      child: Scaffold(
        key: _con.scaffoldKey,
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.home, color: Theme.of(context).primaryColor),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/Home');
            },
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).accentColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.locationTitle, // "Locations",
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
            child: DefaultTabController(
              length: 2,
              child: Scaffold(
                body: Column(
                  children: [
                    if (!isFetching)
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                        ),
                        child: TabBar(
                          labelColor: Theme.of(context).accentColor,
                          unselectedLabelColor: Theme.of(context).hintColor,
                          tabs: [
                            Tab(
                                child: Text(AppLocalizations
                                    .of(context)
                                    !.locationTabMember)), // 'Member'
                            Tab(
                                child: Text(AppLocalizations
                                    .of(context)
                                    !.locationTabTrainer)), // 'Trainer'
                          ],
                        ),
                      ),
                    if (!isFetching)
                      Expanded(
                        child: Container(
                          padding:
                              EdgeInsets.only(left: 15, right: 15, top: 15),
                          child: TabBarView(
                            children: [
                              Stack(
                                children: [
                                  Column(
                                    children: [
                                      TextFormField(
                                        onChanged: (txt) {
                                          setState(
                                              () => myLocationSearchText = txt);
                                        },
                                        decoration: Helper.of(context)
                                            .textInputDecoration(null,
                                                AppLocalizations.of(context)!.appInputSearch,
                                                prefixIcon: Icon(Icons.search,
                                                    color: Theme.of(context)
                                                        .hintColor)),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: myLocations
                                                .where((location) => location
                                                    .name!
                                                    .toLowerCase()
                                                    .contains(
                                                        myLocationSearchText
                                                            .toLowerCase()))
                                                .map((location) =>
                                                    MemberLocationWidget(
                                                      location: location,
                                                    ))
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                      left: 0,
                                      bottom: 20,
                                      child: HelpButtonWidget(
                                        showHelpDialog: () => Helper.of(context)
                                            .showHintDialog(Helper.homeHelp()),
                                        color: Theme.of(context).accentColor,
                                      ))
                                ],
                              ),
                              Stack(
                                children: [
                                  Column(
                                    children: [
                                      TextFormField(
                                        onChanged: (txt) {
                                          setState(
                                              () => locationSearchText = txt);
                                        },
                                        decoration: Helper.of(context)
                                            .textInputDecoration(null,
                                                AppLocalizations.of(context)!.appInputSearch,
                                                prefixIcon: Icon(Icons.search,
                                                    color: Theme.of(context)
                                                        .hintColor)),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Expanded(
                                        child: _trainerLocationList(),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                      right: 0,
                                      bottom: 20,
                                      child: InkWell(
                                        child: Icon(
                                          Icons.add_circle_rounded,
                                          size: 70,
                                          color: Theme.of(context).accentColor,
                                        ),
                                        onTap: () {
                                          Navigator.of(context)
                                              .pushNamed('/CreateLocation')
                                              .then((value) {});
                                        },
                                      )),
                                  Positioned(
                                      left: 0,
                                      bottom: 20,
                                      child: HelpButtonWidget(
                                        showHelpDialog: () => Helper.of(context)
                                            .showHintDialog(Helper.homeHelp()),
                                        color: Theme.of(context).accentColor,
                                      ))
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (isFetching)
                      Expanded(
                          child: Center(child: CircularProgressIndicator())),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
