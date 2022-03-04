import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../elements/CustomDatePicker.dart';
import '../../../elements/CustomTimePicker.dart';

import '../../../models/classEvent.dart';

import '../../../controllers/calendar_event_controller.dart';

import '../../../helpers/helper.dart';

import '../../../repository/user_repository.dart' as user_repo;
import '../../../repository/location_repository.dart' as location_repo;

class CalendarEventInformationWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;
  final ClassEvent? event;

  CalendarEventInformationWidget({Key? key, this.parentScaffoldKey, this.event})
      : super(key: key);
  @override
  _CalendarEventInformationWidgetState createState() =>
      _CalendarEventInformationWidgetState();
}

class _CalendarEventInformationWidgetState
    extends StateMVC<CalendarEventInformationWidget> {
  late CalendarEventDetailController _con;

  TextEditingController activityController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController maxParticipantsController = TextEditingController();

  bool isFetching = true;

  _CalendarEventInformationWidgetState()
      : super(CalendarEventDetailController()) {
    _con = controller as CalendarEventDetailController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    location_repo.locations.addListener(() {
      setState(() {
        _con.locationId = location_repo.myLocations.value.length - 1;
      });
    });

    _con.calendarEvent = widget.event;
    _con.initData(mine: true);
    initData();
    activityController.text =
        user_repo.activities.value.length > _con.activityId
            ? user_repo.activities.value[_con.activityId].name ?? ''
            : '';
    locationController.text = _con.locationId != null &&
            _con.locationId != -1 &&
            location_repo.myLocations.value.length > _con.locationId!
        ? location_repo.myLocations.value[_con.locationId!].name ?? ''
        : '';
    statusController.text = user_repo.eventStatus.value.length > _con.statusId
        ? user_repo.eventStatus.value[_con.statusId].name ?? ''
        : '';
    durationController.text = _con.duration.toString();
    maxParticipantsController.text = _con.maxParticipants == 0
        ? 'Unlimited'
        : _con.maxParticipants.toString();
  }

  void initData() {
    setState(() => isFetching = false);
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
                  readOnly: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: Helper.of(context).textInputDecoration(
                      AppLocalizations.of(context)!.eventClassName, null,
                      filled: true,
                      fillColor:
                          Theme.of(context).hintColor.withOpacity(0.05))),
              SizedBox(height: 15),
              TextFormField(
                  controller: _con.eventNameController,
                  readOnly: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: Helper.of(context).textInputDecoration(
                      AppLocalizations.of(context)!.eventName, null,
                      filled: true,
                      fillColor:
                          Theme.of(context).hintColor.withOpacity(0.05))),
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
                      label: AppLocalizations.of(context)!.eventPlannedDate, //"Planned Date",
                      disabled: true,
                    ),
                    CustomTimePicker(
                      controller: _con.planTimeController,
                      label: AppLocalizations.of(context)!.eventPlannedTime, //"Planned Time",
                      disabled: true,
                    ),
                  ]),
              TextFormField(
                  controller: activityController,
                  readOnly: true,
                  decoration: Helper.of(context)
                      .textInputDecoration(AppLocalizations.of(context)!.eventActivity, null)),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: locationController,
                      readOnly: true,
                      decoration: Helper.of(context).textInputDecoration(
                          AppLocalizations.of(context)!.eventLocation, null),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/LocationDetail',
                            arguments: location_repo
                                .myLocations.value[_con.locationId!]);
                      },
                      padding:
                          EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                      color: Theme.of(context).accentColor,
                      shape: StadiumBorder(),
                      child: Text(AppLocalizations.of(context)!.locationAddressShow, // New
                          style:
                              TextStyle(color: Theme.of(context).primaryColor)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: statusController,
                readOnly: true,
                decoration: Helper.of(context)
                    .textInputDecoration(AppLocalizations.of(context)!.eventStatus, null),
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
                    label: AppLocalizations.of(context)!.eventReplaceDate, // "Replace Date",
                    disabled: true,
                    filled: false,
                  ),
                  CustomTimePicker(
                    controller: _con.replaceTimeController,
                    label: AppLocalizations.of(context)!.eventReplaceTime, // "Replace Time",\
                    disabled: true,
                    filled: false,
                  ),
                  TextFormField(
                    controller: durationController,
                    readOnly: true,
                    decoration: Helper.of(context)
                        .textInputDecoration(AppLocalizations.of(context)!.eventDuration, null),
                  ),
                  TextFormField(
                    controller: maxParticipantsController,
                    readOnly: true,
                    decoration: Helper.of(context).textInputDecoration(
                        AppLocalizations.of(context)!.eventMaxParticipants, null),
                  ),
                ],
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
            'Calender Event Information',
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
          child: _buildEventInformationTab(),
        ),
      ),
    );
  }
}
