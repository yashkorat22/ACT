// import '../models/media.dart';

class ClassAvatar {
  int? id;
  int? societyId;
  String? avatarUrl;

  ClassAvatar();

  ClassAvatar.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'] != null ? jsonMap['id'] : 0;
      avatarUrl = jsonMap['avatar_url'] != null ? jsonMap['avatar_url'] : '';
      societyId = jsonMap['event_location_id'] != null
          ? jsonMap['event_location_id']
          : 0;
    } catch (e) {
      print(e.toString());
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["avatar_url"] = avatarUrl;

    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    return map.toString();
  }
}
