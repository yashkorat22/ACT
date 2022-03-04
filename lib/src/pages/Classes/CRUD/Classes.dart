import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../controllers/class_controller.dart';

import '../../../elements/DrawerWidget.dart';
import '../../../elements/MemberClassWidget.dart';
import '../../../elements/TrainingClassWidget.dart';
import '../../../elements/HelpButtonWidget.dart';

import '../../../models/memberClass.dart';
import '../../../models/trainingClass.dart';

import '../../../helpers/helper.dart';

import '../../../repository/user_repository.dart' as user_repo;
import '../../../repository/class_repository.dart' as class_repo;

class ClassesWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  ClassesWidget({Key? key, this.parentScaffoldKey}) : super(key: key);
  @override
  _ClassesWidgetState createState() => _ClassesWidgetState();
}

class _ClassesWidgetState extends StateMVC<ClassesWidget> {
  late ClassController _con;
  List<MemberClass> memberClasses = [];
  List<TrainingClass> trainingClasses = [];
  bool isFetching = false;
  bool isTrainingClassFetching = false;
  bool isMemberClassFetching = false;
  int? societyId;
  String searchText = '';

  final focusKeyMember = new GlobalKey();
  final focusKeyTraining = new GlobalKey();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  _ClassesWidgetState() : super(ClassController()) {
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
    class_repo.createdTrainingClassId.addListener(() async {
      if (class_repo.createdTrainingClassId.value == -1) return;
      setState(() => isTrainingClassFetching = true);
      await getTrainingClasses();
      setState(() => isTrainingClassFetching = false);
    });
    class_repo.deletedTrainingClassId.addListener(() {
      setState(() {
        trainingClasses.removeWhere(
            (c) => c.id == class_repo.deletedTrainingClassId.value);
        trainingClasses = List.from(trainingClasses);
        class_repo.deletedTrainingClassId.value = -1;
      });
    });
    SharedPreferences.getInstance().then((instance) {
      if (!(instance.getBool("classes_visited") ?? false)) {
        Future.delayed(const Duration(seconds: 1), () {
          instance.setBool("classes_visited", true);
          Helper.of(context).showHintDialog(Helper.homeHelp());
        });
      }
    });
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
    futures.add(getMemberClasses());
    futures.add(getTrainingClasses());
    await Future.wait(futures);
  }

  Future<void> getTrainingClasses() async {
    final _trainingClasses = await _con.getTrainingClasses();
    setState(() {
      trainingClasses = _trainingClasses;
    });
    if (class_repo.createdTrainingClassId.value != -1) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (focusKeyTraining.currentContext != null) {
          Scrollable.ensureVisible(focusKeyTraining.currentContext!);
        }
        class_repo.createdTrainingClassId.value = -1;
      });
    }
  }

  Future<void> getMemberClasses() async {
    final _memberClasses = await _con.getMemberClasses();
    setState(() {
      memberClasses = _memberClasses;
    });
    // if (class_repo.createdMemberClassId != -1) {
    //   Future.delayed(const Duration(milliseconds: 1000), () {
    //     Scrollable.ensureVisible(focusKeyMember.currentContext);
    //     class_repo.createdMemberClassId = -1;
    //   });
    // }
  }

  Future<void> _showDeleteTrainingClassDialog(int? classId) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text( AppLocalizations.of(context)!.appDialogTitleConfirmation ),              // Confirmation
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text( AppLocalizations.of(context)!.classRemoveClassConfirmText ),              // 'Are you sure to delete this class?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text( AppLocalizations.of(context)!.appButtonYes ),                        // Yes
              onPressed: () async {
                Navigator.of(context).pop();
                if (await _con.deleteTrainingClass(classId)) {
                  setState(() {
                    trainingClasses
                        .removeWhere((classInfo) => classInfo.id == classId);
                    trainingClasses = List.from(trainingClasses);
                  });
                }
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

  void deleteTrainingClass(int? classId) {
    _showDeleteTrainingClassDialog(classId);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(memberClasses
        .where((classInfo) => classInfo
        .className!
        .toLowerCase()
        .contains(searchText
        .toLowerCase())).toString());
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacementNamed('/Home');
        return true;
      },
      child: Scaffold(
        key: _con.scaffoldKey,
        drawer: DrawerWidget(),
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
            AppLocalizations.of(context)!.classTitle,                                           // 'Classes',
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
                            Tab(child: Text( AppLocalizations.of(context)!.classTabMember )),   // Member
                            Tab(child: Text( AppLocalizations.of(context)!.classTabTrainer )),  // Trainer
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
                                          setState(() => searchText = txt);
                                        },
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          hintText: AppLocalizations.of(context)!.appInputSearch, //"Search...",
                                          hintStyle: TextStyle(
                                              color: Theme.of(context)
                                                  .hintColor
                                                  .withOpacity(0.5)),
                                          prefixIcon: Icon(Icons.search,
                                              color:
                                                  Theme.of(context).hintColor),
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
                                            children: memberClasses
                                                .where((classInfo) => classInfo
                                                    .className!
                                                    .toLowerCase()
                                                    .contains(searchText
                                                        .toLowerCase()))
                                                .map(
                                                  (classInfo) =>
                                                      MemberClassWidget(
                                                    key: classInfo.classMemberId ==
                                                            class_repo
                                                                .createdMemberClassId
                                                                .value
                                                        ? focusKeyMember
                                                        : Key(classInfo.classMemberId.toString()),
                                                    classInfo: classInfo,
                                                    onDelete: () {},
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                      right: 0,
                                      bottom: 20,
                                      child: InkWell(
                                        child: Icon(
                                          Icons.search,
                                          size: 70,
                                          color: Theme.of(context).accentColor,
                                        ),
                                        onTap: () {
                                          Navigator.of(context)
                                              .pushNamed('/DiscoverClass');
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
                              if (isTrainingClassFetching)
                                Center(child: CircularProgressIndicator())
                              else
                                Stack(
                                  children: [
                                    Column(
                                      children: [
                                        TextFormField(
                                          onChanged: (txt) {
                                            setState(() => searchText = txt);
                                          },
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 10),
                                            hintText: AppLocalizations.of(context)!.appInputSearch,   //"Search...",
                                            hintStyle: TextStyle(
                                                color: Theme.of(context)
                                                    .hintColor
                                                    .withOpacity(0.5)),
                                            prefixIcon: Icon(Icons.search,
                                                color: Theme.of(context)
                                                    .hintColor),
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
                                                children: trainingClasses
                                                    .where((classInfo) =>
                                                        classInfo.name!
                                                            .toLowerCase()
                                                            .contains(searchText
                                                                .toLowerCase()))
                                                    .map(
                                                      (classInfo) =>
                                                          TrainingClassWidget(
                                                        key: classInfo.id ==
                                                                class_repo
                                                                    .createdTrainingClassId
                                                                    .value
                                                            ? focusKeyTraining
                                                            : Key(classInfo.id
                                                                .toString()),
                                                        classInfo: classInfo,
                                                        onDelete: () {
                                                          deleteTrainingClass(
                                                              classInfo.id);
                                                        },
                                                      ),
                                                    )
                                                    .toList()),
                                          ),
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
                                            color:
                                                Theme.of(context).accentColor,
                                          ),
                                          onTap: () {
                                            Navigator.of(context).pushNamed(
                                                '/CreateTrainingClass');
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
