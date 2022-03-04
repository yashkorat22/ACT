// import '../models/media.dart';

class Applicant {
  int? applicationId;
  int? societyId;
  String? firstName;
  String? lastName;
  int? classId;
  String? className;
  int? societyMemberId;
  String? applicationSince;
  int? classBlocked;
  String? avatarUrl;

  Applicant();

  Applicant.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      applicationId =
          jsonMap['application_id'] != null ? jsonMap['application_id'] : 0;
      societyId = jsonMap['society_id'] != null ? jsonMap['society_id'] : 0;
      firstName = jsonMap['first_name'] != null ? jsonMap['first_name'] : '';
      lastName = jsonMap['last_name'] != null ? jsonMap['last_name'] : '';
      classId = jsonMap['class_id'] != null ? jsonMap['class_id'] : 0;
      className = jsonMap['class_name'] != null ? jsonMap['class_name'] : '';
      societyMemberId = jsonMap['society_member_id'] != null
          ? jsonMap['society_member_id']
          : 0;
      applicationSince = jsonMap['application_since'] != null
          ? jsonMap['application_since']
          : '';
      classBlocked =
          jsonMap['class_blocked'] != null ? jsonMap['class_blocked'] : 0;
      avatarUrl = jsonMap['avatar_url'] != null ? jsonMap['avatar_url'] : '';
    } catch (e) {
      print(e.toString());
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["application_id"] = applicationId;
    map["society_id"] = societyId;
    map["first_name"] = firstName;
    map["last_name"] = lastName;
    map["class_id"] = classId;
    map["class_name"] = className;
    map["society_member_id"] = societyMemberId;
    map["class_blocked"] = classBlocked;

    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    return map.toString();
  }
}
