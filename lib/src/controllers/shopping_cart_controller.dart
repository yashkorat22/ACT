import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../helpers/helper.dart';
import '../models/shoppingCartDetail.dart';
import '../repository/shopping_cart_repository.dart' as shopping_cart_repo;
import '../repository/user_repository.dart' as user_repo;

class ShoppingCartController extends ControllerMVC {
  GlobalKey<ScaffoldState>? scaffoldKey;
  GlobalKey<FormState>? shoppingCartFormKey;
  OverlayEntry? loader;
  int currencyId = 1;
  ShoppingCartDetail shoppingCartDetail = ShoppingCartDetail.fromJSON({});

  BuildContext? context;

  ShoppingCartController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
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

  Future<void> getTrainerShoppingCarts() async {
    try {
      await shopping_cart_repo.fetchTrainerShoppingCarts();
    } catch (e) {
      print(e);
    }
  }

  Future<void> getShoppingCartDetail(int? memberId, int? shoppingCartId) async {
    try {
      shoppingCartDetail = await shopping_cart_repo.fetchShoppingCartDetail(
          memberId, shoppingCartId);
      currencyId = user_repo.currencies.value.indexWhere((currency) =>
          currency.name ==
          shoppingCartDetail.shoppingCart.shoppingCartCurrencyText);
      if (currencyId == -1) {
        currencyId = 0;
      }
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<bool> deleteShoppingCart(int? memberId, int? shoppingCartId) async {
    bool result = false;
    Overlay.of(context!)!.insert(loader!);
    try {
      final response =
          await shopping_cart_repo.deleteShoppingCart(memberId, shoppingCartId);
      if (response != 'true') {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        result = true;
      }
    } catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text((e as dynamic).message),
      ));
    } finally {
      Helper.hideLoader(loader);
    }
    return result;
  }

  Future<void> saveShoppingCartDetail() async {
    Overlay.of(context!)!.insert(loader!);
    try {
      final response = await shopping_cart_repo.saveShoppingCartDetail(
        shoppingCartDetail.shoppingCart.memberId,
        shoppingCartDetail.shoppingCart.shoppingCartId,
        {},
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

  Future<bool> deleteShoppingCartItem(int? shoppingCartItemId) async {
    bool result = false;
    Overlay.of(context!)!.insert(loader!);
    try {
      final response = await shopping_cart_repo.deleteShoppingCartItem(
          shoppingCartDetail.shoppingCart.memberId,
          shoppingCartDetail.shoppingCart.shoppingCartId,
          shoppingCartItemId);
      if (response != 'true') {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        result = true;
        shoppingCartDetail.items.removeWhere((item) => item.shoppingCartItemId == shoppingCartItemId);
        setState(() {});
        if (shoppingCartDetail.items.length == 0) {
          Navigator.of(context!).pop();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text((e as dynamic).message),
      ));
    } finally {
      Helper.hideLoader(loader);
    }
    return result;
  }

  Future<bool> setAsCashPaid(totalPrice, currencyId) async {
    bool result = false;
    Overlay.of(context!)!.insert(loader!);
    try {
      final response = await shopping_cart_repo.setAsCashPaid(
          shoppingCartDetail.shoppingCart.memberId,
          shoppingCartDetail.shoppingCart.shoppingCartId, {
        "price": totalPrice,
        "currency_id": currencyId,
      });
      if (response != 'true') {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        result = true;
        await getShoppingCartDetail(
          shoppingCartDetail.shoppingCart.memberId,
          shoppingCartDetail.shoppingCart.shoppingCartId,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text((e as dynamic).message),
      ));
    } finally {
      Helper.hideLoader(loader);
    }
    return result;
  }

  Future<bool> saveCartItemPrice(shoppingCartItemId, currencyId, price) async {
    bool result = false;
    try {
      final response = await shopping_cart_repo.saveCartItemPrice(
          shoppingCartDetail.shoppingCart.memberId,
          shoppingCartDetail.shoppingCart.shoppingCartId,
          shoppingCartItemId, {
        "currency_id": currencyId,
        "price": price,
      });
      if (response != 'true') {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        result = true;
      }
    } catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text((e as dynamic).message),
      ));
    } finally {}
    return result;
  }
}
