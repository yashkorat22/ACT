import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../repository/user_repository.dart' as user_repo;
import '../repository/location_repository.dart' as location_repo;
import '../repository/class_repository.dart' as class_repo;

import '../models/classEvent.dart';
import '../models/eventParticipant.dart';

import '../helpers/helper.dart';

class CalendarEventDetailController extends ControllerMVC {
  GlobalKey<ScaffoldState>? scaffoldKey;
  GlobalKey<FormState>? formKey;
  OverlayEntry? loader;

  ClassEvent? calendarEvent;

  TextEditingController eventNameController = TextEditingController();
  TextEditingController classNameController = TextEditingController();
  String planDate = "";
  TextEditingController planTimeController = TextEditingController();
  String replaceDate = "";
  TextEditingController replaceTimeController = TextEditingController();

  int activityId = 0;
  int? locationId;
  int statusId = 0;
  int repetitionId = 0;
  int? maxParticipants = 0;
  int? duration = 60;

  BuildContext? context;

  CalendarEventDetailController() {
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
    initData();
  }

  void initData({mine = false}) {
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    final DateFormat timeFormatter = DateFormat('HH:mm');

    if (calendarEvent == null) {
      final now = DateTime.now();

      final String currentDate = dateFormatter.format(now);

      final String currentTime = timeFormatter.format(now);

      planDate = replaceDate = currentDate;
      planTimeController.text = replaceTimeController.text = currentTime;
      maxParticipants = 0;
      duration = 60;
    } else {
      classNameController.text = calendarEvent!.className!;
      eventNameController.text = calendarEvent!.eventName!;

      DateTime planDateTime =
          DateTime.parse(calendarEvent!.eventDateTimePlan! + 'Z');
      DateTime replaceDateTime =
          DateTime.parse(calendarEvent!.eventDateTime! + 'Z');

      planDate = dateFormatter.format(planDateTime);
      planTimeController.text = timeFormatter.format(planDateTime);

      replaceDate = dateFormatter.format(replaceDateTime);
      replaceTimeController.text = timeFormatter.format(replaceDateTime);

      duration = calendarEvent!.eventDuration;
      maxParticipants = calendarEvent!.evenMaxParticipants;

      activityId = user_repo.activities.value.indexWhere(
          (activity) => activity.id == calendarEvent!.eventActivityId);
      if (activityId < 0) activityId = 0;
      statusId = user_repo.eventStatus.value
          .indexWhere((event) => event.value == calendarEvent!.eventStatusId);
      if (statusId < 0) statusId = 0;
      locationId = (mine ? location_repo.myLocations : location_repo.locations)
          .value
          .indexWhere((location) =>
              location.locationId == calendarEvent!.eventLocationId);
      if (locationId! < 0) locationId = null;
    }
  }

  Future<List<EventParticipant>> getEventParticipants(
      eventId, classId, dateTimePlan) async {
    try {
      return await class_repo.fetchEventParticipants(
          eventId, classId, dateTimePlan);
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<void> updateCalendarEvent() async {
    FocusScope.of(context!).requestFocus(new FocusNode());
    if (!formKey!.currentState!.validate()) {
      return;
    }
    Overlay.of(context!)!.insert(loader!);
    try {
      final eventInfo = {
        'comment': null,
        'dateTimePlan': planDate + ' ' + planTimeController.text + ':00',
        'dateTimeReplace': '$replaceDate ${replaceTimeController.text}:00',
        'status_id': user_repo.eventStatus.value[statusId].value,
        'maxParticipants': maxParticipants,
        'location_id': locationId != null &&
                locationId! < location_repo.locations.value.length
            ? location_repo.locations.value[locationId!].locationId
            : null,
        'activity_id': user_repo.activities.value[activityId].id,
        'duration': duration,
      };
      final response = await class_repo.updateCalendarEvent(
        eventInfo,
        calendarEvent!.classId,
        calendarEvent!.eventId,
        calendarEvent!.eventDateReplaceId,
      );
      if (response == 'true') {
        Helper.hideLoader(loader);
        if (class_repo.editId != -1) {
          await class_repo.fetchCalendarEvents();
        } else {
          await class_repo.fetchAllCalendarEvents();
        }
        Navigator.of(scaffoldKey!.currentContext!).pop();
      } else {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      }
    } catch (e) {
      print(e);
    } finally {
      Helper.hideLoader(loader);
    }
  }

  Future<void> deleteCalendarEvent() async {
    FocusScope.of(context!).requestFocus(new FocusNode());
    if (!formKey!.currentState!.validate()) {
      return;
    }
    Overlay.of(context!)!.insert(loader!);
    try {
      final response = await class_repo.deleteCalendarEvent(
        calendarEvent!.classId,
        calendarEvent!.eventId,
        calendarEvent!.eventDateReplaceId,
      );
      if (response != 'true') {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        if (class_repo.editId != -1) {
          await class_repo.fetchCalendarEvents();
        } else {
          await class_repo.fetchAllCalendarEvents();
        }
        Navigator.of(context!).pop();
      }
    } catch (e) {
      print(e);
    } finally {
      Helper.hideLoader(loader);
    }
  }

  Future<dynamic> admissEventParticipant(
      EventParticipant participantInfo) async {
    Overlay.of(context!)!.insert(loader!);
    dynamic result;
    try {
      final updateInfo = {
        'member_id': participantInfo.memberId,
        'event_dateTimePlan': participantInfo.eventDateTimePlan,
        'event_dateTimeReplace':
            '$replaceDate ${replaceTimeController.text}:00',
        'participation_status_id': 1,
      };
      final eventId = participantInfo.eventId;
      final classId = participantInfo.classId;
      final statusId = participantInfo.participationStatusId;

      final response = await class_repo.admissEventParticipant(
          updateInfo, classId, eventId, statusId);
      if (response is String) {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
        result = null;
      } else {
        result = response;
      }
    } catch (e) {
      print(e);
    } finally {
      Helper.hideLoader(loader);
    }
    return result;
  }

  Future<dynamic> dismissEventParticipant(
      EventParticipant participantInfo) async {
    Overlay.of(context!)!.insert(loader!);
    dynamic result;
    try {
      final eventId = participantInfo.eventId;
      final classId = participantInfo.classId;
      final participationId = participantInfo.participationId;

      final response = await class_repo.dismissEventParticipant(
          eventId, classId, participationId);
      if (response is String) {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
        result = null;
      } else {
        result = response;
      }
    } catch (e) {
      print(e);
    } finally {
      Helper.hideLoader(loader);
    }
    return result;
  }
}
