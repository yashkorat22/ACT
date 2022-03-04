import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/shopping_cart_controller.dart';

import '../../elements/TrainerShoppingCartWidget.dart';
import '../../elements/HelpButtonWidget.dart';

import '../../helpers/helper.dart';

import '../../repository/user_repository.dart' as user_repo;
import '../../repository/shopping_cart_repository.dart' as shopping_cart_repo;

class ShoppingCartsWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  ShoppingCartsWidget({Key? key, this.parentScaffoldKey}) : super(key: key);
  @override
  _ShoppingCartsWidgetState createState() => _ShoppingCartsWidgetState();
}

class _ShoppingCartsWidgetState extends StateMVC<ShoppingCartsWidget> {
  late ShoppingCartController _con;
  bool isFetching = false;
  bool isTrainerShoppingCartFetching = false;
  bool isMemberShoppingCartFetching = false;
  int? societyId;
  String searchText = '';

  final focusKeyMember = new GlobalKey();
  final focusKeyTraining = new GlobalKey();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  _ShoppingCartsWidgetState() : super(ShoppingCartController()) {
    _con = controller as ShoppingCartController;
    societyId = user_repo.currentUserSocieties.value
        .firstWhere((so) => so.isPrimary == true)
        .id;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initData();
    shopping_cart_repo.trainerShoppingCarts.addListener(() {
      setState(() {});
    });

    SharedPreferences.getInstance().then((instance) {
      if (!(instance.getBool("invoices_visited") ?? false)) {
        Future.delayed(const Duration(seconds: 1), () {
          instance.setBool("invoices_visited", true);
          Helper.of(context).showHintDialog(Helper.homeHelp());
        });
      }
    });
  }

  void _initData() async {
    setState(() => isFetching = true);
    await _getData();
    setState(() => isFetching = false);
  }

  void _onRefresh() async {
    try {
      await _getData();
    } catch (e) {
      print(e.toString());
    }

    _refreshController.refreshCompleted();
  }

  Future<void> _getData() async {
    var futures = <Future>[];
    // futures.add(getMemberShoppingCarts());
    futures.add(getTrainerShoppingCarts());
    await Future.wait(futures);
  }

  Future<void> getTrainerShoppingCarts() async {
    await _con.getTrainerShoppingCarts();
  }

  Future<void> _showDeleteShoppingCartDialog(int? memberId, int? shoppingCartId) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text( AppLocalizations.of(context)!.appDialogTitleConfirmation ),              // Confirmation
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text( AppLocalizations.of(context)!.shoppingCartRemoveShoppingCartConfirmText ), // Are you sure to delete this shopping cart?
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                Navigator.of(context).pop();
                if (await _con.deleteShoppingCart(memberId, shoppingCartId)) {
                    shopping_cart_repo.trainerShoppingCarts.value
                        .removeWhere((shoppingCartInfo) => shoppingCartInfo.shoppingCartId == shoppingCartId);
                }
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

  void deleteTrainerShoppingCart(int? memberId, int? shoppingCartId) {
    _showDeleteShoppingCartDialog(memberId, shoppingCartId);
  }

  Widget _trainerShoppingCartList() {
    return Stack(
      children: [
        Column(
          children: [
            TextFormField(
              onChanged: (txt) {
                setState(() => searchText = txt);
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                hintText: AppLocalizations.of(context)!.appInputSearch,                             // Search...
                hintStyle:
                    TextStyle(color: Theme.of(context).hintColor.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).hintColor),
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).focusColor.withOpacity(0.2))),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).focusColor.withOpacity(0.5))),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).focusColor.withOpacity(0.2)),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: shopping_cart_repo.trainerShoppingCarts.value
                      .where((shoppingCartInfo) =>
                          (shoppingCartInfo.memberFirstName! +
                                  ' ' +
                                  shoppingCartInfo.memberLastName!)
                              .toLowerCase()
                              .contains(searchText.toLowerCase()))
                      .map(
                        (shoppingCartInfo) => TrainerShoppingCartWidget(
                          key: Key(shoppingCartInfo.memberId.toString()),
                          shoppingCartInfo: shoppingCartInfo,
                          onDelete: () {
                            deleteTrainerShoppingCart(shoppingCartInfo.memberId, shoppingCartInfo.shoppingCartId);
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
        Positioned(
            left: 0,
            bottom: 20,
            child: HelpButtonWidget(
              showHelpDialog: () => Helper.of(context)
                  .showHintDialog(Helper.homeHelp()),
              color: Theme.of(context).accentColor,
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacementNamed('/Home');
        return true;
      },
      child: Scaffold(
        key: _con.scaffoldKey,
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.home, color: Theme.of(context).primaryColor),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/Home');
            },
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).accentColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.shoppingCartTitle,                                    // Invoices
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
            child: DefaultTabController(
              length: 2,
              child: Scaffold(
                body: Column(
                  children: [
                    if (!isFetching)
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                        ),
                        child: TabBar(
                          labelColor: Theme.of(context).accentColor,
                          unselectedLabelColor: Theme.of(context).hintColor,
                          tabs: [
                            Tab(child: Text( AppLocalizations.of(context)!.shoppingCartTabMember )),  // Member
                            Tab(child: Text( AppLocalizations.of(context)!.shoppingCartTabTrainer )), // Trainer
                          ],
                        ),
                      ),
                    if (!isFetching)
                      Expanded(
                        child: Container(
                          padding:
                              EdgeInsets.only(left: 15, right: 15, top: 15),
                          child: TabBarView(
                            children: [
                              Icon(Icons.people),
                              if (isTrainerShoppingCartFetching)
                                Center(child: CircularProgressIndicator())
                              else
                                _trainerShoppingCartList(),
                            ],
                          ),
                        ),
                      ),
                    if (isFetching)
                      Expanded(
                          child: Center(child: CircularProgressIndicator())),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
