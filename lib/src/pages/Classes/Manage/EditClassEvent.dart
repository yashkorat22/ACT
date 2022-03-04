import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/services.dart';

import '../../../elements/CustomDatePicker.dart';
import '../../../elements/CustomTimePicker.dart';

import '../../../models/activity.dart';
import '../../../models/location.dart';
import '../../../models/eventStatus.dart';
import '../../../models/repetition.dart';

import '../../../controllers/class_event_controller.dart';

import '../../../repository/user_repository.dart' as user_repo;
import '../../../repository/class_repository.dart' as class_repo;
import '../../../repository/location_repository.dart' as location_repo;

class EditClassEventWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  EditClassEventWidget({Key? key, this.parentScaffoldKey}) : super(key: key);
  @override
  _EditClassEventWidgetState createState() => _EditClassEventWidgetState();
}

class _EditClassEventWidgetState extends StateMVC<EditClassEventWidget> {
  late ClassEventDetailController _con;
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

  _EditClassEventWidgetState() : super(ClassEventDetailController()) {
    _con = controller as ClassEventDetailController;
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
                Text( AppLocalizations.of(context)!.eventRemoveEventConfirmText ),              // 'Are you sure to delete this event?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text( AppLocalizations.of(context)!.appButtonYes ),                        // Yes
              onPressed: () {
                Navigator.of(context).pop();
                _con.deleteClassEvent();
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

  Future<void> _deleteClass() async {
    _showMyDialog(class_repo.editId);
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
            AppLocalizations.of(context)!.eventEdit,                                            // Edit event
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
                              ? AppLocalizations.of(context)!.appInputMandatoryField            //'Input the event name'
                              : (input.length < 3
                                  ? AppLocalizations.of(context)!.appInputValidationLengthMin +' 3' // 'Event name shouble more than 3 letters'
                                  : (input.length > 255
                                      ? AppLocalizations.of(context)!.appInputValidationLengthMax +' 255' // 'Event name should be less than 255 letters.'
                                      : null)),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.eventName,                 // Event name
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
                                  labelText: AppLocalizations.of(context)!.eventLocation,       //"Location",
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
                                child: Text( AppLocalizations.of(context)!.appButtonNew,        // New
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.eventStatus,               // "Status",
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
                            label: AppLocalizations.of(context)!.eventStartDate,                // "Start Date",
                            disabled: true,
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
                            if (repetitions[_con.repetitionId].value != 0)
                              CustomDatePicker(
                                value: _con.startDate,
                                onChange: (value) {
                                  setState(() {
                                    _con.startDate = value;
                                  });
                                },
                                label: AppLocalizations.of(context)!.eventStartDate,            // "Start Date",
                                disabled: true,
                              ),
                            if (repetitions[_con.repetitionId].value != 0)
                              CustomDatePicker(
                                value: _con.endDate,
                                onChange: (value) {
                                  setState(() {
                                    _con.endDate = value;
                                  });
                                },
                                label: AppLocalizations.of(context)!.eventEndDate             //"End Date",
                              ),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.eventRepetition,       // "Repetition",
                                labelStyle: TextStyle(
                                    color: Theme.of(context).accentColor),
                                contentPadding: EdgeInsets.all(12),
                                filled: true,
                                fillColor: Theme.of(context)
                                    .hintColor
                                    .withOpacity(0.05),
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
                              initialValue:
                                  repetitions.length > _con.repetitionId
                                      ? repetitions[_con.repetitionId].name
                                      : '',
                              onTap: () {
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                              },
                              readOnly: true,
                            ),
                            CustomTimePicker(
                              controller: _con.eventTimeController,
                              label: AppLocalizations.of(context)!.eventTime,                   // "Event Time",
                            ),
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
                              items: _maxParticipantList,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Container(
                          padding:
                              EdgeInsets.only(left: 20, right: 20, bottom: 20),
                          child: Text(
                            AppLocalizations.of(context)!.eventConfirmRemoveReplacements,       // 'Important: All replacements and member participations after "End Date" get removed!',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                child: Text(
                                  AppLocalizations.of(context)!.appButtonDelete,                // "Delete",
                                  style: TextStyle(
                                      color: Colors.red,
                                      decoration: TextDecoration.underline,
                                      fontSize: 18),
                                ),
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.pressed))
                                          return Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5);
                                        return Theme.of(context).primaryColor;
                                      },
                                    ),
                                    minimumSize:
                                        MaterialStateProperty.all<Size>(
                                            Size(100, 40))),
                                onPressed: () {
                                  _deleteClass();
                                },
                              ),
                              TextButton(
                                child: Text(
                                  AppLocalizations.of(context)!.appButtonSave,                  //"Save",
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 18),
                                ),
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.pressed))
                                          return Theme.of(context)
                                              .accentColor
                                              .withOpacity(0.5);
                                        return Theme.of(context).accentColor;
                                      },
                                    ),
                                    minimumSize:
                                        MaterialStateProperty.all<Size>(
                                            Size(100, 40))),
                                onPressed: () {
                                  TextInput.finishAutofillContext(
                                      shouldSave: true);
                                  _con.updateClassEvent();
                                },
                              ),
                            ]),
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
