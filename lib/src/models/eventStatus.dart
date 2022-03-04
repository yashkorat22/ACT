// import '../models/media.dart';

class EventStatus {
  String? name;
  int? value;

  EventStatus();

  EventStatus.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      name = jsonMap['name'] != null ? jsonMap['name'] : '';
      value = jsonMap['value'] != null ? jsonMap['value'] : 0;
    } catch (e) {
      print(e.toString());
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
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
