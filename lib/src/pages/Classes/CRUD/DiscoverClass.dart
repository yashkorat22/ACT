import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../controllers/class_controller.dart';
import '../../../elements/DrawerWidget.dart';
import '../../../elements/DiscoveredClassWidget.dart';

import '../../../repository/user_repository.dart' as user_repo;
import '../../../models/discoveredClass.dart';

class DiscoverClassWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  DiscoverClassWidget({Key? key, this.parentScaffoldKey}) : super(key: key);
  @override
  _DiscoverClassWidgetState createState() => _DiscoverClassWidgetState();
}

class _DiscoverClassWidgetState extends StateMVC<DiscoverClassWidget> {
  late ClassController _con;
  List<DiscoveredClass> discoveredClasses = [];
  bool isFetching = false;
  bool isTrainingClassFetching = false;
  bool isMemberClassFetching = false;
  int? societyId;
  String searchText = '';

  final focusKeyMember = new GlobalKey();
  final focusKeyTraining = new GlobalKey();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  _DiscoverClassWidgetState() : super(ClassController()) {
    _con = controller as ClassController;
    societyId = user_repo.currentUserSocieties.value
        .firstWhere((so) => so.isPrimary == true)
        .id;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initData();
  }

  void _initData() async {
    setState(() => isFetching = true);
    await _getData();
    setState(() => isFetching = false);
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
    futures.add(discoverClasses());
    await Future.wait(futures);
  }

  Future<void> discoverClasses() async {
    final _discoveredClasses = await _con.discoverClasses();
    setState(() {
      discoveredClasses = _discoveredClasses;
    });
  }

  Future<void> _showDeleteTrainingClassDialog(int classId) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text( AppLocalizations.of(context)!.appDialogTitleConfirmation ),              // Confirmation
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text( AppLocalizations.of(context)!.classRemoveClassConfirmText ),              // Are you sure to delete this class
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text( AppLocalizations.of(context)!.appButtonYes ),                        // Yes
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text( AppLocalizations.of(context)!.appButtonCancel ),                     // Cancel
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void deleteTrainingClass(int classId) {
    _showDeleteTrainingClassDialog(classId);
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
        drawer: DrawerWidget(),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/Home');
                },
                icon: Icon(
                  Icons.home,
                  size: 26.0,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).accentColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.classDiscoverClasses,                                 // 'Discover Classes',
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
          child: isFetching
              ? Center(child: CircularProgressIndicator())
              : Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextFormField(
                        onChanged: (txt) {
                          setState(() => searchText = txt);
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          hintText: AppLocalizations.of(context)!.appInputSearch,               // "Search...",
                          hintStyle: TextStyle(
                              color:
                                  Theme.of(context).hintColor.withOpacity(0.5)),
                          prefixIcon: Icon(Icons.search,
                              color: Theme.of(context).hintColor),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: discoveredClasses
                                .where((classInfo) =>
                                    classInfo.className!
                                        .toLowerCase()
                                        .contains(searchText.toLowerCase()) ||
                                    (classInfo.ownerFirstName! +
                                            ' ' +
                                            classInfo.ownerLastName!)
                                        .toLowerCase()
                                        .contains(searchText.toLowerCase()))
                                .map(
                                  (classInfo) => DiscoveredClassWidget(
                                    classInfo: classInfo,
                                    onRequest: () async {
                                      final int? newApplicationId =
                                          await _con.requestApplication(
                                        classInfo.societyId,
                                        classInfo.classId,
                                      );
                                      discoveredClasses =
                                          discoveredClasses.map((item) {
                                        if (item.classId != classInfo.classId)
                                          return item;
                                        item.classApplicationId =
                                            newApplicationId;
                                        return item;
                                      }).toList();
                                      setState(() {});
                                    },
                                    onRetract: () async {
                                      final result = await _con.cancelApplication(
                                        classInfo.societyId,
                                        classInfo.classId,
                                        classInfo.classApplicationId,
                                      );
                                      if (!result) return;
                                      discoveredClasses =
                                          discoveredClasses.map((item) {
                                        if (item.classId != classInfo.classId)
                                          return item;
                                        item.classApplicationId = 0;
                                        return item;
                                      }).toList();
                                      setState(() {});
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
