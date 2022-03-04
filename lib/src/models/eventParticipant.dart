// import '../models/media.dart';

class EventParticipant {
  int? participationId;
  int? societyId;
  int? classId;
  int? eventId;
  String? eventDateTimePlan;
  int? memberId;
  String? memberFirstName;
  String? memberLastName;
  String? avatarUrl;
  int? participationStatusId;
  String? participationStatusName;

  EventParticipant();

  EventParticipant.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      participationId = jsonMap['participation_id'] != null ? jsonMap['participation_id'] : 0;
      societyId = jsonMap['society_id'] != null ? jsonMap['society_id'] : 0;
      classId = jsonMap['class_id'] != null ? jsonMap['class_id'] : 0;
      eventId = jsonMap['event_id'] != null ? jsonMap['event_id'] : 0;
      eventDateTimePlan = jsonMap['event_dateTimePlan'] != null
          ? jsonMap['event_dateTimePlan']
          : '';
      memberId = jsonMap['member_id'] != null ? jsonMap['member_id'] : 0;
      memberFirstName = jsonMap['member_first_name'] != null
          ? jsonMap['member_first_name']
          : '';
      memberLastName = jsonMap['member_last_name'] != null
          ? jsonMap['member_last_name']
          : '';
      avatarUrl = jsonMap['avatar_url'] != null ? jsonMap['avatar_url'] : '';
      participationStatusId =
          jsonMap['participation_status_id'] != null ? jsonMap['participation_status_id'] : 0;
      participationStatusName =
          jsonMap['participation_status_name'] != null ? jsonMap['participation_status_name'] : '';
    } catch (e) {
      print(e.toString());
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["society_id"] = societyId;
    map["member_id"] = memberId;

    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    return map.toString();
  }
}
