import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../helpers/helper.dart';
import '../models/subscription.dart';
import '../repository/subscription_repository.dart' as subscription_repo;

class SubscriptionController extends ControllerMVC {
  GlobalKey<ScaffoldState>? scaffoldKey;
  GlobalKey<FormState>? subscriptionFormKey;
  OverlayEntry? loader;
  int? templateId;
  String startDate = "";
  String endDate = "";
  int? maxCount = 12;
  bool addToShoppingCart = true;
  Subscription subscriptionInfo = Subscription.fromJSON({});
  BuildContext? context;

  SubscriptionController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();

    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();
    startDate = dateFormatter.format(now);
    final end_date = new DateTime(now.year, now.month + 2, now.day);
    endDate = dateFormatter.format(end_date);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    context = state!.context;
    loader = Helper.overlayLoader(context);
  }

  void showLoader() {
    Overlay.of(context!)!.insert(loader!);
  }

  void hideLoader() {
    Helper.hideLoader(loader);
  }

  Future<void> getTrainerSubscriptions() async {
    try {
      await subscription_repo.fetchTrainerSubscriptions();
    } catch (e) {
      print(e);
    }
  }

  Future<void> getMemberSubscriptions(int? memberId) async {
    try {
      await subscription_repo.fetchMemberSubscriptions(memberId);
    } catch (e) {
      print(e);
    }
  }

  Future<void> addToMemberShoppingCart(
      int memberId, int? subscriptionId, int? participationId) async {
    showLoader();
    try {
      final message =
          await (subscription_repo.addToMemberShoppingCart(memberId, {
        "subscription_id": subscriptionId,
        "participation_id": participationId,
      }));
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text(message),
      ));
      if (subscriptionId != null) {
        await Future.wait([
          subscription_repo.fetchMemberSubscriptions(memberId),
          subscription_repo.fetchTrainerSubscriptions()
        ]);
      }
      if (participationId != null) {
        await subscription_repo.fetchMemberBookings(memberId);
      }
    } catch (e) {
      print(e);
    }
    hideLoader();
  }

  Future<void> cancelMemberShoppingCartItem(
    int memberId,
    int shoppingCartId,
    int shoppingCartItemId,
    String cartItemType,
  ) async {
    showLoader();
    try {
      final message = await (subscription_repo.cancelMemberShoppingCartItem(
        memberId,
        shoppingCartId,
        shoppingCartItemId,
      ));
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text(message),
      ));
      if (cartItemType == "subscription") {
        await Future.wait([
          subscription_repo.fetchMemberSubscriptions(memberId),
          subscription_repo.fetchTrainerSubscriptions()
        ]);
      } else if (cartItemType == "booking") {
        await subscription_repo.fetchMemberBookings(memberId);
      }
    } catch (e) {
      print(e);
    }
    hideLoader();
  }

  Future<void> createSubscription(int? memberId) async {
    showLoader();
    try {
      await subscription_repo.createSubscription(memberId, {
        "start_date": startDate,
        "end_date": endDate,
        "max_count": maxCount,
        "addShoppingCart": addToShoppingCart,
      });
      Navigator.of(context!).pop();
    } catch (e) {
      print(e);
    } finally {
      hideLoader();
    }
  }

  Future<void> getSubscriptionDetail(int? memberId, int? subscriptionId,
      {bool? mine = false}) async {
    try {
      subscriptionInfo = await subscription_repo.fetchSubscriptionDetail(
          memberId, subscriptionId, mine);
      setState(() {
        startDate = subscriptionInfo.subscriptionStartDate!;
        endDate = subscriptionInfo.subscriptionEndDate!;
        maxCount = subscriptionInfo.subscriptionMaxCount;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteMemberSubscription() async {
    Overlay.of(context!)!.insert(loader!);
    try {
      final response = await subscription_repo.deleteSubscription(
          subscriptionInfo.memberId, subscriptionInfo.subscriptionId);
      if (response != 'true') {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        Navigator.of(scaffoldKey!.currentContext!).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text((e as dynamic).message),
      ));
    } finally {
      Helper.hideLoader(loader);
    }
  }

  Future<void> saveSubscriptionDetail() async {
    Overlay.of(context!)!.insert(loader!);
    try {
      final response = await subscription_repo.saveSubscriptionDetail(
        subscriptionInfo.memberId,
        subscriptionInfo.subscriptionId,
        {
          "start_date": startDate,
          "end_date": endDate,
          "max_count": maxCount,
          "state_overwrite": subscriptionInfo.subscriptionStateOverwrite,
          "shopping_cart_id": subscriptionInfo.shoppingCartId,
          "shopping_cart_items_subscription_id":
              subscriptionInfo.shoppingCartItemsSubscriptionId,
        },
      );
      if (response != 'true') {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        Navigator.of(scaffoldKey!.currentContext!).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text((e as dynamic).message),
      ));
    } finally {
      Helper.hideLoader(loader);
    }
  }

  Future<void> getMemberBookings(int? memberId) async {
    try {
      await subscription_repo.fetchMemberBookings(memberId);
    } catch (e) {
      print(e);
    }
  }
}
