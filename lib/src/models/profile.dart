// import '../models/media.dart';


class Profile {
  int? gender;
  String? birthday;
  String? phone;


  Profile();

  Profile.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      gender = jsonMap['user_gender'] != null ? jsonMap['user_gender'] : 0;
      birthday = jsonMap['user_birthday'] != null ? jsonMap['user_birthday'] : '';
      phone = jsonMap['user_phone_mobile'] != null ? jsonMap['user_phone_mobile'] : '';
    } catch (e) {
      print(e.toString());
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["user_gender"] = gender;
    map["user_birthday"] = birthday;
    map["user_phone_mobile"] = phone;

    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    return map.toString();
  }
}
