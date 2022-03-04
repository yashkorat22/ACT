import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/shoppingCart.dart';
import '../../models/currency.dart';

import '../../controllers/shopping_cart_controller.dart';

import '../../elements/ShoppingCartSubscriptionWidget.dart';
import '../../elements/ShoppingCartParticipationWidget.dart';

import '../../repository/user_repository.dart' as user_repo;

class ManageSingleShoppingCartWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;
  final ShoppingCart? shoppingCartInfo;

  ManageSingleShoppingCartWidget(
      {Key? key, this.parentScaffoldKey, this.shoppingCartInfo})
      : super(key: key);
  @override
  _ManageSingleShoppingCartWidgetState createState() =>
      _ManageSingleShoppingCartWidgetState();
}

class _ManageSingleShoppingCartWidgetState
    extends StateMVC<ManageSingleShoppingCartWidget> {
  late ShoppingCartController _con;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  List<Currency> currencies = [];

  _ManageSingleShoppingCartWidgetState() : super(ShoppingCartController()) {
    _con = controller as ShoppingCartController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    currencies = user_repo.currencies.value;
    user_repo.currencies.addListener(() {
      setState(() {
        currencies = user_repo.currencies.value;
      });
    });
    _initData();
  }

  Future<void> _initData() async {
    setState(() => isLoading = true);
    try {
      await _getData();
    } catch (e) {
      print(e.toString());
    }
    setState(() => isLoading = false);
  }

  Future<void> _getData() async {
    await _con.getShoppingCartDetail(widget.shoppingCartInfo!.memberId,
        widget.shoppingCartInfo!.shoppingCartId);
  }

  void _onRefresh() async {
    try {
      await _getData();
    } catch (e) {
      print(e.toString());
    }

    _refreshController.refreshCompleted();
  }

  Future<void> _handleDeleteShoppingCartItem(shoppingCartItemId) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text( AppLocalizations.of(context)!.appDialogTitleConfirmation ),              // Confirmation
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text( AppLocalizations.of(context)!.shoppingCartRemoveShoppingCartItemConfirmText ), // Are you sure to delete this shopping cart item?
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text( AppLocalizations.of(context)!.appButtonOk ),                         // Ok
              onPressed: () {
                Navigator.of(context).pop();
                _con.deleteShoppingCartItem(shoppingCartItemId);
              },
            ),
            TextButton(
              child: Text( AppLocalizations.of(context)!.appButtonCancel ),                     // Cancel
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSetAsCashPaid() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text( AppLocalizations.of(context)!.appDialogTitleConfirmation ),              // Confirmation
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
            AppLocalizations.of(context)!.shoppingCartConfirmAsCashPaid +'\n' +_con.shoppingCartDetail.getPriceTotal()!.toStringAsFixed(2) +' ' +currencies[_con.currencyId].name.toString() ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text( AppLocalizations.of(context)!.appButtonOk ),                         // OK
              onPressed: () {
                Navigator.of(context).pop();
                _con.setAsCashPaid(_con.shoppingCartDetail.getPriceTotal(),
                    currencies[_con.currencyId].value);
              },
            ),
            TextButton(
              child: Text( AppLocalizations.of(context)!.appButtonCancel ),                     // Cancel
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _form() {
    return Form(
      key: _con.shoppingCartFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 62,
            backgroundColor: Theme.of(context).accentColor,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(115),
                child: CachedNetworkImage(
                  width: 118,
                  height: 118,
                  fit: BoxFit.cover,
                  imageUrl: _con.shoppingCartDetail.shoppingCart.avatarUrl!,
                  httpHeaders: {
                    'X-WP-Nonce': user_repo.currentUser.value.nonce!,
                    'Cookie': user_repo.currentUser.value.cookie!,
                  },
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Center(
                          child: CircularProgressIndicator(
                              value: downloadProgress.progress)),
                  errorWidget: (context, url, error) => Container(
                      child: Icon(Icons.person,
                          size: 80, color: Theme.of(context).primaryColor),
                      color: Theme.of(context).accentColor),
                )),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            _con.shoppingCartDetail.shoppingCart.memberFirstName! +
                " " +
                _con.shoppingCartDetail.shoppingCart.memberLastName!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24),
          ),
          const Divider(
            height: 30,
            thickness: 5,
          ),
          Text( AppLocalizations.of(context)!.shoppingCartTotal, textAlign: TextAlign.center),  // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _con.shoppingCartDetail.shoppingCart.shoppingCartPaymentId! > 0
                  ? CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.greenAccent,
                      child: Icon(
                        Icons.attach_money,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  : CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.redAccent,
                      child: Icon(
                        Icons.money_off,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
              Container(
                width: 150,
                child: _con.shoppingCartDetail.shoppingCart
                            .shoppingCartPaymentId! >
                        0
                    ? TextFormField(
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.shoppingCartCurrency,        // Currency
                          labelStyle:
                              TextStyle(color: Theme.of(context).accentColor),
                          contentPadding: EdgeInsets.all(12),
                          filled: true,
                          fillColor:
                              Theme.of(context).hintColor.withOpacity(0.05),
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                        ),
                        initialValue: currencies.length > _con.currencyId
                            ? currencies[_con.currencyId].name
                            : null,
                        onTap: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                        onChanged: (String newValue) {
                          _con.currencyId = currencies.indexWhere(
                              (currency) => currency.name == newValue);
                          setState(() {});
                        },
                        readOnly: true,
                      )
                    : DropdownButtonFormField(
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.shoppingCartCurrency,        // Currency
                          labelStyle:
                              TextStyle(color: Theme.of(context).accentColor),
                          contentPadding: EdgeInsets.all(12),
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                        ),
                        value: currencies.length > _con.currencyId
                            ? currencies[_con.currencyId].name
                            : null,
                        onTap: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                        onChanged: (String? newValue) {
                          _con.currencyId = currencies.indexWhere(
                              (currency) => currency.name == newValue);
                          setState(() {});
                        },
                        items: currencies
                            .map<DropdownMenuItem<String>>((Currency currency) {
                          return DropdownMenuItem<String>(
                            value: currency.name,
                            child: Text(currency.name!),
                          );
                        }).toList(),
                      ),
              ),
              Text(
                _con.shoppingCartDetail.getPriceTotal()!.toStringAsFixed(2),
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // TextButton(
              //   child: Text('Send Invoice',
              //       style: TextStyle(color: Theme.of(context).primaryColor)),
              //   style: ButtonStyle(
              //     backgroundColor: MaterialStateProperty.resolveWith<Color>(
              //       (Set<MaterialState> states) {
              //         if (states.contains(MaterialState.pressed))
              //           return Theme.of(context).accentColor.withOpacity(0.5);
              //         if (states.contains(MaterialState.disabled))
              //           return Theme.of(context).backgroundColor;
              //         return Theme.of(context).accentColor;
              //       },
              //     ),
              //     minimumSize: MaterialStateProperty.all<Size>(
              //       Size(100, 40),
              //     ),
              //   ),
              //   onPressed: _con.shoppingCartDetail.shoppingCart
              //               .shoppingCartPaymentId! >
              //           0
              //       ? null
              //       : () {},
              // ),
              // TextButton(
              //   child: Text('Send Receipt',
              //       style: TextStyle(color: Theme.of(context).primaryColor)),
              //   style: ButtonStyle(
              //     backgroundColor: MaterialStateProperty.resolveWith<Color>(
              //       (Set<MaterialState> states) {
              //         if (states.contains(MaterialState.pressed))
              //           return Theme.of(context).accentColor.withOpacity(0.5);
              //         if (states.contains(MaterialState.disabled))
              //           return Theme.of(context).backgroundColor;
              //         return Theme.of(context).accentColor;
              //       },
              //     ),
              //     minimumSize: MaterialStateProperty.all<Size>(
              //       Size(100, 40),
              //     ),
              //   ),
              //   onPressed: _con.shoppingCartDetail.shoppingCart
              //               .shoppingCartPaymentId! >
              //           0
              //       ? null
              //       : () {},
              // ),
              TextButton(
                child: Text( AppLocalizations.of(context)!.shoppingCartSetAsCashPaid,           // Set as cash paid
                    style: TextStyle(color: Theme.of(context).primaryColor)),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed))
                        return Theme.of(context).accentColor.withOpacity(0.5);
                      if (states.contains(MaterialState.disabled))
                        return Theme.of(context).backgroundColor;
                      return Theme.of(context).accentColor;
                    },
                  ),
                  minimumSize: MaterialStateProperty.all<Size>(
                    Size(100, 40),
                  ),
                ),
                onPressed: _con.shoppingCartDetail.shoppingCart
                            .shoppingCartPaymentId! >
                        0
                    ? null
                    : () {
                        _handleSetAsCashPaid();
                      },
              ),
            ],
          ),
          const Divider(
            height: 30,
            thickness: 5,
          ),
          ..._con.shoppingCartDetail.items
              .asMap()
              .map((index, item) {
                if (item.subscriptionId != 0) {
                  return MapEntry(
                      index,
                      ShoppingCartSubscriptionWidget(
                        subscriptionInfo: item,
                        onDelete: () {
                          _handleDeleteShoppingCartItem(
                              item.shoppingCartItemId);
                        },
                        onPriceChange: (newPrice) {
                          setState(() {
                            _con.shoppingCartDetail.items[index]
                                .shoppingCartPrice = newPrice;
                          });
                          _con.saveCartItemPrice(item.shoppingCartItemId,
                              currencies[_con.currencyId].value, newPrice);
                        },
                        disabled: _con.shoppingCartDetail.shoppingCart
                                    .shoppingCartPaymentId! >
                                0 ||
                            item.paymentId! > 0,
                      ));
                }
                if (item.participationId != 0) {
                  return MapEntry(
                      index,
                      ShoppingCartParticipationWidget(
                        participationInfo: item,
                        onDelete: () {
                          _handleDeleteShoppingCartItem(
                              item.shoppingCartItemId);
                        },
                        onPriceChange: (newPrice) {
                          setState(() {
                            _con.shoppingCartDetail.items[index]
                                .shoppingCartPrice = newPrice;
                          });
                          _con.saveCartItemPrice(item.shoppingCartItemId,
                              currencies[_con.currencyId].value, newPrice);
                        },
                        disabled: _con.shoppingCartDetail.shoppingCart
                                    .shoppingCartPaymentId! >
                                0 ||
                            item.paymentId! > 0,
                      ));
                }
                return MapEntry(
                  index,
                  null,
                );
              })
              .values
              .toList()
              .whereType<StatelessWidget>()
              .toList(),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        key: _con.scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/Home');
                },
                icon: Icon(
                  Icons.home,
                  size: 26.0,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back,
                color: Theme.of(context).primaryColor),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).accentColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.shoppingCartManageShoppingCart,                       // Manage ShoppingCart
            style: Theme.of(context).textTheme.headline6!.merge(
                  TextStyle(
                    letterSpacing: 1.3,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
          ),
        ),
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: ClassicHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Container(
                    decoration:
                        BoxDecoration(color: Theme.of(context).primaryColor),
                    padding: EdgeInsets.only(left: 25, right: 25, top: 25),
                    child: _form(),
                  ),
                ),
        ),
      ),
    );
  }
}
