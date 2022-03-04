// import '../models/media.dart';

class ShoppingCart {
  int? societyId;
  int? memberId;
  String? memberFirstName;
  String? memberLastName;
  String? avatarUrl;
  int? shoppingCartId;
  int? shoppingCartPaymentId;
  String? shoppingCartCurrencyText;
  double? shoppingCartPrice;
  int? shoppingCartCount;

  ShoppingCart();

  ShoppingCart.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      societyId = jsonMap['society_id'] != null ? jsonMap['society_id'] : 0;
      memberId = jsonMap['member_id'] != null ? jsonMap['member_id'] : 0;
      memberFirstName = jsonMap['member_first_name'] != null
          ? jsonMap['member_first_name']
          : '';
      memberLastName = jsonMap['member_last_name'] != null
          ? jsonMap['member_last_name']
          : '';
      avatarUrl = jsonMap['avatar_url'] != null ? jsonMap['avatar_url'] : '';
      shoppingCartId =
          jsonMap['shopping_cart_id'] != null ? jsonMap['shopping_cart_id'] : 0;
      shoppingCartPaymentId = jsonMap['shopping_cart_payment_id'] != null
          ? jsonMap['shopping_cart_payment_id']
          : 0;
      shoppingCartCurrencyText =
          jsonMap['shopping_cart_currency_text'] != null
              ? jsonMap['shopping_cart_currency_text']
              : '';
      shoppingCartPrice = jsonMap['shopping_cart_price'] != null
          ? jsonMap['shopping_cart_price'].toDouble()
          : 0;
      shoppingCartCount = jsonMap['shopping_cart_count'] != null
          ? jsonMap['shopping_cart_count']
          : 0;
    } catch (e) {
      print(e.toString());
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["society_id"] = societyId;
    map["member_id"] = memberId;
    map["member_first_name"] = memberFirstName;
    map["member_last_name"] = memberLastName;
    map["avatar_url"] = avatarUrl;
    map["shopping_cart_price"] = shoppingCartPrice;

    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    return map.toString();
  }
}
