// import '../models/media.dart';

class TrainingClass {
  int? id;
  String? name;
  int? activityId;
  int? avatarId;
  String? hashMd5;
  String? avatarUrl;
  int? public;
  int? autoAssign;
  int? activeCount;
  int? eventNextId;
  String? eventNextDate;
  String? created;
  int? societyId;

  TrainingClass();

  TrainingClass.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'] != null ? jsonMap['id'] : 0;
      name = jsonMap['name'] != null ? jsonMap['name'] : '';
      activityId = jsonMap['activity_id'] != null ? jsonMap['activity_id'] : 0;
      avatarId = jsonMap['avatar_id'] != null ? jsonMap['avatar_id'] : 0;
      hashMd5 = jsonMap['hash_md5'] != null ? jsonMap['hash_md5'] : '';
      avatarUrl = jsonMap['avatar_url'] != null ? jsonMap['avatar_url'] : '';
      public = jsonMap['public'] != null ? jsonMap['public'] : 0;
      autoAssign = jsonMap['autoAssign'] != null ? jsonMap['autoAssign'] : 0;
      activeCount = jsonMap['active_count'] != null ? jsonMap['active_count'] : 0;
      eventNextId =
          jsonMap['event_next_id'] != null ? jsonMap['event_next_id'] : 0;
      eventNextDate =
          jsonMap['event_next_date'] != null ? jsonMap['event_next_date'] : '';
      created = jsonMap['created'] != null
          ? jsonMap['created']
          : '';
      societyId = jsonMap['society_id'] != null
          ? jsonMap['society_id']
          : 0;
    } catch (e) {
      print(e.toString());
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["avatar_id"] = avatarId;

    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    return map.toString();
  }
}
