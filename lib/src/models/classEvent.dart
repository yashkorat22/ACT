// import '../models/media.dart';

class ClassEvent {
  int? classId;
  String? className;
  int? societyId;
  int? eventId;
  int? eventDateReplaceId;
  String? eventName;
  String? eventComment;
  String? eventDateTimeStart;
  String? eventDateTimeEnd;
  String? eventDateTimePlan;
  String? eventDateTime;
  int? eventActivityId;
  int? eventLocationId;
  int? eventStatusId;
  String? eventStatusText;
  int? eventDuration;
  int? evenMaxParticipants;
  int? eventRegParticipants;
  int? eventDateRepeat;
  String? eventDateRepeatName;
  int? societyPermission;

  ClassEvent();

  ClassEvent.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      classId = jsonMap['class_id'] ?? 0;
      className = jsonMap['class_name'] ?? '';
      societyId = jsonMap['society_id'] ?? 0;
      eventId = jsonMap['event_id'] ?? 0;
      eventDateReplaceId = jsonMap['event_date_replace_id'] ?? 0;
      eventName = jsonMap['event_name'] ?? '';
      eventComment = jsonMap['event_comment'] ?? '';
      eventDateTimeStart = jsonMap['event_dateTimeStart'] ?? '';
      eventDateTimeEnd = jsonMap['event_dateTimeEnd'] ?? '';
      eventDateTimePlan = jsonMap['event_dateTimePlan'] ?? '';
      eventDateTime = jsonMap['event_dateTime'] ?? '';
      eventActivityId = jsonMap['event_activity_id'] ?? 0;
      eventLocationId = jsonMap['event_location_id'] ?? 0;
      eventStatusId = jsonMap['event_status_id'] ?? 0;
      eventStatusText = jsonMap['event_status_text'] ?? '';
      eventDuration = jsonMap['event_duration'] ?? 0;
      evenMaxParticipants = jsonMap['event_maxParticipants'] ?? 0;
      eventRegParticipants = jsonMap['event_regParticipants'] ?? 0;
      eventDateRepeat = jsonMap['event_dateRepeat'] ?? 0;
      eventDateRepeatName = jsonMap['event_dateRepeat_name'] ?? '';
      societyPermission = jsonMap['society_permission'] ?? 4;
    } catch (e) {
      print(e.toString());
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();

    map["event_id"] = eventId;
    map["event_name"] = eventName;
    map["society_id"] = societyId;

    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    return map.toString();
  }
}
