import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/services.dart';

import '../../../elements/CustomDatePicker.dart';
import '../../../elements/CustomTimePicker.dart';
import '../../../elements/BlockButtonWidget.dart';
import '../../../elements/EventParticipantWidget.dart';

import '../../../models/activity.dart';
import '../../../models/location.dart';
import '../../../models/eventStatus.dart';
import '../../../models/repetition.dart';
import '../../../models/classEvent.dart';
import '../../../models/eventParticipant.dart';

import '../../../controllers/calendar_event_controller.dart';

import '../../../repository/user_repository.dart' as user_repo;
import '../../../repository/class_repository.dart' as class_repo;
import '../../../repository/location_repository.dart' as location_repo;

class ManageCalendarEventWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;
  final ClassEvent? event;

  ManageCalendarEventWidget({Key? key, this.parentScaffoldKey, this.event})
      : super(key: key);
  @override
  _ManageCalendarEventWidgetState createState() =>
      _ManageCalendarEventWidgetState();
}

class _ManageCalendarEventWidgetState
    extends StateMVC<ManageCalendarEventWidget> {
  late CalendarEventDetailController _con;
  final List<DropdownMenuItem<String>> _maxParticipantList =
      List<DropdownMenuItem<String>>.generate(
    100,
    (i) => DropdownMenuItem<String>(
      value: i.toString(),
      child: Text(i == 0 ? 'Unlimited' : i.toString()),
    ),
  );

  List<Activity> activities = [];
  List<ActLocation> locations = [];
  List<EventStatus> eventStatus = [];
  List<Repetition> repetitions = [];

  List<EventParticipant> eventParticipants = [];

  String searchTextContributor = '';

  bool isFetching = true;

  _ManageCalendarEventWidgetState() : super(CalendarEventDetailController()) {
    _con = controller as CalendarEventDetailController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    activities = user_repo.activities.value;
    user_repo.activities.addListener(() {
      setState(() {
        activities = user_repo.activities.value;
      });
    });
    locations = location_repo.locations.value;
    location_repo.locations.addListener(() {
      setState(() {
        locations = location_repo.locations.value;
        _con.locationId = location_repo.locations.value.length - 1;
      });
    });
    eventStatus = user_repo.eventStatus.value;
    user_repo.eventStatus.addListener(() {
      setState(() {
        eventStatus = user_repo.eventStatus.value;
      });
    });
    repetitions = user_repo.repetitions.value;
    user_repo.repetitions.addListener(() {
      setState(() {
        repetitions = user_repo.repetitions.value;
      });
    });

    _con.calendarEvent = widget.event;
    _con.initData();
    initData();
  }

  Future<void> initData() async {
    await getEventParticipants();
    setState(() => isFetching = false);
  }

  Future<void> getEventParticipants() async {
    final _eventParticipants = await _con.getEventParticipants(
        widget.event!.eventId,
        widget.event!.classId,
        widget.event!.eventDateTimePlan);
    setState(() {
      eventParticipants = _eventParticipants;
    });
  }

  Future<void> _showMyDialog(int? classId) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text( AppLocalizations.of(context)!.appDialogTitleConfirmation ),              // Confirmation
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text( AppLocalizations.of(context)!.eventRemoveEventConfirmText ),                // 'Are you sure to delete this event?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text( AppLocalizations.of(context)!.appButtonYes ),                        // Yes
              onPressed: () {
                Navigator.of(context).pop();
                _con.deleteCalendarEvent();
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

  Future<void> _deleteReplacement() async {
    _showMyDialog(class_repo.editId);
  }

  Widget _buildEventInformationTab() {
    return Form(
      key: _con.formKey,
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 25, right: 25, top: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              TextFormField(
                controller: _con.classNameController,
                enabled: false,
                readOnly: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.eventClassName,                      // "Class Name",
                  labelStyle: TextStyle(color: Theme.of(context).accentColor),
                  filled: true,
                  fillColor: Theme.of(context).hintColor.withOpacity(0.05),
                  contentPadding: EdgeInsets.all(12),
                  hintStyle: TextStyle(
                      color: Theme.of(context).focusColor.withOpacity(0.7)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).focusColor.withOpacity(0.2))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).focusColor.withOpacity(0.5))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).focusColor.withOpacity(0.2))),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _con.eventNameController,
                enabled: false,
                readOnly: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.eventName,                           //"Event Name",
                  labelStyle: TextStyle(color: Theme.of(context).accentColor),
                  contentPadding: EdgeInsets.all(12),
                  filled: true,
                  fillColor: Theme.of(context).hintColor.withOpacity(0.05),
                  hintStyle: TextStyle(
                      color: Theme.of(context).focusColor.withOpacity(0.7)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).focusColor.withOpacity(0.2))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).focusColor.withOpacity(0.5))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).focusColor.withOpacity(0.2))),
                ),
              ),
              SizedBox(height: 10),
              GridView.count(
                  primary: false,
                  padding: const EdgeInsets.only(top: 5),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  childAspectRatio: 2.5,
                  children: <Widget>[
                    CustomDatePicker(
                      value: _con.planDate,
                      onChange: (value) {
                        setState(() {
                          _con.planDate = value;
                        });
                      },
                      label: AppLocalizations.of(context)!.eventPlannedDate,                    //"Planned Date",
                      disabled: true,
                    ),
                    CustomTimePicker(
                      controller: _con.planTimeController,
                      label: AppLocalizations.of(context)!.eventPlannedTime,                    //"Planned Time",
                      disabled: true,
                    ),
                  ]),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.eventActivity,                       //"Activity",
                  labelStyle: TextStyle(color: Theme.of(context).accentColor),
                  contentPadding: EdgeInsets.all(12),
                  hintStyle: TextStyle(
                      color: Theme.of(context).focusColor.withOpacity(0.7)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).focusColor.withOpacity(0.2))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).focusColor.withOpacity(0.5))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).focusColor.withOpacity(0.2))),
                ),
                value: activities.length > _con.activityId
                    ? activities[_con.activityId].name
                    : null,
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                onChanged: (String? newValue) {
                  setState(() {
                    _con.activityId = activities
                        .indexWhere((activity) => activity.name == newValue);
                  });
                },
                items: activities
                    .map<DropdownMenuItem<String>>((Activity activity) {
                  return DropdownMenuItem<String>(
                    value: activity.name,
                    child: Text(activity.name!),
                  );
                }).toList(),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.eventLocation,                 // "Location",
                        labelStyle:
                            TextStyle(color: Theme.of(context).accentColor),
                        contentPadding: EdgeInsets.all(12),
                        hintStyle: TextStyle(
                            color:
                                Theme.of(context).focusColor.withOpacity(0.7)),
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
                      value: _con.locationId != null &&
                              locations.length > _con.locationId!
                          ? locations[_con.locationId!].name
                          : null,
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                      onChanged: (String? newValue) {
                        setState(() {
                          _con.locationId = locations.indexWhere(
                              (activity) => activity.name == newValue);
                        });
                      },
                      items: locations
                          .map<DropdownMenuItem<String>>((ActLocation location) {
                        return DropdownMenuItem<String>(
                          value: location.name,
                          child: Text(location.name!),
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/CreateLocation');
                      },
                      padding:
                          EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                      color: Theme.of(context).accentColor,
                      shape: StadiumBorder(),
                      child: Text( AppLocalizations.of(context)!.appButtonNew,                  // New
                          style:
                              TextStyle(color: Theme.of(context).primaryColor)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.eventStatus,                         //"Status",
                  labelStyle: TextStyle(color: Theme.of(context).accentColor),
                  contentPadding: EdgeInsets.all(12),
                  hintStyle: TextStyle(
                      color: Theme.of(context).focusColor.withOpacity(0.7)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).focusColor.withOpacity(0.2))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).focusColor.withOpacity(0.5))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Theme.of(context).focusColor.withOpacity(0.2))),
                ),
                value: eventStatus.length > _con.statusId
                    ? eventStatus[_con.statusId].name
                    : null,
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                onChanged: (String? newValue) {
                  setState(() {
                    _con.statusId = eventStatus
                        .indexWhere((activity) => activity.name == newValue);
                  });
                },
                items: eventStatus
                    .map<DropdownMenuItem<String>>((EventStatus status) {
                  return DropdownMenuItem<String>(
                    value: status.name,
                    child: Text(status.name!),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              GridView.count(
                primary: false,
                padding: const EdgeInsets.only(top: 5),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 2,
                shrinkWrap: true,
                childAspectRatio: 2.5,
                children: <Widget>[
                  CustomDatePicker(
                    value: _con.replaceDate,
                    onChange: (value) {
                      setState(() {
                        _con.replaceDate = value;
                      });
                    },
                    label: AppLocalizations.of(context)!.eventReplaceDate,                      // "Replace Date",
                  ),
                  CustomTimePicker(
                    controller: _con.replaceTimeController,
                    label: AppLocalizations.of(context)!.eventReplaceTime,                      // "Replace Time",
                  ),
                  DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.eventDuration,                   //"Duration (min)",
                      labelStyle:
                          TextStyle(color: Theme.of(context).accentColor),
                      contentPadding: EdgeInsets.all(12),
                      hintStyle: TextStyle(
                          color: Theme.of(context).focusColor.withOpacity(0.7)),
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
                    value: _con.duration.toString(),
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    onChanged: (String? newValue) {
                      setState(() {
                        _con.duration = int.parse(newValue!);
                      });
                    },
                    items: List<DropdownMenuItem<String>>.generate(
                        120,
                        (i) => DropdownMenuItem<String>(
                              value: (i + 1).toString(),
                              child: Text((i + 1).toString()),
                            )),
                  ),
                  DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.eventMaxParticipants,            //"Max. Participants",
                      labelStyle:
                          TextStyle(color: Theme.of(context).accentColor),
                      contentPadding: EdgeInsets.all(12),
                      hintStyle: TextStyle(
                          color: Theme.of(context).focusColor.withOpacity(0.7)),
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
                    value: _con.maxParticipants.toString(),
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    onChanged: (String? newValue) {
                      setState(() {
                        _con.maxParticipants = int.parse(newValue!);
                      });
                    },
                    items: _maxParticipantList,
                  ),
                ],
              ),
              widget.event!.eventDateReplaceId != null &&
                      widget.event!.eventDateReplaceId! > 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          child: Text(
                            AppLocalizations.of(context)!.eventReplacementRemove,               // "Delete\nReplacement",
                            style: TextStyle(
                              color: Colors.red,
                              decoration: TextDecoration.underline,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.pressed))
                                    return Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.5);
                                  return Theme.of(context).primaryColor;
                                },
                              ),
                              minimumSize: MaterialStateProperty.all<Size>(
                                  Size(100, 40))),
                          onPressed: () {
                            _deleteReplacement();
                          },
                        ),
                        TextButton(
                          child: Text(
                            AppLocalizations.of(context)!.appButtonSave,                        // Save
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 18),
                          ),
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.pressed))
                                    return Theme.of(context)
                                        .accentColor
                                        .withOpacity(0.5);
                                  return Theme.of(context).accentColor;
                                },
                              ),
                              minimumSize: MaterialStateProperty.all<Size>(
                                  Size(100, 40))),
                          onPressed: () {
                            TextInput.finishAutofillContext(shouldSave: true);
                            _con.updateCalendarEvent();
                          },
                        ),
                      ],
                    )
                  : Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      child: BlockButtonWidget(
                        text: Text(
                          AppLocalizations.of(context)!.appButtonSave,                          // Save
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        color: Theme.of(context).accentColor,
                        onPressed: () {
                          TextInput.finishAutofillContext(shouldSave: true);
                          _con.updateCalendarEvent();
                        },
                      ),
                    ),
              SizedBox(
                  height: widget.event!.eventDateReplaceId != null &&
                          widget.event!.eventDateReplaceId! > 0
                      ? 20
                      : 50),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> admissEventParticipant(EventParticipant participantInfo) async {
    final result = await _con.admissEventParticipant(participantInfo);
    if (result != null) {
      final participantIndex = eventParticipants
          .indexWhere((p) => p.memberId == participantInfo.memberId);
      if (participantIndex != -1) {
        eventParticipants[participantIndex].participationStatusId =
            result['participation_status_id'];
        eventParticipants[participantIndex].participationStatusName =
            result['participation_status_name'];
        eventParticipants[participantIndex].participationId =
            result['participation_id'];
        setState(() {
          eventParticipants = eventParticipants;
        });
      }
    }
  }

  Future<void> dismissEventParticipant(participantInfo) async {
    final result = await _con.dismissEventParticipant(participantInfo);
    if (result != null) {
      final participantIndex = eventParticipants
          .indexWhere((p) => p.memberId == participantInfo.memberId);
      if (participantIndex != -1) {
        eventParticipants[participantIndex].participationId =
            result['participation_id'] != null ? result['participation_id'] : 0;
        eventParticipants[participantIndex].participationStatusId =
            result['participation_status_id'] != null
                ? result['participation_status_id']
                : 0;
        eventParticipants[participantIndex].participationStatusName =
            result['participation_status_name'] != null
                ? result['participation_status_name']
                : '';
        setState(() {
          eventParticipants = eventParticipants;
        });
      }
    }
  }

  Widget _buildContributorList() {
    return Stack(
      children: [
        isFetching
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  TextFormField(
                    onChanged: (txt) {
                      setState(() => searchTextContributor = txt);
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      hintText: AppLocalizations.of(context)!.appInputSearch,                   // "Search...",
                      hintStyle: TextStyle(
                          color: Theme.of(context).hintColor.withOpacity(0.5)),
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
                        children: eventParticipants
                            .where((participantInfo) => (participantInfo
                                        .memberFirstName! +
                                    ' ' +
                                    participantInfo.memberLastName!)
                                .toLowerCase()
                                .contains(searchTextContributor.toLowerCase()))
                            .map(
                              (participantInfo) => EventParticipantWidget(
                                key: Key(participantInfo.memberId.toString()),
                                participant: participantInfo,
                                onAdmiss: () =>
                                    admissEventParticipant(participantInfo),
                                onDismiss: () =>
                                    dismissEventParticipant(participantInfo),
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        key: _con.scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).accentColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.eventCalendarManageEvent,                             // 'Manage Calendar Event',
            style: Theme.of(context).textTheme.headline6!.merge(
                  TextStyle(
                    letterSpacing: 1.3,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
          ),
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
        ),
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: TabBar(
                  labelColor: Theme.of(context).accentColor,
                  unselectedLabelColor: Theme.of(context).hintColor,
                  tabs: [
                    Tab(
                      child: Text( AppLocalizations.of(context)!.eventCalendarTabInformation,   //'Event Information',
                          textAlign: TextAlign.center),
                    ),
                    Tab(
                      child: Text( AppLocalizations.of(context)!.eventCalendarTabParticipants,  //'Event Contributors',
                          textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration:
                      BoxDecoration(color: Theme.of(context).primaryColor),
                  child: TabBarView(
                    children: [
                      _buildEventInformationTab(),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: _buildContributorList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
