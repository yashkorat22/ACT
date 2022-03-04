// import '../models/media.dart';

class Member {
  int? id;
  int? societyId;
  String? firstName;
  String? lastName;
  String? birthday;
  String? phoneMobile;
  bool? isWpUser;
  String? hashMd5;
  String? avatarUrl;
  String? email;
  int? gender;

  Member();

  Member.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'] != null ? jsonMap['id'] : 0;
      societyId = jsonMap['society_id'] != null ? jsonMap['society_id'] : '' as int?;
      firstName = jsonMap['first_name'] != null ? jsonMap['first_name'] : '';
      lastName = jsonMap['last_name'] != null ? jsonMap['last_name'] : '';
      birthday = jsonMap['birthday'] != null ? jsonMap['birthday'] : '';
      phoneMobile =
          jsonMap['phone_mobile'] != null ? jsonMap['phone_mobile'] : '';
      isWpUser = jsonMap['is_wp_user'] != null ? jsonMap['is_wp_user'] : '' as bool?;
      hashMd5 = jsonMap['hash_md5'] != null ? jsonMap['hash_md5'] : '';
      avatarUrl = jsonMap['avatar_url'] != null ? jsonMap['avatar_url'] : '';
      email = jsonMap['email'] != null ? jsonMap['email'] : '';
      gender = jsonMap['gender'] != null ? jsonMap['gender'] : '' as int?;
    } catch (e) {
      print(e.toString());
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["first_name"] = firstName;
    map["last_name"] = lastName;
    map["birthday"] = birthday;
    map["phone_mobile"] = phoneMobile;
    map["avatar_url"] = avatarUrl;

    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    return map.toString();
  }
}
