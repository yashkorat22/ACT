// import '../models/media.dart';

class MyEvent {
  int? classId;
  String? className;
  int? eventActivityId;
  int? eventBookable;
  String? eventComment;
  int? eventDateRepeat;
  String? eventDateRepeatName;
  String? eventDateTime;
  String? eventDateTimePlan;
  String? eventDateTimeStart;
  int? eventDateReplaceId;
  int? eventDuration;
  int? eventId;
  int? eventLocationId;
  String? eventLocationName;
  int? eventMaxParticipants;
  String? eventName;
  int? eventRegParticipants;
  int? eventStatusId;
  String? eventStatusText;
  int? societyId;
  int? societyPermission;
  int? userParticipationId;
  int? userParticipationStatusId;
  String? userParticipationText;

  MyEvent();

  MyEvent.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      classId = jsonMap['class_id'] ?? 0;
      className = jsonMap['class_name'] ?? '';
      eventActivityId = jsonMap['event_activity_id'] ?? 0;
      eventBookable = jsonMap['event_bookable'] ?? 0;
      eventComment = jsonMap['event_comment'] ?? '';
      eventDateRepeat = jsonMap['event_dateRepeat'] ?? 0;
      eventDateRepeatName = jsonMap['event_dateRepeat_name'] ?? '';
      eventDateTime = jsonMap['event_dateTime'] ?? '';
      eventDateTimePlan = jsonMap['event_dateTimePlan'] ?? '';
      eventDateTimeStart = jsonMap['event_dateTimeStart'] ?? '';
      eventDateReplaceId = jsonMap['event_date_replace_id'] ?? 0;
      eventDuration = jsonMap['event_duration'] ?? 0;
      eventId = jsonMap['event_id'] ?? 0;
      eventLocationId = jsonMap['event_location_id'] ?? 0;
      eventLocationName = jsonMap['event_location_name'] ?? '';
      eventMaxParticipants = jsonMap['event_maxParticipants'] ?? 0;
      eventName = jsonMap['event_name'] ?? '';
      eventRegParticipants = jsonMap['event_regParticipants'] ?? 0;
      eventStatusId = jsonMap['event_status_id'] ?? 0;
      eventStatusText = jsonMap['event_status_text'] ?? '';
      societyId = jsonMap['society_id'] ?? 0;
      societyPermission = jsonMap['society_permission'] ?? 4;
      userParticipationId = jsonMap['user_participation_id'] ?? 0;
      userParticipationStatusId = jsonMap['user_participation_status_id'] ?? 0;
      userParticipationText = jsonMap['user_participation_text'] ?? '';
    } catch (e) {
      print(e.toString());
    }
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();

    map["class_id"] = classId;
    map["class_name"] = className;
    map["event_activity_id"] = eventActivityId;
    map["event_bookable"] = eventBookable;
    map["event_comment"] = eventComment;
    map["event_dateRepeat"] = eventDateRepeat;
    map["event_dateRepeat_name"] = eventDateRepeatName;
    map["event_dateTime"] = eventDateTime;
    map["event_dateTimePlan"] = eventDateTimePlan;
    map["event_dateTimeStart"] = eventDateTimeStart;
    map["event_date_replace_id"] = eventDateReplaceId;
    map["event_duration"] = eventDuration;
    map["event_id"] = eventId;
    map["event_location_id"] = eventLocationId;
    map["event_location_name"] = eventLocationName;
    map["event_maxParticipants"] = eventMaxParticipants;
    map["event_name"] = eventName;
    map["event_regParticipants"] = eventRegParticipants;
    map["event_status_id"] = eventStatusId;
    map["event_status_text"] = eventStatusText;
    map["society_id"] = societyId;
    map["society_permission"] = societyPermission;
    map["user_participation_id"] = userParticipationId;
    map["user_participation_status_id"] = userParticipationStatusId;
    map["user_participation_text"] = userParticipationText;

    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    return map.toString();
  }
}
