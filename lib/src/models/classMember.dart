// import '../models/media.dart';

class ClassMember {
  int? societyId;
  int? memberId;
  String? memberFirstName;
  String? memberLastName;
  String? avatarUrl;
  int? memberStatus;
  int? classId;
  int? classMemberId;
  bool? isClassMember;

  ClassMember();

  ClassMember.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      societyId = jsonMap['society_id'] != null ? jsonMap['society_id'] : 0;
      memberId = jsonMap['member_id'] != null ? jsonMap['member_id'] : 0;
      memberFirstName = jsonMap['member_first_name'] != null
          ? jsonMap['member_first_name']
          : '';
      memberLastName = jsonMap['member_last_name'] != null
          ? jsonMap['member_last_name']
          : '';
      avatarUrl = jsonMap['avatar_url'] != null ? jsonMap['avatar_url'] : '';
      memberStatus =
          jsonMap['member_status'] != null ? jsonMap['member_status'] : 0;
      classId = jsonMap['class_id'] != null ? jsonMap['class_id'] : 0;
      classMemberId =
          jsonMap['class_member_id'] != null ? jsonMap['class_member_id'] : 0;
      isClassMember =
          jsonMap['is_class_member'] != null ? jsonMap['is_class_member'] : '' as bool?;
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
