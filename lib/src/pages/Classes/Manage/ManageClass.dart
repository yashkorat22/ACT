import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../controllers/class_manage_controller.dart';

import './EventCalendarWidget.dart';

import '../../../elements/ClassMemberWidget.dart';
import '../../../elements/ClassEventWidget.dart';

import '../../../repository/class_repository.dart' as class_repo;
import '../../../models/classMember.dart';
import '../../../models/classEvent.dart';

class ManageClass extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  ManageClass({Key? key, this.parentScaffoldKey}) : super(key: key);
  @override
  _ManageClassState createState() => _ManageClassState();
}

class _ManageClassState extends StateMVC<ManageClass> {
  late ClassMemberController _con;
  List<ClassMember> classMembers = [];
  List<ClassEvent> classEvents = [];
  List<ClassEvent> calendarEvents = [];
  bool isFetching = false;
  bool isClassMemberFetching = false;
  bool isClassEventFetching = false;
  String searchTextEvent = '';
  String searchTextContributor = '';
  int? classId;
  DateTime? firstDate, lastDate;

  final focusKey = new GlobalKey();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  _ManageClassState() : super(ClassMemberController()) {
    _con = controller as ClassMemberController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initData();
    debugPrint(class_repo.editId.toString());
    classId = class_repo.editId;

    class_repo.createdClassEventId.addListener(() async {
      if (class_repo.createdClassEventId.value != -1) {
        setState(() => isClassEventFetching = true);
        await getClassEvents();
        setState(() => isClassEventFetching = false);
        Future.delayed(const Duration(milliseconds: 1000), () {
          Scrollable.ensureVisible(focusKey.currentContext!);
          class_repo.createdClassEventId.value = -1;
        });
      }
    });

    class_repo.deletedClassEventId.addListener(() {
      setState(() {
        classEvents.removeWhere(
            (c) => c.eventId == class_repo.deletedClassEventId.value);
        classEvents = List.from(classEvents);
        class_repo.deletedClassEventId.value = -1;
      });
    });

    class_repo.calendarEvents.addListener(() {
      setState(() {
        calendarEvents = class_repo.calendarEvents.value;
      });
    });
  }

  void _initData() async {
    setState(() => isFetching = true);
    await _getData();
    setState(() => isFetching = false);
  }

