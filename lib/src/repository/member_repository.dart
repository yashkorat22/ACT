import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';

import 'user_repository.dart' as user_repo;

import '../helpers/helper.dart';

import '../models/member.dart';
import '../models/applicant.dart';

int? createdId = -1;
int? editId = -1;

Future<List<Member>> fetchMembers() async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members$apiLocaleSuffix');
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
      return List<Member>.from(
          data['members'].map((mem) => Member.fromJSON(mem)));
    }
  } catch (e) {
    throw e;
  }
}

Future<String> createMember(data) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members$apiLocaleSuffix');

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
      createdId = body['members'][0]['id'];
      return 'true';
    }
  } catch (e) {
    throw e;
  }
}

Future<String> updateMember(data) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/$editId$apiLocaleSuffix');

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
      createdId = body['member_id'];
      return 'true';
    }
  } catch (e) {
    throw e;
  }
}

Future<String> deleteMember(int? memberId) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/$memberId$apiLocaleSuffix');

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

Future<Member> fetchMember() async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/$editId$apiLocaleSuffix');

  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });
    if (response.statusCode != 200) {
      throw Exception(response.body);
    } else {
      return Member.fromJSON(jsonDecode(response.body)['members'][0]);
    }
  } catch (e) {
    throw e;
  }
}

Future<String> disconnectSelfManaged() async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/$editId/disconnect$apiLocaleSuffix');

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

Future<List<Applicant>> fetchApplicants() async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/applications$apiLocaleSuffix');
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
      return List<Applicant>.from(
          data['applicants'].map((mem) => Applicant.fromJSON(mem)));
    }
  } catch (e) {
    throw e;
  }
}

Future<String> acceptApplication(applicationId) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/applications/$applicationId$apiLocaleSuffix');

  final client = new http.Client();

  try {
    final response = await client.put(url, headers: {
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

Future<String> declineApplication(applicationId) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/applications/$applicationId$apiLocaleSuffix');

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
