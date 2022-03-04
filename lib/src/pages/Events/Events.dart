import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/event_controller.dart';

import '../Classes/Manage/EventCalendarWidget.dart';
import './MemberEventCalendarWidget.dart';
import '../../elements/HelpButtonWidget.dart';

import '../../models/classEvent.dart';
import '../../models/myEvent.dart';

import '../../helpers/helper.dart';

import '../../repository/class_repository.dart' as class_repo;
import '../../repository/user_repository.dart' as user_repo;
import '../../repository/location_repository.dart' as location_repo;

class EventsWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  EventsWidget({Key? key, this.parentScaffoldKey}) : super(key: key);
  @override
  _EventsWidgetState createState() => _EventsWidgetState();
}

class _EventsWidgetState extends StateMVC<EventsWidget> {
  late EventsController _con;
  List<ClassEvent> trainerEvents = [];
  List<MyEvent> myEvents = [];
  bool isFetching = false;
  bool isClassMemberFetching = false;
  bool isClassEventFetching = false;
  String searchTextEvent = '';
  String searchTextContributor = '';
  DateTime? trainerFirstDate, trainerLastDate;
  DateTime? memberFirstDate, memberLastDate;

  final focusKey = new GlobalKey();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  _EventsWidgetState() : super(EventsController()) {
    _con = controller as EventsController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initData();
    debugPrint(class_repo.editId.toString());
    class_repo.editId = -1;

    class_repo.calendarEvents.addListener(() {
      setState(() {
        trainerEvents = class_repo.calendarEvents.value;
      });
    });

    user_repo.myEvents.addListener(() {
      setState(() {
        myEvents = user_repo.myEvents.value;
      });
    });

    SharedPreferences.getInstance().then((instance) {
      if (!(instance.getBool("events_visited") ?? false)) {
        Future.delayed(const Duration(seconds: 1), () {
          instance.setBool("events_visited", true);
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

  Future<void> getTrainerEvents({DateTime? first, DateTime? last}) async {
    try {
      if (first == null) {
        if (trainerFirstDate == null) {
          trainerFirstDate = DateTime(DateTime.now().year, DateTime.now().month)
              .subtract(Duration(days: 6));
        }
      } else {
        trainerFirstDate = first;
      }
      if (last == null) {
        if (trainerLastDate == null) {
          trainerLastDate = DateTime(DateTime.now().year, DateTime.now().month)
              .add(Duration(days: 36));
        }
      } else {
        trainerLastDate = last;
      }
      await _con.getTrainerEvents(trainerFirstDate, trainerLastDate);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> getMemberEvents({DateTime? first, DateTime? last}) async {
    try {
      if (first == null) {
        if (memberFirstDate == null) {
          memberFirstDate = DateTime(DateTime.now().year, DateTime.now().month)
              .subtract(Duration(days: 6));
        }
      } else {
        memberFirstDate = first;
      }
      if (last == null) {
        if (memberLastDate == null) {
          memberLastDate = DateTime(DateTime.now().year, DateTime.now().month)
              .add(Duration(days: 36));
        }
      } else {
        memberLastDate = last;
      }
      await _con.getMemberEvents(memberFirstDate, memberLastDate);
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
    futures.add(getMemberEvents());
    futures.add(getTrainerEvents());
    futures.add(location_repo.getLocations(null));
    futures.add(location_repo.fetchMyLocations());
    await Future.wait(futures);
  }

  Future<void> scheduleCalendarEvent(ClassEvent event) async {
    final isSuccess = await _con.scheduleCalendarEvent(event);
    if (isSuccess) {
      await getTrainerEvents();
      _con.hideLoader();
    }
  }

  Future<void> cancelCalendarEvent(ClassEvent event) async {
    final isSuccess = await _con.cancelCalendarEvent(event);
    if (isSuccess) {
      await getTrainerEvents();
      _con.hideLoader();
    }
  }

  Future<void> registerMyCalendarEvent(MyEvent event) async {
    final isSuccess = await _con.registerCalendarEvent(event);
    if (isSuccess) {
      await getMemberEvents();
      _con.hideLoader();
    }
  }

  Future<void> cancelMyCalendarEvent(MyEvent event) async {
    final isSuccess = await _con.cancelMyCalendarEvent(event);
    if (isSuccess) {
      await getMemberEvents();
      _con.hideLoader();
    }
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/Home');
            },
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).accentColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.eventTitle,                                           // Events
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
                            AppLocalizations.of(context)!.eventTabMember,                       // Member
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Tab(
                          child: Text(
                            AppLocalizations.of(context)!.eventTabTrainer,                       // Trainer
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
                          Stack(
                            children: [
                              MemberEventCalendarWidget(
                                events: myEvents,
                                updateMonth: getMemberEvents,
                                cancelEvent: cancelMyCalendarEvent,
                                registerEvent: registerMyCalendarEvent,
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
                              EventCalendarWidget(
                                events: trainerEvents,
                                updateMonth: getTrainerEvents,
                                cancelEvent: cancelCalendarEvent,
                                scheduleEvent: scheduleCalendarEvent,
                                showAddButton: false,
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
                  Expanded(child: Center(child: CircularProgressIndicator())),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
