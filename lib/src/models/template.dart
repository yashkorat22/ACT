// import '../models/media.dart';

class Template {
  String? name;
  String? unit;
  int? unitAmount;
  int? maxCount;

  Template();

  Template.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      name = jsonMap['name'] != null ? jsonMap['name'] : '';
      unit = jsonMap['unit'] != null ? jsonMap['unit'] : '';
      unitAmount = jsonMap['unit_amount'] != null ? jsonMap['unit_amount'] : 0;
      maxCount = jsonMap['max_count'] != null ? jsonMap['max_count'] : 0;
    } catch (e) {
      print(e.toString());
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["name"] = name;
    map["unit"] = unit;
    map["unit_amount"] = unitAmount;
    map["max_count"] = maxCount;

    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    return map.toString();
  }
}
