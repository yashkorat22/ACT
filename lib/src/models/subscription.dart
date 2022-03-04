// import '../models/media.dart';

class Subscription {
  int? societyId;
  int? permissionSociety;
  String? ownerFullName;
  int? memberId;
  String? memberFirstName;
  String? memberLastName;
  String? avatarUrl;
  int? subscriptionId;
  String? subscriptionStartDate;
  String? subscriptionEndDate;
  int? subscriptionState;
  String? subscriptionStateText;
  int? subscriptionStateOverwrite;
  int? subscriptionPaymentId;
  int? subscriptionPaid;
  String? subscriptionPaidText;
  int? subscriptionMaxCount;
  int? subscriptionCount;
  bool? subscriptionOverbooked;
  int? participationUncovered;
  int? shoppingCartId;
  int? shoppingCartItemsSubscriptionId;
  bool? mine;

  Subscription();

  Subscription.fromJSON(Map<String, dynamic> jsonMap, {bool? bMine = false}) {
    try {
      societyId = jsonMap['society_id'] ?? 0;
      permissionSociety = jsonMap['permission_society'] ?? 0;
      ownerFullName = jsonMap['owner_full_name'] ?? '';
      memberId = jsonMap['member_id'] ?? 0;
      memberFirstName = jsonMap['member_first_name'] ?? '';
      memberLastName = jsonMap['member_last_name'] ?? '';
      avatarUrl = jsonMap['avatar_url'] ?? '';
      subscriptionId = jsonMap['subscription_id'] ?? 0;
      subscriptionStartDate = jsonMap['subscription_start_date'] ?? '';
      subscriptionEndDate = jsonMap['subscription_end_date'] ?? '';
      subscriptionState = jsonMap['subscription_state'] ?? 0;
      subscriptionStateText = jsonMap['subscription_state_text'] ?? '';
      subscriptionStateOverwrite = jsonMap['subscription_state_overwrite'] ?? 0;
      subscriptionPaymentId = jsonMap['subscription_payment_id'] ?? 0;
      subscriptionPaid = jsonMap['subscription_paid'] ?? 0;
      subscriptionPaidText = jsonMap['subscription_paid_text'] ?? '';
      subscriptionMaxCount = jsonMap['subscription_max_count'] ?? 0;
      subscriptionCount = jsonMap['subscription_count'] ?? 0;
      subscriptionOverbooked = jsonMap['subscription_overbooked'] ?? false;
      participationUncovered = jsonMap['participation_uncovered'] ?? 0;
      shoppingCartId = jsonMap['shopping_cart_id'] ?? 0;
      shoppingCartItemsSubscriptionId =
          jsonMap['shopping_cart_items_subscription_id'] ?? 0;
      mine = bMine;
    } catch (e) {
      print(e.toString());
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["society_id"] = societyId;
    map["member_id"] = memberId;

    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    return map.toString();
  }
}
