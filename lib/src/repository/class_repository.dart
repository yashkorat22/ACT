import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:intl/intl.dart';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';

import 'user_repository.dart' as user_repo;

import '../helpers/helper.dart';

import '../models/memberClass.dart';
import '../models/trainingClass.dart';
import '../models/classAvatar.dart';
import '../models/classMember.dart';
import '../models/classEvent.dart';
import '../models/eventParticipant.dart';
import '../models/discoveredClass.dart';

int? editId = -1;
ValueNotifier<List<ClassAvatar>> avatarList = new ValueNotifier([]);
ValueNotifier<int?> avatarId = new ValueNotifier(null);

ValueNotifier<int> createdMemberClassId = new ValueNotifier(-1);
ValueNotifier<int?> createdTrainingClassId = new ValueNotifier(-1);
ValueNotifier<int?> deletedTrainingClassId = new ValueNotifier(-1);

ValueNotifier<int?> createdClassEventId = new ValueNotifier(-1);

ClassEvent? editEvent;
ValueNotifier<int?> deletedClassEventId = new ValueNotifier(-1);

ValueNotifier<List<ClassEvent>> calendarEvents = new ValueNotifier([]);

DateTime firstDate = DateTime.now(), lastDate = DateTime.now();

Future<List<MemberClass>> fetchMemberClasses() async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/my/classes$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      return [];
    } else {
      final data = json.decode(response.body);
      return List<MemberClass>.from(
          data['socities'].map((mem) => MemberClass.fromJSON(mem)));
    }
  } catch (e) {
    throw e;
  }
}

Future<List<TrainingClass>> fetchTrainingClasses() async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/classes$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      return [];
    } else {
      final data = json.decode(response.body);
      return List<TrainingClass>.from(
          data['classes'].map((mem) => TrainingClass.fromJSON(mem)));
    }
  } catch (e) {
    throw e;
  }
}

Future<String> createTrainingClass(data) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/classes$apiLocaleSuffix');

  final client = new http.Client();

  try {
    final response = await client.post(url,
        headers: {
          'X-WP-Nonce': user_repo.currentUser.value.nonce!,
          'Cookie': user_repo.currentUser.value.cookie!,
          'Content-Type': 'application/json',
        },
        body: json.encode(data));
    if (response.statusCode != 200) {
      return response.body;
    } else {
      final body = json.decode(response.body);
      createdTrainingClassId.value = body['id'];
      return 'true';
    }
  } catch (e) {
    throw e;
  }
}

Future<String> updateClass(data) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/classes/$editId$apiLocaleSuffix');

  final client = new http.Client();

  try {
    final response = await client.put(url,
        headers: {
          'X-WP-Nonce': user_repo.currentUser.value.nonce!,
          'Cookie': user_repo.currentUser.value.cookie!,
          'Content-Type': 'application/json',
        },
        body: json.encode(data));
    if (response.statusCode != 200 && response.statusCode != 206) {
      return response.body;
    } else {
      final body = json.decode(response.body);
      createdTrainingClassId.value = body['class_id'];
      return 'true';
    }
  } catch (e) {
    throw e;
  }
}

Future<String> deleteClass(int? classId) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/classes/$classId$apiLocaleSuffix');

  final client = new http.Client();

  try {
    final response = await client.delete(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
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

Future<MemberClass> fetchMemberClass() async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/classes$apiLocaleSuffix');

  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });
    if (response.statusCode != 200) {
      throw Exception(response.body);
    } else {
      return MemberClass.fromJSON(jsonDecode(response.body)['classes'][0]);
    }
  } catch (e) {
    throw e;
  }
}

Future<TrainingClass> fetchTrainingClass() async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/classes/$editId$apiLocaleSuffix');

  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });
    if (response.statusCode != 200) {
      throw Exception(response.body);
    } else {
      return TrainingClass.fromJSON(jsonDecode(response.body)['classes'][0]);
    }
  } catch (e) {
    throw e;
  }
}

Future<void> fetchAvatarList() async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/classes/avatar$apiLocaleSuffix');

  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });
    if (response.statusCode != 200) {
      avatarList.value = [];
    } else {
      avatarList.value = List<ClassAvatar>.from(
          jsonDecode(response.body)['members']
              .map((so) => ClassAvatar.fromJSON(so)));
    }
  } catch (e) {
    throw e;
  }
}

Future<List<ClassMember>> fetchClassMembers() async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/classes/$editId/members$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      return [];
    } else {
      final data = json.decode(response.body);
      return List<ClassMember>.from(
          data['class_members'].map((mem) => ClassMember.fromJSON(mem)));
    }
  } catch (e) {
    throw e;
  }
}

