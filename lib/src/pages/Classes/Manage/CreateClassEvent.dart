import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/services.dart';

import '../../../elements/BlockButtonWidget.dart';
import '../../../elements/CustomDatePicker.dart';
import '../../../elements/CustomTimePicker.dart';

import '../../../models/activity.dart';
import '../../../models/location.dart';
import '../../../models/eventStatus.dart';
import '../../../models/repetition.dart';

import '../../../controllers/class_event_controller.dart';

import '../../../repository/user_repository.dart' as user_repo;
import '../../../repository/location_repository.dart' as location_repo;

class CreateClassEventWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;
  final DateTime? selectedDate;

  CreateClassEventWidget({Key? key, this.parentScaffoldKey, this.selectedDate})
      : super(key: key);
  @override
  _CreateClassEventWidgetState createState() => _CreateClassEventWidgetState();
}

class _CreateClassEventWidgetState extends StateMVC<CreateClassEventWidget> {
  late ClassEventDetailController _con;

  List<Activity> activities = [];
  List<ActLocation> locations = [];
  List<EventStatus> eventStatus = [];
  List<Repetition> repetitions = [];

  _CreateClassEventWidgetState() : super(ClassEventDetailController()) {
    _con = controller as ClassEventDetailController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.selectedDate != null) {
      final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
      _con.startDate = dateFormatter.format(widget.selectedDate!);
    }
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
            AppLocalizations.of(context)!.eventCreate,                                          // 'Create Event',
            style: Theme.of(context).textTheme.headline6!.merge(
                  TextStyle(
                    letterSpacing: 1.3,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            padding: EdgeInsets.only(left: 25, right: 25, top: 15),
            child: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: <Widget>[
                Positioned(
                  top: -5,
                  left: -15,
                  child: IconButton(
                    icon: new Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Column(children: [
                  SizedBox(height: 50),
                  Form(
                    key: _con.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _con.nameController,
                          onSaved: (input) => _con.nameController.text = input!,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.sentences,
                          validator: (input) => input!.length < 1
                              ? AppLocalizations.of(context)!.appInputMandatoryField            // 'Input the event name'
                              : (input.length < 3
                                  ? AppLocalizations.of(context)!.appInputValidationLengthMin +' 3'         //'Event name shouble more than 3 letters'
                                  : (input.length > 255
                                      ? AppLocalizations.of(context)!.appInputValidationLengthMax +' 255'       // 'Event name should be less than 255 letters.'
                                      : null)),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.eventName,                 // "Event Name",
                            labelStyle:
                                TextStyle(color: Theme.of(context).accentColor),
                            contentPadding: EdgeInsets.all(12),
                            hintText: 'First Event',
                            hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .focusColor
                                    .withOpacity(0.7)),
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
                        SizedBox(height: 15),
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.eventActivity,             // "Activity",
                            labelStyle:
                                TextStyle(color: Theme.of(context).accentColor),
                            contentPadding: EdgeInsets.all(12),
                            hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .focusColor
                                    .withOpacity(0.7)),
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
                          value: activities.length > _con.activityId
                              ? activities[_con.activityId].name
                              : null,
                          onTap: () {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                          },
                          onChanged: (String? newValue) {
                            setState(() {
                              _con.activityId = activities.indexWhere(
                                  (activity) => activity.name == newValue);
                            });
                          },
                          items: activities.map<DropdownMenuItem<String>>(
                              (Activity activity) {
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
                                  labelText: AppLocalizations.of(context)!.eventLocation,       // "Location",
                                  labelStyle: TextStyle(
                                      color: Theme.of(context).accentColor),
                                  contentPadding: EdgeInsets.all(12),
                                  hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .focusColor
                                          .withOpacity(0.7)),
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
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                },
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _con.locationId = locations.indexWhere(
                                        (activity) =>
                                            activity.name == newValue);
                                  });
                                },
                                items: locations.map<DropdownMenuItem<String>>(
                                    (ActLocation location) {
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
                                  Navigator.of(context)
                                      .pushNamed('/CreateLocation');
                                },
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 10),
                                color: Theme.of(context).accentColor,
                                shape: StadiumBorder(),
                                child: Text( AppLocalizations.of(context)!.appButtonNew,        //'New',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.eventStatus,               //"Status",
                            labelStyle:
                                TextStyle(color: Theme.of(context).accentColor),
                            contentPadding: EdgeInsets.all(12),
                            hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .focusColor
                                    .withOpacity(0.7)),
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
                          value: eventStatus.length > _con.statusId
                              ? eventStatus[_con.statusId].name
                              : null,
                          onTap: () {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                          },
                          onChanged: (String? newValue) {
                            setState(() {
                              _con.statusId = eventStatus.indexWhere(
                                  (activity) => activity.name == newValue);
                            });
                          },
                          items: eventStatus.map<DropdownMenuItem<String>>(
                              (EventStatus status) {
                            return DropdownMenuItem<String>(
                              value: status.name,
                              child: Text(status.name!),
                            );
                          }).toList(),
                        ),
                        if (repetitions[_con.repetitionId].value == 0)
                          SizedBox(height: 15),
                        if (repetitions[_con.repetitionId].value == 0)
                          CustomDatePicker(
                              value: _con.startDate,
                              onChange: (value) {
                                setState(() {
                                  _con.startDate = value;
                                });
                              },
                              label: AppLocalizations.of(context)!.eventStartDate ), // First Date
                        SizedBox(height: 10),
                        GridView.count(
                          primary: false,
                          padding: const EdgeInsets.only(top: 5),
                          crossAxisSpacing: 10,
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          childAspectRatio: 2.5,
                          children: <Widget>[
                            if (repetitions[_con.repetitionId].value != 0)
                              CustomDatePicker(
                                  value: _con.startDate,
                                  onChange: (value) {
                                    setState(() {
                                      _con.startDate = value;
                                    });
                                  },
                                  label: AppLocalizations.of(context)!.eventStartDate ),        // First Date
                            if (repetitions[_con.repetitionId].value != 0)
                              CustomDatePicker(
                                  value: _con.endDate,
                                  onChange: (value) {
                                    setState(() {
                                      _con.endDate = value;
                                    });
                                  },
                                  label: AppLocalizations.of(context)!.eventEndDate),           // End Date
                            DropdownButtonFormField(
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.eventRepetition,       // "Repetition",
                                labelStyle: TextStyle(
                                    color: Theme.of(context).accentColor),
                                contentPadding: EdgeInsets.all(12),
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.7)),
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
                              value: repetitions.length > _con.repetitionId
                                  ? repetitions[_con.repetitionId].name
                                  : null,
                              onTap: () {
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                              },
                              onChanged: (String? newValue) {
                                setState(() {
                                  if (repetitions[_con.repetitionId].value ==
                                      0) {
                                    DateTime startDate = DateTime.parse(
                                        _con.startDate);
                                    final DateFormat dateFormatter =
                                        DateFormat('yyyy-MM-dd');
                                    if (dateFormatter.format(startDate) !=
                                        _con.startDate) {
                                      startDate = DateTime.now();
                                    }
                                    startDate =
                                        startDate.add(Duration(days: 365));
                                    _con.endDate =
                                        dateFormatter.format(startDate);
                                  }
                                  _con.repetitionId = repetitions.indexWhere(
                                      (repetition) =>
                                          repetition.name == newValue);
                                });
                              },
                              items: repetitions.map<DropdownMenuItem<String>>(
                                  (Repetition repetition) {
                                return DropdownMenuItem<String>(
                                  value: repetition.name,
                                  child: Text(repetition.name!),
                                );
                              }).toList(),
                            ),
                            CustomTimePicker(
                                controller: _con.eventTimeController,
                                label: AppLocalizations.of(context)!.eventTime ),               // Event Time
                            DropdownButtonFormField(
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.eventDuration,         // "Duration (min)",
                                labelStyle: TextStyle(
                                    color: Theme.of(context).accentColor),
                                contentPadding: EdgeInsets.all(12),
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.7)),
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
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
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
                                labelText: AppLocalizations.of(context)!.eventMaxParticipants,  // "Max. Participants",
                                labelStyle: TextStyle(
                                    color: Theme.of(context).accentColor),
                                contentPadding: EdgeInsets.all(12),
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.7)),
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
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                              },
                              onChanged: (String? newValue) {
                                setState(() {
                                  _con.maxParticipants = int.parse(newValue!);
                                });
                              },
                              items: List<DropdownMenuItem<String>>.generate(
                                  100,
                                  (i) => DropdownMenuItem<String>(
                                        value: i.toString(),
                                        child: Text(i == 0
                                            ? 'Unlimited'
                                            : i.toString()),
                                      )),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          child: BlockButtonWidget(
                            text: Text(
                              AppLocalizations.of(context)!.appButtonCreate,                    // "Save",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                            color: Theme.of(context).accentColor,
                            onPressed: () {
                              TextInput.finishAutofillContext(shouldSave: true);
                              _con.createClassEvent();
                            },
                          ),
                        ),
                        SizedBox(height: 50),
                      ],
                    ),
                  ),
                ])
              ],
            ),
          ),
        ),
      ),
    );
  }
}
