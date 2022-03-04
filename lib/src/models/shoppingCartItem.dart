// import '../models/media.dart';

class ShoppingCartItem {
  int? shoppingCartItemId;
  int? paymentId;
  double? shoppingCartPrice;

  // subscription
  int? subscriptionId;
  String? subscriptionStartDate;
  String? subscriptionEndDate;
  int? subscriptionCount;
  int? subscriptionMaxCount;

  // participation
  int? participationId;
  String? className;
  String? eventName;
  String? eventDateTimeReplace;

  ShoppingCartItem();

  ShoppingCartItem.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      // subscription
      subscriptionId =
          jsonMap['subscription_id'] != null ? jsonMap['subscription_id'] : 0;
      subscriptionStartDate = jsonMap['subscription_start_date'] != null
          ? jsonMap['subscription_start_date']
          : '';
      subscriptionEndDate = jsonMap['subscription_end_date'] != null
          ? jsonMap['subscription_end_date']
          : '';
      subscriptionCount = jsonMap['subscription_count'] != null
          ? jsonMap['subscription_count']
          : 0;
      subscriptionMaxCount = jsonMap['subscription_max_count'] != null
          ? jsonMap['subscription_max_count']
          : 0;

      // participation
      participationId =
          jsonMap['participation_id'] != null ? jsonMap['participation_id'] : 0;
      className = jsonMap['class_name'] != null ? jsonMap['class_name'] : '';
      eventName = jsonMap['event_name'] != null ? jsonMap['event_name'] : '';
      eventDateTimeReplace = jsonMap['event_dateTimeReplace'] != null
          ? jsonMap['event_dateTimeReplace']
          : '';

      paymentId = jsonMap['payment_id'] != null ? jsonMap['payment_id'] : 0;
      shoppingCartPrice = jsonMap['shopping_cart_price'] != null
          ? jsonMap['shopping_cart_price'].toDouble()
          : 0;
      if (subscriptionId != 0 && shoppingCartPrice == 0) {
        shoppingCartPrice = 240.0;
      } else if (participationId != 0 && shoppingCartPrice == 0) {
        shoppingCartPrice = 25.0;
      }
      shoppingCartItemId = jsonMap['shopping_cart_item_id'] != null
          ? jsonMap['shopping_cart_item_id']
          : 0;
    } catch (e) {
      print(e);
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["shopping_cart_item_id"] = shoppingCartItemId;
    map["payment_id"] = paymentId;
    map["shopping_cart_price"] = shoppingCartPrice;

    // subscription
    map["subscription_id"] = subscriptionId;
    map["subscription_start_date"] = subscriptionStartDate;
    map["subscription_end_date"] = subscriptionEndDate;
    map["subscription_count"] = subscriptionCount;
    map["subscription_max_count"] = subscriptionMaxCount;

    // participation
    map["participation_id"] = participationId;
    map["class_name"] = className;
    map["event_name"] = eventName;
    map["event_dateTimeReplace"] = eventDateTimeReplace;
    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    return map.toString();
  }
}
