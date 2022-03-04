class Country {
  String? name;
  String? value;

  Country();

  Country.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      name = jsonMap['name'] ?? '';
      value = jsonMap['value'] ?? '';
    } catch (e) {
      print(e.toString());
    }
  }

  Map toMap() {
    var map = new Map<String, String?>();
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
