// import '../models/media.dart';

class DiscoveredClass {
  int? societyId;
  String? societyName;
  int? classId;
  String? className;
  int? activityId;
  String? classAvatarUrl;
  int? classMemberId;
  int? classApplicationId;
  String? ownerFirstName;
  String? ownerLastName;
  String? classEventNextDateTime;

  DiscoveredClass();

  DiscoveredClass.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      societyId = jsonMap['society_id'] != null ? jsonMap['society_id'] : 0;
      societyName =
          jsonMap['society_name'] != null ? jsonMap['society_name'] : '';
      classId = jsonMap['class_id'] != null ? jsonMap['class_id'] : 0;
      className = jsonMap['class_name'] != null ? jsonMap['class_name'] : '';
      activityId = jsonMap['activity_id'] != null ? jsonMap['activity_id'] : 0;
      classAvatarUrl = jsonMap['class_avatar_url'] != null
          ? jsonMap['class_avatar_url']
          : '';
      classMemberId =
          jsonMap['class_member_id'] != null ? jsonMap['class_member_id'] : 0;
      classApplicationId = jsonMap['class_application_id'] != null
          ? jsonMap['class_application_id']
          : 0;
      ownerFirstName = jsonMap['owner_first_name'] != null
          ? jsonMap['owner_first_name']
          : '';
      ownerLastName =
          jsonMap['owner_last_name'] != null ? jsonMap['owner_last_name'] : '';
      classEventNextDateTime = jsonMap['class_event_next_dateTime'] != null
          ? jsonMap['class_event_next_dateTime']
          : '';
    } catch (e) {
      print(e.toString());
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["society_id"] = societyId;
    map["society_name"] = societyName;
    map["class_id"] = classId;
    map["class_name"] = className;

    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    return map.toString();
  }
}
