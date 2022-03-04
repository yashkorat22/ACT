import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../repository/user_repository.dart' as user_repo;
import '../repository/location_repository.dart' as location_repo;
import '../repository/class_repository.dart' as class_repo;
import '../helpers/helper.dart';

class ClassEventDetailController extends ControllerMVC {
  GlobalKey<ScaffoldState>? scaffoldKey;
  GlobalKey<FormState>? formKey;
  OverlayEntry? loader;

  TextEditingController nameController = TextEditingController();
  TextEditingController eventTimeController = TextEditingController();
  String startDate = '';
  String endDate = '';

  int activityId = 0;
  int? locationId;
  int statusId = 0;
  int repetitionId = 0;
  int? maxParticipants = 0;
  int? duration = 60;

  BuildContext? context;

  ClassEventDetailController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    formKey = new GlobalKey<FormState>();
    activityId = user_repo.activities.value
        .indexWhere((activity) => activity.public! > 0);
  }

  @override
  void initState() {
    super.initState();
    context = state!.context;
    loader = Helper.overlayLoader(context);
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    final DateFormat timeFormatter = DateFormat('HH:mm');

    if (class_repo.editEvent == null) {
      final now = DateTime.now();
      final nextYear = now.add(Duration(days: 365));

      final String currentDate = dateFormatter.format(now);
      final String nextYearDate = dateFormatter.format(nextYear);

      final String currentTime = timeFormatter.format(now);

      startDate = currentDate;
      endDate = nextYearDate;
      eventTimeController.text = currentTime;
      maxParticipants = 0;
      duration = 60;
    } else {
      nameController.text = class_repo.editEvent!.eventName!;

      DateTime startDateTime =
          DateTime.parse(class_repo.editEvent!.eventDateTimeStart! + 'Z');
      startDate = dateFormatter.format(startDateTime);
      eventTimeController.text = timeFormatter.format(startDateTime);

      final endDateTime = class_repo.editEvent?.eventDateTimeEnd;
      endDate = endDateTime != ''
          ? dateFormatter.format(DateTime.parse(endDateTime! + 'Z'))
          : '';

      duration = class_repo.editEvent!.eventDuration;
      maxParticipants = class_repo.editEvent!.evenMaxParticipants;

      activityId = user_repo.activities.value.indexWhere(
          (activity) => activity.id == class_repo.editEvent!.eventActivityId);
      if (activityId < 0) activityId = 0;
      statusId = user_repo.eventStatus.value.indexWhere(
          (event) => event.value == class_repo.editEvent!.eventStatusId);
      if (statusId < 0) statusId = 0;
      repetitionId = user_repo.repetitions.value.indexWhere((repetition) =>
          repetition.value == class_repo.editEvent!.eventDateRepeat);
      if (repetitionId < 0) repetitionId = 0;
      locationId = location_repo.locations.value.indexWhere(
          (location) => location.locationId == class_repo.editEvent!.eventLocationId);
      if (locationId! < 0) locationId = null;
    }
  }

  Future<void> createClassEvent() async {
    FocusScope.of(context!).requestFocus(new FocusNode());
    if (!formKey!.currentState!.validate()) {
      return;
    }
    Overlay.of(context!)!.insert(loader!);
    try {
      final eventInfo = {
        'name': nameController.text,
        'comment': null,
        'location_id': locationId != null &&
                locationId! < location_repo.locations.value.length
            ? location_repo.locations.value[locationId!].locationId
            : null,
        'activity_id': user_repo.activities.value[activityId].id,
        'status_id': user_repo.eventStatus.value[statusId].value,
        'duration': duration,
        'maxParticipants': maxParticipants,
        'dateTimeStart':
          startDate + ' ' + eventTimeController.text + ':00',
        'dateTimeEnd': endDate.length == 0 ||
                user_repo.repetitions.value[repetitionId].value == 0
            ? null
            : endDate + ' ' + eventTimeController.text + ':00',
        'dateRepeat': user_repo.repetitions.value[repetitionId].value,
      };
      final response = await class_repo.createClassEvent(eventInfo);
      if (response == 'true') {
        Helper.hideLoader(loader);
        Navigator.of(scaffoldKey!.currentContext!).pop();
      } else {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      }
    } catch (e) {
      print((e as dynamic).errMsg());
    } finally {
      Helper.hideLoader(loader);
    }
  }

  Future<void> updateClassEvent() async {
    FocusScope.of(context!).requestFocus(new FocusNode());
    if (!formKey!.currentState!.validate()) {
      return;
    }
    Overlay.of(context!)!.insert(loader!);
    try {
      final eventInfo = {
        'name': nameController.text,
        'comment': null,
        'location_id': locationId != null &&
                locationId! < location_repo.locations.value.length
            ? location_repo.locations.value[locationId!].locationId
            : null,
        'activity_id': user_repo.activities.value[activityId].id,
        'status_id': user_repo.eventStatus.value[statusId].value,
        'duration': duration,
        'maxParticipants': maxParticipants,
        'dateTimeStart':
          startDate + ' ' + eventTimeController.text + ':00',
        'dateTimeEnd': endDate.length == 0 ||
            user_repo.repetitions.value[repetitionId].value == 0
            ? null
            : endDate + ' ' + eventTimeController.text + ':00',
        'dateRepeat': user_repo.repetitions.value[repetitionId].value,
      };
      final response = await class_repo.updateClassEvent(eventInfo);
      if (response == 'true') {
        Helper.hideLoader(loader);
        Navigator.of(scaffoldKey!.currentContext!).pop();
      } else {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      }
    } catch (e) {
      print((e as dynamic).errMsg());
    } finally {
      Helper.hideLoader(loader);
    }
  }

  Future<void> deleteClassEvent() async {
    FocusScope.of(context!).requestFocus(new FocusNode());
    if (!formKey!.currentState!.validate()) {
      return;
    }
    Overlay.of(context!)!.insert(loader!);
    try {
      final response =
          await class_repo.deleteClassEvent(class_repo.editEvent!.eventId);
      if (response != 'true') {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        class_repo.deletedClassEventId.value = class_repo.editEvent!.eventId;
        Navigator.of(context!).pop();
      }
    } catch (e) {
      print((e as dynamic).errMsg());
    } finally {
      Helper.hideLoader(loader);
    }
  }
}
