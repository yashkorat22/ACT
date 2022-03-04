import 'dart:convert';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';

import 'user_repository.dart' as user_repo;

import '../helpers/helper.dart';

import '../models/subscription.dart';
import '../models/booking.dart';

int editId = -1;
ValueNotifier<int> createdTrainerSubscriptionId = new ValueNotifier(-1);
ValueNotifier<int> deletedTrainerSubscriptionId = new ValueNotifier(-1);

ValueNotifier<List<Subscription>> trainerSubscriptions = new ValueNotifier([]);
ValueNotifier<List<Subscription>> subscriptions = new ValueNotifier([]);
ValueNotifier<List<Booking>> bookings = new ValueNotifier([]);
ValueNotifier<List<Subscription>> mySubscriptions = new ValueNotifier([]);
ValueNotifier<List<Booking>> myBookings = new ValueNotifier([]);

Future<void> fetchTrainerSubscriptions() async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/subscriptions$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      trainerSubscriptions.value = [];
    } else {
      final data = json.decode(response.body);
      trainerSubscriptions.value = List<Subscription>.from(
          data['subscriptions'].map((sub) => Subscription.fromJSON(sub)));
    }
  } catch (e) {
    throw e;
  }
}

Future<void> fetchMemberSubscriptions(int? memberId) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/$memberId/subscriptions');
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      subscriptions.value = [];
    } else {
      final data = json.decode(response.body);
      subscriptions.value = List<Subscription>.from(
          data['subscriptions'].map((sub) => Subscription.fromJSON(sub)));
    }
  } catch (e) {
    throw e;
  }
}

Future<void> fetchMemberBookings(int? memberId) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/$memberId/bookings');
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      bookings.value = [];
    } else {
      final data = json.decode(response.body);
      if (data['bookings'] == null)
        bookings.value = [];
      else
        bookings.value = List<Booking>.from(
            data['bookings'].map((booking) => Booking.fromJSON(booking)));
    }
  } catch (e) {
    throw e;
  }
}

Future<String> addToMemberShoppingCart(int memberId, data) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/$memberId/shoppingCart$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.post(
      url,
      headers: {
        'X-WP-Nonce': user_repo.currentUser.value.nonce!,
        'Cookie': user_repo.currentUser.value.cookie!,
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw response.body;
    } else {
      final data = json.decode(response.body);
      return data["message"];
    }
  } catch (e) {
    throw e;
  }
}

Future<String> cancelMemberShoppingCartItem(
  int memberId,
  int shoppingCartId,
  int shoppingCartItemSubscriptionId,
) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/$memberId/shoppingCart/$shoppingCartId/items/$shoppingCartItemSubscriptionId$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.delete(
      url,
      headers: {
        'X-WP-Nonce': user_repo.currentUser.value.nonce!,
        'Cookie': user_repo.currentUser.value.cookie!,
      },
    );

    if (response.statusCode != 200) {
      throw response.body;
    } else {
      final data = json.decode(response.body);
      return data["message"];
    }
  } catch (e) {
    throw e;
  }
}

Future<void> createSubscription(int? memberId, data) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/$memberId/subscriptions$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.post(
      url,
      headers: {
        'X-WP-Nonce': user_repo.currentUser.value.nonce!,
        'Cookie': user_repo.currentUser.value.cookie!,
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw response.body;
    } else {
      await Future.wait(
          [fetchMemberSubscriptions(memberId), fetchTrainerSubscriptions()]);
    }
  } catch (e) {
    throw e;
  }
}

Future<Subscription> fetchSubscriptionDetail(
  int? memberId,
  int? subscriptionId,
  bool? mine,
) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/${mine == false ? 'socities/$societyId/members/$memberId' : 'my'}/subscriptions/$subscriptionId$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      throw response.body;
    } else {
      final data = json.decode(response.body);
      return Subscription.fromJSON(data);
    }
  } catch (e) {
    throw e;
  }
}

Future<String> deleteSubscription(
  int? memberId,
  int? subscriptionId,
) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/$memberId/subscriptions/$subscriptionId$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.delete(
      url,
      headers: {
        'X-WP-Nonce': user_repo.currentUser.value.nonce!,
        'Cookie': user_repo.currentUser.value.cookie!,
      },
    );

    if (response.statusCode != 200 && response.statusCode != 206) {
      return response.body;
    } else {
      await Future.wait(
          [fetchMemberSubscriptions(memberId), fetchTrainerSubscriptions()]);
    }
  } catch (e) {
    throw e;
  }
  return 'true';
}

Future<String> saveSubscriptionDetail(
    int? memberId, int? subscriptionId, data) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/$memberId/subscriptions/$subscriptionId$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.put(
      url,
      headers: {
        'X-WP-Nonce': user_repo.currentUser.value.nonce!,
        'Cookie': user_repo.currentUser.value.cookie!,
        'Content-Type': 'application/json'
      },
      body: json.encode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 206) {
      return response.body;
    } else {
      await Future.wait(
          [fetchMemberSubscriptions(memberId), fetchTrainerSubscriptions()]);
    }
  } catch (e) {
    throw e;
  }
  return 'true';
}

Future<void> fetchMySubscriptions() async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/my/subscriptions$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      mySubscriptions.value = [];
    } else {
      final data = json.decode(response.body);
      mySubscriptions.value = List<Subscription>.from(data['subscriptions']
          .map((sub) => Subscription.fromJSON(sub, bMine: true)));
      mySubscriptions.notifyListeners();
    }
  } catch (e) {
    throw e;
  }
}

Future<void> fetchMyBookings() async {
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/my/bookings$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      bookings.value = [];
    } else {
      final data = json.decode(response.body);
      if (data['bookings'] == null)
        myBookings.value = [];
      else
        myBookings.value = List<Booking>.from(
            data['bookings'].map((booking) => Booking.fromJSON(booking)));
      myBookings.notifyListeners();
    }
  } catch (e) {
    throw e;
  }
}
