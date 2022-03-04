// import '../models/media.dart';

class MemberClass {
  int? societyId;
  String? ownerFirstName;
  String? ownerLastName;
  String? societyName;
  int? classId;
  String? className;
  int? classMemberId;
  String? classMemberSince;
  String? classAvatarUrl;

  MemberClass();

  MemberClass.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      societyId = jsonMap['society_id'] != null ? jsonMap['society_id'] : 0;
      ownerFirstName = jsonMap['owner_first_name'] != null
          ? jsonMap['owner_first_name']
          : '';
      ownerLastName =
          jsonMap['owner_last_name'] != null ? jsonMap['owner_last_name'] : '';
      societyName =
          jsonMap['society_name'] != null ? jsonMap['society_name'] : '';
      classId = jsonMap['class_id'] != null ? jsonMap['class_id'] : 0;
      className = jsonMap['class_name'] != null ? jsonMap['class_name'] : '';
      classMemberId =
          jsonMap['class_member_id'] != null ? jsonMap['class_member_id'] : 0;
      classMemberSince = jsonMap['class_member_since'] != null
          ? jsonMap['class_member_since']
          : '';
      classAvatarUrl = jsonMap['class_avatar_url'] != null
          ? jsonMap['class_avatar_url']
          : '';
    } catch (e) {
      print(e.toString());
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
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
