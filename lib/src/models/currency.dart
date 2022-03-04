// import '../models/media.dart';

class Currency {
  String? name;
  int? value;

  Currency();

  Currency.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      name = jsonMap['name'] ?? '';
      value = jsonMap['value'] ?? 0;
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