Future<String> admissClassMember(int? classId, int memberId) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/classes/$classId/members/$memberId$apiLocaleSuffix');

  final client = new http.Client();

  try {
    final response = await client.post(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });
    if (response.statusCode != 200 && response.statusCode != 206) {
      return response.body;
    } else {
      return 'true';
    }
  } catch (e) {
    throw e;
  }
}

Future<String> dismissClassMember(int? classId, int memberId) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/classes/$classId/members/$memberId$apiLocaleSuffix');

  final client = new http.Client();

  try {
    final response = await client.delete(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });
    if (response.statusCode != 200 && response.statusCode != 206) {
      return response.body;
    } else {
      return 'true';
    }
  } catch (e) {
    throw e;
  }
}

Future<List<ClassEvent>> fetchClassEvents() async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/classes/$editId/events$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      return [];
    } else {
      final data = json.decode(response.body);
      return List<ClassEvent>.from(
          data['events'].map((mem) => ClassEvent.fromJSON(mem)));
    }
  } catch (e) {
    throw e;
  }
}

Future<String> createClassEvent(data) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/classes/$editId/events$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.post(url,
        headers: {
          'X-WP-Nonce': user_repo.currentUser.value.nonce!,
          'Cookie': user_repo.currentUser.value.cookie!,
          'Content-Type': 'application/json',
        },
        body: json.encode(data));

    if (response.statusCode != 200) {
      return response.body;
    } else {
      final data = json.decode(response.body);
      createdClassEventId.value = data['id'];
      return 'true';
    }
  } catch (e) {
    throw e;
  }
}

Future<String> deleteClassEvent(int? eventId) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/classes/$editId/events/$eventId$apiLocaleSuffix');

  final client = new http.Client();

  try {
    final response = await client.delete(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });
    if (response.statusCode != 200 && response.statusCode != 206) {
      return response.body;
    } else {
      return 'true';
    }
  } catch (e) {
    throw e;
  }
}

Future<String> updateClassEvent(data) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/classes/$editId/events/' +
          editEvent!.eventId.toString() +
          apiLocaleSuffix);
  final client = new http.Client();

  try {
    final response = await client.put(url,
        headers: {
          'X-WP-Nonce': user_repo.currentUser.value.nonce!,
          'Cookie': user_repo.currentUser.value.cookie!,
          'Content-Type': 'application/json',
        },
        body: json.encode(data));

    if (response.statusCode != 200) {
      return response.body;
    } else {
      createdClassEventId.value = editEvent!.eventId;
      return 'true';
    }
  } catch (e) {
    throw e;
  }
}

Future<void> fetchCalendarEvents({DateTime? first, DateTime? last}) async {
  if (first != null) {
    firstDate = first;
  }
  if (last != null) {
    lastDate = last;
  }
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;

  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

  final queryParams = {
    'calendarRangeStart': dateFormatter.format(firstDate),
    'calendarRangeEnd': dateFormatter.format(lastDate),
    'lang': Platform.localeName.substring(0, 2) +
        '-' +
        Platform.localeName.substring(3, 5)
  };

  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/classes/$editId/eventCalendar' +
          '?' +
          Uri(queryParameters: queryParams).query);
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
    } else {
      final data = json.decode(response.body);
      calendarEvents.value = List<ClassEvent>.from(
          data['events'].map((mem) => ClassEvent.fromJSON(mem)));
    }
  } catch (e) {
    throw e;
  }
}

Future<void> fetchAllCalendarEvents({DateTime? first, DateTime? last}) async {
  if (first != null) {
    firstDate = first;
  }
  if (last != null) {
    lastDate = last;
  }
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
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
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/eventCalendar' +
          '?' +
          Uri(queryParameters: queryParams).query);
  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
    } else {
      final data = json.decode(response.body);
      calendarEvents.value = List<ClassEvent>.from(
          data['events'].map((mem) => ClassEvent.fromJSON(mem)));
    }
  } catch (e) {
    throw e;
  }
}

Future<String> cancelCalendarEvent(ClassEvent event) async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/${event.societyId}/classes/${event.classId}/events/' +
          event.eventId.toString() +
          '/replace$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.put(url,
        headers: {
          'X-WP-Nonce': user_repo.currentUser.value.nonce!,
          'Cookie': user_repo.currentUser.value.cookie!,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'comment': event.eventComment,
          'dateTimePlan': event.eventDateTimePlan,
          'dateTimeReplace': event.eventDateTime,
          'status_id': 2,
          'duration': event.eventDuration,
          'maxParticipants': event.evenMaxParticipants,
          'location_id': event.eventLocationId,
          'activity_id': event.eventActivityId,
        }));

    if (response.statusCode != 200) {
      return response.body;
    } else {
      return 'true';
    }
  } catch (e) {
    throw e;
  }
}

