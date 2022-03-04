import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';

import '../models/location.dart';

import 'user_repository.dart' as user_repo;

int? createdId = -1;

ValueNotifier<List<ActLocation>> locations = new ValueNotifier([]);
ValueNotifier<List<ActLocation>> myLocations = new ValueNotifier([]);

Future<void> getLocations(int? societyId) async {
  if (societyId == null) {
    societyId = user_repo.currentUserSocieties.value
        .firstWhere((so) => so.isPrimary == true)
        .id;
  }
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/locations$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      locations.value = [];
    } else {
      final data = json.decode(response.body);
      locations.value = List<ActLocation>.from(
          data['locations'].map((lo) => ActLocation.fromJSON(lo)));
      debugPrint(locations.value.toString());
    }
  } catch (e) {
    throw e;
  }
  locations.notifyListeners();
}

Future<void> fetchMyLocations() async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/my/locations$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
    } else {
      final data = json.decode(response.body);
      myLocations.value = List<ActLocation>.from(
          data['locations'].map((lo) => ActLocation.fromJSON(lo)));
      myLocations.notifyListeners();
    }
  } catch (e) {
    throw e;
  }
}

Future<String> createLocation(data) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/locations');

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
      debugPrint(response.body);
      final body = json.decode(response.body);
      List<ActLocation> newLocations = locations.value;
      ActLocation newLocation = ActLocation.fromJSON(body['location'][0]);
      newLocations.add(newLocation);
      locations.value = newLocations;
      locations.notifyListeners();
      return 'true';
    }
  } catch (e) {
    throw e;
  }
}

Future<String> deleteLocation(int? locationId) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/locations/$locationId$apiLocaleSuffix');

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

Future<String> updateLocation(id, data) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/locations/$id$apiLocaleSuffix');

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
      debugPrint(response.body);
      final body = json.decode(response.body);
      ActLocation newLocation = ActLocation.fromJSON(body['location'][0]);
      locations.value = locations.value
          .map((lo) => lo.locationId == id ? newLocation : lo)
          .toList();
      locations.notifyListeners();
      return 'true';
    }
  } catch (e) {
    throw e;
  }
}
