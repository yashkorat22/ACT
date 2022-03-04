// import '../models/media.dart';

class Activity {
  int? id;
  int? societyId;
  int? public;
  String? name;

  Activity();

  Activity.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'] != null ? jsonMap['id'] : 0;
      societyId = jsonMap['society_id'] != null ? jsonMap['society_id'] : '' as int?;
      public = jsonMap['public'] != null ? jsonMap['public'] : 0;
      name = jsonMap['name'] != null ? jsonMap['name'] : false as String?;
    } catch (e) {
      print(e.toString());
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["society_id"] = societyId;
    map["public"] = public;
    map["name"] = name;

    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    return map.toString();
  }
}
