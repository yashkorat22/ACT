// import '../models/media.dart';

class Booking {
  int? participationId;
  int? permissionSociety;
  int? societyId;
  String? ownerFullName;
  int? memberId;
  int? classId;
  String? className;
  int? eventId;
  String? eventName;
  String? eventDateTimePlan;
  String? eventDateTimeReplace;
  int? participationStatusId;
  String? participationStatusName;
  int? subscriptionId;
  int? paymentId;
  int? shoppingCartId;
  int? shoppingCartItemsParticipationId;
  int? shoppingCartItemsSubscriptionId;

  Booking();

  Booking.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      participationId = jsonMap['participation_id'] ?? 0;
      societyId = jsonMap['society_id'] ?? 0;
      permissionSociety = jsonMap['permission_society'] ?? 0;
      ownerFullName = jsonMap['owner_full_name'] ?? '';
      memberId = jsonMap['member_id'] ?? 0;
      classId = jsonMap['class_id'] ?? 0;
      eventDateTimePlan = jsonMap['event_dateTimePlan'] ?? '';
      eventDateTimeReplace = jsonMap['event_dateTimeReplace'] ?? '';
      className = jsonMap['class_name'] ?? '';
      eventId = jsonMap['event_id'] ?? 0;
      eventName = jsonMap['event_name'] ?? '';
      participationStatusId = jsonMap['participation_status_id'] ?? 0;
      participationStatusName = jsonMap['participation_status_name'] ?? '';
      subscriptionId = jsonMap['subscription_id'] ?? 0;
      paymentId = jsonMap['payment_id'] ?? null;
      shoppingCartId = jsonMap['shopping_cart_id'] ?? 0;
      shoppingCartItemsParticipationId =
          jsonMap['shopping_cart_items_participation_id'] ?? 0;
      shoppingCartItemsSubscriptionId =
          jsonMap['shopping_cart_items_subscription_id'] ?? 0;
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
