import './shoppingCart.dart';
import './shoppingCartItem.dart';

class ShoppingCartDetail {
  late ShoppingCart shoppingCart;
  late List<ShoppingCartItem> items;

  ShoppingCartDetail();

  ShoppingCartDetail.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      shoppingCart = ShoppingCart.fromJSON(
          jsonMap["shoppingCart"] != null ? jsonMap["shoppingCart"] : {});
      items = List<ShoppingCartItem>.from(jsonMap["items"] != null
          ? jsonMap["items"].map((item) => ShoppingCartItem.fromJSON(item))
          : []);
    } catch (e) {
      print(e);
    }
  }

  double? getPriceTotal() {
    if (items.length == 0) return 0;
    return items
        .map((cartItem) => cartItem.shoppingCartPrice)
        .toList()
        .reduce((sum, itemPrice) => sum! + itemPrice!);
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["shoppingCart"] = shoppingCart.toMap();
    map["items"] = items.map((cartItem) => cartItem.toMap()).toList();

    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    return map.toString();
  }
}
