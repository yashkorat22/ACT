import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/member_controller.dart';
import '../../elements/DrawerWidget.dart';
import '../../elements/MemberWidget.dart';
import '../../elements/ApplicantWidget.dart';
import '../../elements/HelpButtonWidget.dart';

import '../../helpers/helper.dart';

import '../../models/member.dart';
import '../../models/applicant.dart';

import '../../repository/user_repository.dart' as user_repo;
import '../../repository/member_repository.dart' as member_repo;

class MembersWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  MembersWidget({Key? key, this.parentScaffoldKey}) : super(key: key);
  @override
  _MembersWidgetState createState() => _MembersWidgetState();
}

class _MembersWidgetState extends StateMVC<MembersWidget> {
  late MemberController _con;
  List<Member> members = [];
  List<Applicant> applicants = [];
  bool isFetching = false;
  int? societyId;
  String memberSearchText = '';
  String applicantSearchText = '';

  final focusKey = new GlobalKey();
  SharedPreferences? prefs;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  _MembersWidgetState() : super(MemberController()) {
    _con = controller as MemberController;
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
    await Future.wait([
      SharedPreferences.getInstance().then((instance) => prefs = instance),
      _getData(),
    ]);
    setState(() => isFetching = false);
    if (!(prefs!.getBool("members_visited") ?? false)) {
      Future.delayed(const Duration(seconds: 1), () {
        prefs!.setBool("members_visited", true);
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
    futures.add(getMembers());
    futures.add(getApplicants());
    await Future.wait(futures);
  }

  Future<void> getMembers() async {
    final _members = await _con.getMembers();
    setState(() => members = _members);
    if (member_repo.createdId != -1) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        Scrollable.ensureVisible(focusKey.currentContext!);
        member_repo.createdId = -1;
      });
    }
  }

  Future<void> getApplicants() async {
    final _applicants = await _con.getApplicants();
    setState(() => applicants = _applicants);
  }

  Future<void> _showMyDialog(int? memberId) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text( AppLocalizations.of(context)!.appDialogTitleConfirmation ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text( AppLocalizations.of(context)!.memberRemoveMemberConfirmText ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text( AppLocalizations.of(context)!.appButtonOk ),                         // Ok
              onPressed: () async {
                Navigator.of(context).pop();
                if (await _con.deleteMember(memberId)) {
                  setState(() => members =
                      members.where((mem) => mem.id != memberId).toList());
                }
              },
            ),
            TextButton(
              child: Text( AppLocalizations.of(context)!.appButtonCancel ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void deleteMember(int? memberId) {
    _showMyDialog(memberId);
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
            AppLocalizations.of(context)!.memberTitle,
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
                            Tab(child: Text( AppLocalizations.of(context)!.memberTabMyMembers )),
                            Tab(child: Text( AppLocalizations.of(context)!.memberTabMyApplicants )),
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
                                              () => memberSearchText = txt);
                                        },
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          hintText: AppLocalizations.of(context)!.appInputSearch,                         // Search...
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
                                              children: members
                                                  .where((mem) =>
                                                      mem.firstName!
                                                          .toLowerCase()
                                                          .contains(memberSearchText
                                                              .toLowerCase()) ||
                                                      mem.lastName!
                                                          .toLowerCase()
                                                          .contains(
                                                              memberSearchText
                                                                  .toLowerCase()))
                                                  .map((mem) => MemberWidget(
                                                      key: mem.id ==
                                                              member_repo
                                                                  .createdId
                                                          ? focusKey
                                                          : Key(mem.id
                                                              .toString()),
                                                      member: mem,
                                                      onDelete: () {
                                                        deleteMember(mem.id);
                                                      }))
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
                                          color: Theme.of(context).accentColor,
                                        ),
                                        onTap: () {
                                          Navigator.of(context)
                                              .pushNamed('/CreateMember');
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
                              Stack(
                                children: [
                                  Column(
                                    children: [
                                      TextFormField(
                                        onChanged: (txt) {
                                          setState(() => applicantSearchText = txt);
                                        },
                                        decoration: InputDecoration(
                                          contentPadding:
                                              EdgeInsets.symmetric(horizontal: 10),
                                          hintText: AppLocalizations.of(context)!.appInputSearch,     // Search...
                                          hintStyle: TextStyle(
                                              color: Theme.of(context)
                                                  .hintColor
                                                  .withOpacity(0.5)),
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
                                            children: applicants
                                                .where((applicant) =>
                                                    applicant.firstName!
                                                        .toLowerCase()
                                                        .contains(
                                                            applicantSearchText
                                                                .toLowerCase()) ||
                                                    applicant.lastName!
                                                        .toLowerCase()
                                                        .contains(
                                                            applicantSearchText
                                                                .toLowerCase()))
                                                .map((applicant) => ApplicantWidget(
                                                      applicantInfo: applicant,
                                                      onAccept: () async {
                                                        if (await _con
                                                            .acceptApplication(
                                                                applicant
                                                                    .applicationId)) {
                                                          applicants.removeWhere((item) =>
                                                              item.applicationId ==
                                                              applicant
                                                                  .applicationId);
                                                          setState(() {});
                                                        }
                                                      },
                                                      onDecline: () async {
                                                        if (await _con
                                                            .declineApplication(
                                                            applicant
                                                                .applicationId)) {
                                                          applicants.removeWhere((item) =>
                                                          item.applicationId ==
                                                              applicant
                                                                  .applicationId);
                                                          setState(() {});
                                                        }
                                                      },
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
