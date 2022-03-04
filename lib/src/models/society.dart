// import '../models/media.dart';


class Society {
  int? id;
  String? name;
  int? permission;
  bool? isPrimary;


  Society();

  Society.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'] != null ? jsonMap['id'] : 0;
      name = jsonMap['name'] != null ? jsonMap['name'] : '';
      permission = jsonMap['permission'] != null ? jsonMap['permission'] : 0;
      isPrimary = jsonMap['is_primary'] != null ? jsonMap['is_primary'] : false;
    } catch (e) {
      print(e.toString());
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["permission"] = permission;
    map["is_primary"] = isPrimary;

    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    return map.toString();
  }
}
