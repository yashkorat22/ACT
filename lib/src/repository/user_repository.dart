import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

import 'package:intl/intl.dart';

import 'package:flutter/cupertino.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../models/profile.dart';
import '../models/society.dart';
import '../models/activity.dart';
import '../models/repetition.dart';
import '../models/eventStatus.dart';
import '../models/template.dart';
import '../models/currency.dart';
import '../models/country.dart';
import '../models/myEvent.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';

import 'location_repository.dart' as location_repo;
import 'subscription_repository.dart' as subscription_repo;

ValueNotifier<User> currentUser = new ValueNotifier(User());
ValueNotifier<Profile> currentUserProfile = new ValueNotifier(Profile());
ValueNotifier<Uint8List?> currentUserAvatar = new ValueNotifier(null);
ValueNotifier<bool?> acceptTerms = new ValueNotifier(false);
ValueNotifier<List<Society>> currentUserSocieties = new ValueNotifier([]);
ValueNotifier<List<Activity>> activities = new ValueNotifier([]);
ValueNotifier<List<Repetition>> repetitions = new ValueNotifier([]);
ValueNotifier<List<EventStatus>> eventStatus = new ValueNotifier([]);
ValueNotifier<List<Template>> templates = new ValueNotifier([]);
ValueNotifier<List<Currency>> currencies = new ValueNotifier([]);
ValueNotifier<List<Country>> countries = new ValueNotifier([]);
ValueNotifier<List<MyEvent>> myEvents = new ValueNotifier([]);
DateTime firstDate = DateTime.now(), lastDate = DateTime.now();

User pendingUser = User();

Future<User?> login(User user) async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/users/login$apiLocaleSuffix');
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200) {
    currentUser.value = User.fromJSON(json.decode(response.body));
    currentUser.value.email = user.email;
    currentUser.value.password = user.password;
    setCurrentUser(json.encode(currentUser.value.toMap()));
    getSocieties();
    getProfile();
  } else if (response.statusCode == 403) {
    return null;
  } else {
    throw new Exception(response.body);
  }
  return currentUser.value;
}

Future<bool> emailForResetPassword(User user) async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/users/password/lost$apiLocaleSuffix');
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode({
      "email": user.email,
    }),
  );

  if (response.statusCode == 200) {
    pendingUser = user;
    return true;
  } else {
    throw new Exception(response.body);
  }
}

Future<bool> resetPassword(String? code, String? password) async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/users/password/change$apiLocaleSuffix');
  final client = new http.Client();
  pendingUser.password = password;
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode({
      "email": pendingUser.email,
      "password": pendingUser.password,
      "password_lost_code": code,
    }),
  );
  if (response.statusCode == 200) {
    try {
      var value = await login(pendingUser);
      if (value != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw e;
    }
  } else {
    throw new Exception(response.body);
  }
}

Future<bool> register(User user) async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/users/register$apiLocaleSuffix');
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200 || response.statusCode == 401) {
    pendingUser = user;
    return true;
  } else {
    throw new Exception(response.body);
  }
}

Future<bool> confirmSignUp(String? code) async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/users/confirm$apiLocaleSuffix');
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode({
      "email": pendingUser.email,
      "password": pendingUser.password,
      "confirmation_code": code,
    }),
  );
  if (response.statusCode == 200) {
    try {
      var value = await login(pendingUser);
      if (value != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw e;
    }
  } else {
    throw new Exception(response.body);
  }
}

Future<bool> resendConfirmEmail() async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/users/confirm/resend$apiLocaleSuffix');
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode({
      "email": pendingUser.email,
      "password": pendingUser.password,
    }),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    throw new Exception(response.body);
  }
}

Future<void> logout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/users/logout$apiLocaleSuffix');
  final client = new http.Client();
  final response = await client.get(
    url,
    headers: {
      "X-WP-Nonce": currentUser.value.nonce!,
      "Cookie": currentUser.value.cookie!
    },
  );
  if (response.statusCode == 200) {
    // successfully log out.
  } else if (response.statusCode == 403) {
    // something went wrong while logging out.
  } else {
    throw new Exception(response.body);
  }

  currentUser.value = new User();
  currentUserProfile.value = new Profile();
  currentUserAvatar.value = null;
  currentUserSocieties.value = [];
  activities.value = [];
  prefs.remove('current_user');
}

void setCurrentUser(jsonString) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (json.decode(jsonString) != null) {
    prefs.setString('current_user', json.encode(json.decode(jsonString)));
  }
}

