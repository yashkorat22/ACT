// import '../models/media.dart';

class Repetition {
  int? id;
  String? name;
  int? value;

  Repetition();

  Repetition.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'] != null ? jsonMap['id'] : 0;
      name = jsonMap['name'] != null ? jsonMap['name'] : '';
      value = jsonMap['value'] != null ? jsonMap['value'] : 0;
    } catch (e) {
      print(e.toString());
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["value"] = value;

    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    return map.toString();
  }
}