  Future<void> getCalendarEvents({DateTime? first, DateTime? last}) async {
    try {
      if (first == null) {
        if (firstDate == null) {
          firstDate = DateTime(DateTime.now().year, DateTime.now().month)
              .subtract(Duration(days: 6));
        }
      } else {
        firstDate = first;
      }
      if (last == null) {
        if (lastDate == null) {
          lastDate = DateTime(DateTime.now().year, DateTime.now().month)
              .add(Duration(days: 36));
        }
      } else {
        lastDate = last;
      }
      await _con.getCalendarEvents(firstDate, lastDate);
    } catch (e) {
      print(e.toString());
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
    futures.add(getClassMembers());
    futures.add(getClassEvents());
    await Future.wait(futures);
  }

  Future<void> getClassMembers() async {
    final _classMembers = await _con.getClassMembers();
    setState(() {
      classMembers = _classMembers;
    });
  }

  Future<void> _getClassEvents() async {
    final _classEvents = await _con.getClassEvents();
    setState(() {
      classEvents = _classEvents;
    });
  }

  Future<void> getClassEvents() async {
    var futures = <Future>[];
    futures.add(_getClassEvents());
    futures.add(getCalendarEvents());
    await Future.wait(futures);
  }

  Future<void> admissClassMember(int memberId) async {
    final isSuccess = await _con.admissClassMember(classId, memberId);
    if (isSuccess) {
      final memberIndex =
          classMembers.indexWhere((mem) => mem.memberId == memberId);
      if (memberIndex != -1) {
        classMembers[memberIndex].isClassMember = true;
        setState(() {
          classMembers = classMembers;
        });
      }
    }
  }

  Future<void> dismissClassMember(int memberId) async {
    final isSuccess = await _con.dismissClassMember(classId, memberId);
    if (isSuccess) {
      final memberIndex =
          classMembers.indexWhere((mem) => mem.memberId == memberId);
      if (memberIndex != -1) {
        classMembers[memberIndex].isClassMember = false;
        setState(() {
          classMembers = classMembers;
        });
      }
    }
  }

  Future<void> handleDismissClassMember(int memberId) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text( AppLocalizations.of(context)!.appDialogTitleConfirmation ),              // Confirmation
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text( AppLocalizations.of(context)!.classDismissMember ),                       //'Are you sure to dismiss this member?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text( AppLocalizations.of(context)!.appButtonYes ),                        // Yes
              onPressed: () {
                Navigator.of(context).pop();
                dismissClassMember(memberId);
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


  Future<void> deleteClassEvent(int eventId) async {
    final isSuccess = await _con.deleteClassEvent(eventId);
    if (isSuccess) {
      setState(() {
        classEvents =
            classEvents.where((event) => event.eventId != eventId).toList();
      });
    }
  }

  Future<void> handleDeleteEvent(int eventId) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text( AppLocalizations.of(context)!.appDialogTitleConfirmation ),              // Confirmation
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text( AppLocalizations.of(context)!.eventRemoveEventConfirmText ),              //'Are you sure to delete this event?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text( AppLocalizations.of(context)!.appButtonYes ),                        // Yes
              onPressed: () {
                Navigator.of(context).pop();
                deleteClassEvent(eventId);
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

  Future<void> scheduleCalendarEvent(ClassEvent event) async {
    final isSuccess = await _con.scheduleCalendarEvent(event);
    debugPrint(isSuccess.toString());
    if (isSuccess) {
      await getCalendarEvents();
      _con.hideLoader();
    }
  }

  Future<void> cancelCalendarEvent(ClassEvent event) async {
    final isSuccess = await _con.cancelCalendarEvent(event);
    debugPrint(isSuccess.toString());
    if (isSuccess) {
      await getCalendarEvents();
      _con.hideLoader();
    }
  }

  Widget _buildContributorList() {
    return Stack(
      children: [
        Column(
          children: [
            TextFormField(
              onChanged: (txt) {
                setState(() => searchTextContributor = txt);
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                hintText: AppLocalizations.of(context)!.appInputSearch,                         // Search...
                hintStyle: TextStyle(
                    color: Theme.of(context).hintColor.withOpacity(0.5)),
                prefixIcon:
                    Icon(Icons.search, color: Theme.of(context).hintColor),
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).focusColor.withOpacity(0.2))),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).focusColor.withOpacity(0.5))),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).focusColor.withOpacity(0.2))),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: classMembers
                      .where((memberInfo) => (memberInfo.memberFirstName! +
                              ' ' +
                              memberInfo.memberLastName!)
                          .toLowerCase()
                          .contains(searchTextContributor.toLowerCase()))
                      .map(
                        (memberInfo) => ClassMemberWidget(
                          key: Key(memberInfo.memberId.toString()),
                          member: memberInfo,
                          onAdmiss: admissClassMember,
                          onDismiss: handleDismissClassMember,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClassEventList() {
    return Stack(
      children: [
        Column(
          children: [
            TextFormField(
              onChanged: (txt) {
                setState(() => searchTextEvent = txt);
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                hintText: AppLocalizations.of(context)!.appInputSearch,                         // Search...
                hintStyle: TextStyle(
                    color: Theme.of(context).hintColor.withOpacity(0.5)),
                prefixIcon:
                    Icon(Icons.search, color: Theme.of(context).hintColor),
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).focusColor.withOpacity(0.2))),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).focusColor.withOpacity(0.5))),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).focusColor.withOpacity(0.2))),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: classEvents
                      .where((eventInfo) => eventInfo.eventName!
                          .toLowerCase()
                          .contains(searchTextEvent.toLowerCase()))
                      .map(
                        (eventInfo) => ClassEventWidget(
                          key: class_repo.createdClassEventId.value ==
                                  eventInfo.eventId
                              ? focusKey
                              : Key(eventInfo.eventId.toString()),
                          event: eventInfo,
                          onDelete: handleDeleteEvent,
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
              Icons.add_circle_rounded,
              size: 70,
              color: Theme.of(context).accentColor,
            ),
            onTap: () {
              class_repo.editEvent = null;
              Navigator.of(context).pushNamed('/CreateClassEvent');
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return true;
      },
      child: Scaffold(
        key: _con.scaffoldKey,
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
            AppLocalizations.of(context)!.classManageTitle,                                     // Manage Class
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
            length: 3,
            child: Column(
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
                          child: Text(
                            AppLocalizations.of(context)!.classTabCalendar,                     // Calendar
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Tab(
                          child: Text(
                            AppLocalizations.of(context)!.classTabElements,                     // Elements
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Tab(
                          child: Text(
                            AppLocalizations.of(context)!.classTabContributors,                 // Contributors
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (!isFetching)
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 15, right: 15, top: 15),
                      child: TabBarView(
                        children: [
                          EventCalendarWidget(
                            events: calendarEvents,
                            updateMonth: getCalendarEvents,
                            cancelEvent: cancelCalendarEvent,
                            scheduleEvent: scheduleCalendarEvent,
                          ),
                          isClassEventFetching
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : _buildClassEventList(),
                          _buildContributorList(),
                        ],
                      ),
                    ),
                  ),
                if (isFetching)
                  Expanded(child: Center(child: CircularProgressIndicator())),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
