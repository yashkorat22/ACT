// import '../models/media.dart';

enum UserState { available, away, busy }

class User {
  String? userName;
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? nonce;
  String? cookie;

  // used for indicate if client logged in or not
  bool? auth;

//  String role;

  User();

  User.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      userName = jsonMap['username'] != null ? jsonMap['username'] : '';
      firstName = jsonMap['firstname'] != null ? jsonMap['firstname'] : '';
      lastName = jsonMap['lastname'] != null ? jsonMap['lastname'] : '';
      firstName = jsonMap['user_firstname'] != null ? jsonMap['user_firstname'] : firstName;
      lastName = jsonMap['user_lastname'] != null ? jsonMap['user_lastname'] : lastName;
      email = jsonMap['email'] != null ? jsonMap['email'] : '';
      password = jsonMap['password'] != null ? jsonMap['password'] : '';
      nonce = jsonMap['nonce'] != null ? jsonMap['nonce'] : '';
      cookie = jsonMap['cookie'] != null ? jsonMap['cookie'] : '';
      auth = jsonMap['auth'] != null ? jsonMap['auth'] : null;

      // image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();
    } catch (e) {
      print(e.toString());
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["user_firstname"] = firstName;
    map["user_lastname"] = lastName;
    map["email"] = email;
    map["password"] = password;
    map["cookie"] = cookie;
    map["nonce"] = nonce;
    map["acceptTerms"] = true;
    // map["media"] = image?.toMap();
    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    map["auth"] = this.auth;
    return map.toString();
  }
}
