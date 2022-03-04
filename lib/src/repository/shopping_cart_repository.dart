import 'dart:convert';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';

import 'user_repository.dart' as user_repo;

import '../helpers/helper.dart';

import '../models/shoppingCart.dart';
import '../models/shoppingCartDetail.dart';

int editId = -1;
ValueNotifier<int> createdTrainerShoppingCartId = new ValueNotifier(-1);
ValueNotifier<int> deletedTrainerShoppingCartId = new ValueNotifier(-1);

ValueNotifier<List<ShoppingCart>> trainerShoppingCarts = new ValueNotifier([]);
ValueNotifier<List<ShoppingCart>> shoppingCarts = new ValueNotifier([]);

Future<void> fetchTrainerShoppingCarts() async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/shoppingCart$apiLocaleSuffix');
  final client = new http.Client();

  try {
    final response = await client.get(url, headers: {
      'X-WP-Nonce': user_repo.currentUser.value.nonce!,
      'Cookie': user_repo.currentUser.value.cookie!,
    });

    if (response.statusCode != 200) {
      trainerShoppingCarts.value = [];
    } else {
      final data = json.decode(response.body);
      trainerShoppingCarts.value = List<ShoppingCart>.from(
          data['shoppingCarts'].map((sub) => ShoppingCart.fromJSON(sub)));
    }
  } catch (e) {
    throw e;
  }
}

// Future<void> fetchMemberShoppingCarts(int memberId) async {
//   final int societyId = user_repo.currentUserSocieties.value
//       .firstWhere((so) => so.is_primary == true)
//       .id;
//   final Uri url = Uri.parse(
//       '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/$memberId/shoppingCarts$apiLocaleSuffix');
//   final client = new http.Client();
//
//   try {
//     final response = await client.get(url, headers: {
//       'X-WP-Nonce': user_repo.currentUser.value.nonce,
//       'Cookie': user_repo.currentUser.value.cookie,
//     });
//
//     if (response.statusCode != 200) {
//       shoppingCarts.value = [];
//     } else {
//       final data = json.decode(response.body);
//       shoppingCarts.value = List<ShoppingCart>.from(
//           data['shoppingCarts'].map((sub) => ShoppingCart.fromJSON(sub)));
//     }
//     shoppingCarts.notifyListeners();
//   } catch (e) {
//     throw e;
//   }
// }

Future<void> createShoppingCart(int memberId, data) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/$memberId/shoppingCarts$apiLocaleSuffix');
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
      await Future.wait([fetchTrainerShoppingCarts()]);
    }
  } catch (e) {
    throw e;
  }
}

Future<ShoppingCartDetail> fetchShoppingCartDetail(
    int? memberId, int? shoppingCartId) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/$memberId/shoppingCart/$shoppingCartId$apiLocaleSuffix');
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
      return ShoppingCartDetail.fromJSON(data);
    }
  } catch (e) {
    throw e;
  }
}

Future<String> deleteShoppingCart(
  int? memberId,
  int? shoppingCartId,
) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/$memberId/shoppingCart/$shoppingCartId$apiLocaleSuffix');
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
      await Future.wait([fetchTrainerShoppingCarts()]);
    }
  } catch (e) {
    throw e;
  }
  return 'true';
}

Future<String> saveShoppingCartDetail(
    int? memberId, int? shoppingCartId, data) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/$memberId/shoppingCarts/$shoppingCartId$apiLocaleSuffix');
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
      await Future.wait([fetchTrainerShoppingCarts()]);
    }
  } catch (e) {
    throw e;
  }
  return 'true';
}

Future<String> deleteShoppingCartItem(
    int? memberId, int? shoppingCartId, int? shoppingCartItemId) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/$memberId/shoppingCart/$shoppingCartId/items/$shoppingCartItemId$apiLocaleSuffix');
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
      await Future.wait([fetchTrainerShoppingCarts()]);
    }
  } catch (e) {
    throw e;
  }
  return 'true';
}

Future<String> setAsCashPaid(memberId, shoppingCartId, data) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/$memberId/shoppingCart/$shoppingCartId$apiLocaleSuffix');
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

    if (response.statusCode >= 300) {
      return response.body;
    } else {
      await Future.wait([fetchTrainerShoppingCarts()]);
    }
  } catch (e) {
    throw e;
  }
  return 'true';
}

Future<String> saveCartItemPrice(
    memberId, shoppingCartId, shoppingCartItemId, data) async {
  final int? societyId = user_repo.currentUserSocieties.value
      .firstWhere((so) => so.isPrimary == true)
      .id;
  final Uri url = Uri.parse(
      '${GlobalConfiguration().getValue('api_base_url')}/socities/$societyId/members/$memberId/shoppingCart/$shoppingCartId/items/$shoppingCartItemId$apiLocaleSuffix');
  final client = new http.Client();

  try {
    debugPrint(url.toString());
    final response = await client.put(
      url,
      headers: {
        'X-WP-Nonce': user_repo.currentUser.value.nonce!,
        'Cookie': user_repo.currentUser.value.cookie!,
        'Content-Type': 'application/json'
      },
      body: json.encode(data),
    );

    debugPrint(response.statusCode.toString());
    debugPrint(response.body);

    if (response.statusCode >= 300) {
      return response.body;
    } else {
      await Future.wait([fetchTrainerShoppingCarts()]);
    }
  } catch (e) {
    throw e;
  }
  return 'true';
}