Future<bool> checkLastLogin(nonce, cookie) async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/users/lastlogin$apiLocaleSuffix');
  final client = new http.Client();
  final response = await client.get(
    url,
    headers: {"X-WP-Nonce": nonce, "Cookie": cookie},
  );

  if (response.statusCode == 200) {
    return true;
  } else if (response.statusCode == 403) {
    return false;
  } else {
    throw new Exception(response.body);
  }
}

Future<User> getCurrentUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //await storage.deleteAll();
  try {
    var currentUserString = prefs.getString('current_user') ?? null;
    if (currentUser.value.auth == null && currentUserString != null) {
      User lastLoggedInUser = User.fromJSON(json.decode(currentUserString));
      try {
        User? value = await login(lastLoggedInUser);
        if (value != null) {
          currentUser.value.auth = true;
        } else {
          currentUser.value = lastLoggedInUser;
          currentUser.value.password = "";
          currentUser.value.auth = false;
        }
      } catch (e) {
        currentUser.value = lastLoggedInUser;
        currentUser.value.auth = false;
      }
    } else {
      currentUser.value = User.fromJSON({"auth": false});
    }
  } catch (e) {
    debugPrint(CustomTrace(StackTrace.current,
        message: "Something went wrong while loading previous auth info.").toString());
    currentUser.value.auth = false;
  }
  currentUser.notifyListeners();
  return currentUser.value;
}

Future<void> getAvatar() async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/users/profile/avatar$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      'X-WP-Nonce': currentUser.value.nonce!,
      'Cookie': currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      currentUserAvatar.value = null;
    } else {
      final data = json.decode(response.body);
      final avatarData = data["blob_base64"];
      currentUserAvatar.value = base64.decode(avatarData);
    }
  } catch (e) {
    currentUserAvatar.value = null;
  }
}

Future<bool> setUserAvatar(Uint8List data) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}/users/profile/avatar$apiLocaleSuffix';
  final bodyData = base64.encode(data);
  Dio dio = new Dio();
  dio.options.headers['Content-Type'] = 'application/json';
  dio.options.headers['X-WP-Nonce'] = currentUser.value.nonce;
  dio.options.headers['Cookie'] = currentUser.value.cookie;
  final response = await dio.post(
    url,
    data: {
      "filename": '',
      "data_base64": bodyData,
    },
  );
  if (response.statusCode == 200) {
    getAvatar();
    return true;
  } else {
    throw new Exception(response.data);
  }
}

Future<void> getProfileData() async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/users/profile/data$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      'X-WP-Nonce': currentUser.value.nonce!,
      'Cookie': currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      currentUserProfile.value = Profile.fromJSON({});
    } else {
      final data = json.decode(response.body);
      currentUserProfile.value = Profile.fromJSON(data);
      currentUser.value.firstName = data['user_firstname'];
      currentUser.value.lastName = data['user_lastname'];
    }
  } catch (e) {
    throw e;
  }
}

Future<void> getProfile() async {
  try {
    var futures = <Future>[];
    futures.add(getAvatar());
    futures.add(getProfileData());
    await Future.wait(futures);
  } catch (e) {
    throw e;
  }
}

Future<dynamic> setProfile(data) async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/users/profile/data$apiLocaleSuffix');
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      'X-WP-Nonce': currentUser.value.nonce!,
      'Cookie': currentUser.value.cookie!,
    },
    body: json.encode(data),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    throw new Exception(response.body);
  }
}

Future<dynamic> removeUserAvatar() async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/users/profile/avatar$apiLocaleSuffix');
  final client = new http.Client();
  final response = await client.delete(
    url,
    headers: {
      'X-WP-Nonce': currentUser.value.nonce!,
      'Cookie': currentUser.value.cookie!,
    },
  );

  if (response.statusCode == 200) {
    currentUserAvatar.value = null;
    return true;
  } else {
    throw new Exception(response.body);
  }
}

Future<void> getSocieties() async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/my/socities$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': currentUser.value.nonce!,
      'Cookie': currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      currentUserSocieties.value = [];
    } else {
      final data = json.decode(response.body);
      currentUserSocieties.value = List<Society>.from(
          data['socities'].map((so) => Society.fromJSON(so)));

      final int? societyId = currentUserSocieties.value
          .firstWhere((so) => so.isPrimary == true)
          .id;
      getActivities(societyId);
      location_repo.getLocations(societyId);
      location_repo.fetchMyLocations();
      getRepetitions(societyId);
      getEventStatus(societyId);
      getTemplates(societyId);
      getCurrencies(societyId);
      getCountries(societyId);
      subscription_repo.fetchMySubscriptions();
      subscription_repo.fetchMyBookings();
    }
  } catch (e) {
    throw e;
  }
}

