import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/subscription_controller.dart';

import '../../elements/TrainerSubscriptionWidget.dart';
import '../../elements/HelpButtonWidget.dart';
import '../../elements/MemberSubscriptionWidget.dart';
import '../../elements/MemberBookingWidget.dart';

import '../../helpers/helper.dart';

import '../../repository/user_repository.dart' as user_repo;
import '../../repository/subscription_repository.dart' as subscription_repo;

class SubscriptionsWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  SubscriptionsWidget({Key? key, this.parentScaffoldKey}) : super(key: key);
  @override
  _SubscriptionsWidgetState createState() => _SubscriptionsWidgetState();
}

class _SubscriptionsWidgetState extends StateMVC<SubscriptionsWidget> {
  late SubscriptionController _con;
  bool isFetching = false;
  bool isTrainerSubscriptionFetching = false;
  bool isMemberSubscriptionFetching = false;
  int? societyId;
  String searchText = '';
  int? permission = 3;

  final focusKeyMember = new GlobalKey();
  final focusKeyTraining = new GlobalKey();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  _SubscriptionsWidgetState() : super(SubscriptionController()) {
    _con = controller as SubscriptionController;
    societyId = user_repo.currentUserSocieties.value
        .firstWhere((so) => so.isPrimary == true)
        .id;
    permission = user_repo.currentUserSocieties.value
        .firstWhere((so) => so.isPrimary == true)
        .permission;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initData();
    subscription_repo.trainerSubscriptions.addListener(() {
      setState(() {});
    });
    subscription_repo.myBookings.addListener(() {
      setState(() {});
    });
    subscription_repo.mySubscriptions.addListener(() {
      setState(() {});
    });

    SharedPreferences.getInstance().then((instance) {
      if (!(instance.getBool("subscriptions_visited") ?? false)) {
        Future.delayed(const Duration(seconds: 1), () {
          instance.setBool("subscriptions_visited", true);
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
    futures.add(subscription_repo.fetchMySubscriptions());
    futures.add(subscription_repo.fetchMyBookings());
    futures.add(getTrainerSubscriptions());
    await Future.wait(futures);
  }

  Future<void> getTrainerSubscriptions() async {
    await _con.getTrainerSubscriptions();
  }

  Future<void> _showDeleteTrainerSubscriptionDialog(int? subscriptionId) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.appDialogTitleConfirmation), // Confirmation
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations
                    .of(context)
                    !.subscriptionRemoveSubscriptionConfirmText), // Are you sure to delete this subscription?
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.appButtonOk), // OK
              onPressed: () async {
                Navigator.of(context).pop();
                // if (await _con.deleteTrainerSubscription(subscriptionId)) {
                //   setState(() {
                //     trainerSubscriptions
                //         .removeWhere((subscriptionInfo) => subscriptionInfo.id == subscriptionId);
                //     trainerSubscriptions = List.from(trainerSubscriptions);
                //   });
                // }
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.appButtonCancel), // Cancel
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void deleteTrainerSubscription(int? subscriptionId) {
    _showDeleteTrainerSubscriptionDialog(subscriptionId);
  }

  Widget _trainerSubscriptionList() {
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
                hintText: AppLocalizations.of(context)!.appInputSearch, // Search...
                hintStyle: TextStyle(
                    color: Theme.of(context).hintColor.withOpacity(0.5)),
                prefixIcon:
                    Icon(Icons.search, color: Theme.of(context).hintColor),
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
                  children: subscription_repo.trainerSubscriptions.value
                      .where((subscriptionInfo) =>
                          (subscriptionInfo.memberFirstName! +
                                  ' ' +
                                  subscriptionInfo.memberLastName!)
                              .toLowerCase()
                              .contains(searchText.toLowerCase()))
                      .map(
                        (subscriptionInfo) => TrainerSubscriptionWidget(
                          key: Key(subscriptionInfo.memberId.toString()),
                          subscriptionInfo: subscriptionInfo,
                          onDelete: () {
                            deleteTrainerSubscription(
                                subscriptionInfo.memberId);
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
              showHelpDialog: () =>
                  Helper.of(context).showHintDialog(Helper.homeHelp()),
              color: Theme.of(context).accentColor,
            ))
      ],
    );
  }

  Widget _memberSubscriptionList() {
    return SingleChildScrollView(
      child: Column(
          children: subscription_repo.mySubscriptions.value
              .map(
                (subscriptionInfo) => MemberSubscriptionWidget(
                  subscriptionInfo: subscriptionInfo,
                  onCancel: _con.cancelMemberShoppingCartItem,
                  onOrder: (memberId, subscriptionId) => _con
                      .addToMemberShoppingCart(memberId, subscriptionId, null),
                ),
              )
              .toList()),
    );
  }

  Widget _memberBookingList() {
    return SingleChildScrollView(
      child: Column(
          children: subscription_repo.myBookings.value
              .map(
                (bookingInfo) => MemberBookingWidget(
                  bookingInfo: bookingInfo,
                  onCancel: _con.cancelMemberShoppingCartItem,
                  onOrder: (memberId, participationId) => _con
                      .addToMemberShoppingCart(memberId, null, participationId),
                ),
              )
              .toList()),
    );
  }

  Widget _memberTabView() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(children: [
          if (!isFetching)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: TabBar(
                labelColor: Theme.of(context).accentColor,
                unselectedLabelColor: Theme.of(context).hintColor,
                tabs: [
                  Tab(
                      child: Text(AppLocalizations
                          .of(context)
                          !.subscriptionTabSubscriptions)), // Subscriptions
                  Tab(
                      child: Text(
                          AppLocalizations.of(context)!.subscriptionTabBookings)), // Bookings
                ],
              ),
            ),
          if (!isFetching)
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 15, right: 15, top: 15),
                child: TabBarView(
                  children: [
                    _memberSubscriptionList(),
                    _memberBookingList(),
                  ],
                ),
              ),
            ),
        ]),
      ),
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
            AppLocalizations.of(context)!.subscriptionTitle, // Subscriptions
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
                            Tab(
                                child: Text(AppLocalizations
                                    .of(context)
                                    !.subscriptionTabMember)), // Member
                            Tab(
                                child: Text(AppLocalizations
                                    .of(context)
                                    !.subscriptionTabTrainer)), // Trainer
                          ],
                        ),
                      ),
                    if (!isFetching)
                      Expanded(
                        child: TabBarView(
                          children: [
                            _memberTabView(),
                            Container(
                              padding:
                                  EdgeInsets.only(left: 15, right: 15, top: 15),
                              child: isTrainerSubscriptionFetching
                                  ? Center(child: CircularProgressIndicator())
                                  : _trainerSubscriptionList(),
                            ),
                          ],
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