Future<String> scheduleCalendarEvent(ClassEvent event) async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/${event.societyId}/classes/${event.classId}/events/' +
          event.eventId.toString() +
          '/replace$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final eventInfo = {
      'comment': event.eventComment,
      'dateTimePlan': event.eventDateTimePlan,
      'dateTimeReplace': event.eventDateTime,
      'status_id': 1,
      'duration': event.eventDuration,
      'maxParticipants': event.evenMaxParticipants,
      'location_id': event.eventLocationId,
      'activity_id': event.eventActivityId,
    };

    final response = await client.put(
      url,
      headers: {
        'X-WP-Nonce': user_repo.currentUser.value.nonce!,
        'Cookie': user_repo.currentUser.value.cookie!,
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

Future<String> deleteCalendarEvent(
    int? classId, int? eventId, int? replaceId) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/classes/$classId/events/$eventId/replace/$replaceId$apiLocaleSuffix');

  final client = new http.Client();

  try {
    final response = await client.delete(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });
    if (response.statusCode != 200 && response.statusCode != 206) {
      return response.body;
    } else {
      return 'true';
    }
  } catch (e) {
    throw e;
  }
}

Future<String> updateCalendarEvent(
    data, int? classId, int? eventId, int? replaceId) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/classes/$classId/events/$eventId/replace$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final ajax = replaceId != null && replaceId > 0 ? client.put : client.post;
    final response = await ajax(url,
        headers: {
          'X-WP-Nonce': user_repo.currentUser.value.nonce ?? '',
          'Cookie': user_repo.currentUser.value.cookie ?? '',
          'Content-Type': 'application/json',
        },
        body: json.encode(data));

    if (response.statusCode != 200) {
      return response.body;
    } else {
      createdClassEventId.value = eventId;
      return 'true';
    }
  } catch (e) {
    throw e;
  }
}

Future<List<EventParticipant>> fetchEventParticipants(
    eventId, classId, dateTimePlan) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final client = new http.Client();

  final queryParams = {
    'dateTimePlan': dateTimePlan,
    'lang': Platform.localeName.substring(0, 2) +
        '-' +
        Platform.localeName.substring(3, 5)
  };

  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/classes/$classId/eventCalendar/events/$eventId/participation' +
          '?' +
          Uri(queryParameters: queryParams).query);

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      return [];
    } else {
      final data = json.decode(response.body);
      return List<EventParticipant>.from(
          data['participants'].map((p) => EventParticipant.fromJSON(p)));
    }
  } catch (e) {
    throw e;
  }
}

Future<dynamic> admissEventParticipant(
    data, int? classId, int? eventId, int? participationStatusId) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/classes/$classId/eventCalendar/events/$eventId/participation$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final ajax = participationStatusId != null && participationStatusId > 0
        ? client.put
        : client.post;
    final response = await ajax(url,
        headers: {
          'X-WP-Nonce': user_repo.currentUser.value.nonce ?? '',
          'Cookie': user_repo.currentUser.value.cookie ?? '',
          'Content-Type': 'application/json',
        },
        body: json.encode(data));

    if (response.statusCode != 200) {
      return response.body;
    } else {
      final data = json.decode(response.body);
      return data;
    }
  } catch (e) {
    throw e;
  }
}

Future<dynamic> dismissEventParticipant(
    int? eventId, int? classId, int? participationId) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/classes/$classId/eventCalendar/events/$eventId/participation/$participationId$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.delete(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
      'Content-Type': 'application/json',
    });

    if (response.statusCode != 200) {
      return response.body;
    } else {
      final data = json.decode(response.body);
      return data;
    }
  } catch (e) {
    throw e;
  }
}

Future<List<DiscoveredClass>> discoverClasses() async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/my/classes/discover$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      return [];
    } else {
      final data = json.decode(response.body);
      return List<DiscoveredClass>.from(
          data['classes'].map((mem) => DiscoveredClass.fromJSON(mem)));
    }
  } catch (e) {
    throw e;
  }
}

Future<dynamic> requestApplication(int? societyId, int? classId) async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/my/socities/$societyId/classes/$classId/application$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.post(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      return response.body;
    } else {
      final data = json.decode(response.body);
      return data;
    }
  } catch (e) {
    throw e;
  }
}

Future<dynamic> cancelApplication(
    int? societyId, int? classId, int? applicationId) async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/my/socities/$societyId/classes/$classId/application/$applicationId$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.delete(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      return response.body;
    } else {
      final data = json.decode(response.body);
      return data;
    }
  } catch (e) {
    throw e;
  }
}