Future<void> getActivities(int? societyId) async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/activities$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': currentUser.value.nonce!,
      'Cookie': currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      activities.value = [];
    } else {
      final data = json.decode(response.body);
      activities.value = List<Activity>.from(
          data['activities'].map((so) => Activity.fromJSON(so)));
    }
  } catch (e) {
    throw e;
  }
}

Future<void> getRepetitions(int? societyId) async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/repetitions$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': currentUser.value.nonce!,
      'Cookie': currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      repetitions.value = [];
    } else {
      final data = json.decode(response.body);
      repetitions.value = List<Repetition>.from(
          data['repetitions'].map((so) => Repetition.fromJSON(so)));
    }
  } catch (e) {
    throw e;
  }
}

Future<void> getEventStatus(int? societyId) async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/eventStatus$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': currentUser.value.nonce!,
      'Cookie': currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      eventStatus.value = [];
    } else {
      final data = json.decode(response.body);
      eventStatus.value = List<EventStatus>.from(
          data['eventStatus'].map((so) => EventStatus.fromJSON(so)));
    }
  } catch (e) {
    throw e;
  }
}

Future<void> getTemplates(int? societyId) async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/subscriptions/templates$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': currentUser.value.nonce!,
      'Cookie': currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      templates.value = [];
    } else {
      final data = json.decode(response.body);
      templates.value = List<Template>.from(
          data['subscription_templates'].map((so) => Template.fromJSON(so)));
    }
  } catch (e) {
    throw e;
  }
}

Future<void> getCurrencies(int? societyId) async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/currencies$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': currentUser.value.nonce!,
      'Cookie': currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      currencies.value = [];
    } else {
      final data = json.decode(response.body);
      currencies.value = List<Currency>.from(
          data['currencies'].map((so) => Currency.fromJSON(so)));
    }
  } catch (e) {
    throw e;
  }
}

Future<void> getCountries(int? societyId) async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/my/countries$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': currentUser.value.nonce!,
      'Cookie': currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      countries.value = [];
    } else {
      final data = json.decode(response.body);
      countries.value = List<Country>.from(
          data['countries'].map((co) => Country.fromJSON(co)));
    }
  } catch (e) {
    throw e;
  }
}

Future<void> getMyEvents({first, last}) async {
  if (first != null) {
    firstDate = first;
  }
  if (last != null) {
    lastDate = last;
  }

  final client = new http.Client();

  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

  final queryParams = {
    'calendarRangeStart': dateFormatter.format(firstDate),
    'calendarRangeEnd': dateFormatter.format(lastDate),
    'lang': Platform.localeName.substring(0, 2) +
        '-' +
        Platform.localeName.substring(3, 5)
  };

  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/my/classes/eventCalendar' +
          '?' +
          Uri(queryParameters: queryParams).query);

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': currentUser.value.nonce!,
      'Cookie': currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      myEvents.value = [];
    } else {
      final data = json.decode(response.body);
      myEvents.value =
          List<MyEvent>.from(data['events'].map((ev) => MyEvent.fromJSON(ev)));
    }
  } catch (e) {
    throw e;
  }
}

Future<String> registerCalendarEvent(MyEvent event) async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/my/socities/${event.societyId}/classes/${event.classId}/eventCalendar/events/' +
          event.eventId.toString() +
          '/participation$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final eventInfo = {
      'event_dateTimePlan': event.eventDateTimePlan,
      'event_dateTimeReplace': event.eventDateTime,
      'user_participant_status_id': 4
    };

    debugPrint(eventInfo.toString());

    final response = await client.post(
      url,
      headers: {
        'X-WP-Nonce': currentUser.value.nonce!,
        'Cookie': currentUser.value.cookie!,
        'Content-Type': 'application/json',
      },
      body: json.encode(eventInfo),
    );

    if (response.statusCode != 200) {
      return response.body;
    } else {
      return 'true';
    }
  } catch (e) {
    throw e;
  }
}

Future<String> cancelCalendarEvent(MyEvent event) async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/my/socities/${event.societyId}/classes/${event.classId}/eventCalendar/events/' +
          event.eventId.toString() +
          '/participation/' +
          event.userParticipationId.toString() +'$apiLocaleSuffix');
  ;
  final client = new http.Client();

  try {
    final response = await client.delete(url, headers: {
      'X-WP-Nonce': currentUser.value.nonce!,
      'Cookie': currentUser.value.cookie!,
      'Content-Type': 'application/json',
    });

    if (response.statusCode != 200) {
      return response.body;
    } else {
      return 'true';
    }
  } catch (e) {
    throw e;
  }
}
