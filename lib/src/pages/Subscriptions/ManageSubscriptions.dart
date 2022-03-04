import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../controllers/subscription_controller.dart';

import '../../elements/MemberSubscriptionWidget.dart';
import '../../elements/MemberBookingWidget.dart';

import '../../repository/user_repository.dart' as user_repo;
import '../../repository/subscription_repository.dart' as subscription_repo;

class ManageSubscriptionsWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;
  final int? memberId;

  ManageSubscriptionsWidget({Key? key, this.parentScaffoldKey, this.memberId})
      : super(key: key);
  @override
  _ManageSubscriptionsWidgetState createState() =>
      _ManageSubscriptionsWidgetState();
}

class _ManageSubscriptionsWidgetState
    extends StateMVC<ManageSubscriptionsWidget> {
  late SubscriptionController _con;
  bool isFetching = false;
  int? societyId;
  String searchText = '';

  final focusKeyMember = new GlobalKey();
  final focusKeyTraining = new GlobalKey();
  int? permission = 3;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  _ManageSubscriptionsWidgetState() : super(SubscriptionController()) {
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
    subscription_repo.subscriptions.addListener(() {
      setState(() {});
    });
    subscription_repo.bookings.addListener(() {
      setState(() {});
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
    futures.add(_con.getMemberSubscriptions(widget.memberId));
    futures.add(_con.getMemberBookings(widget.memberId));
    await Future.wait(futures);
  }

  Widget _subscriptionList() {
    return SingleChildScrollView(
      child: Column(
          children: subscription_repo.subscriptions.value
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

  Widget _bookingList() {
    return SingleChildScrollView(
      child: Column(
          children: subscription_repo.bookings.value
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return true;
      },
      child: Scaffold(
        key: _con.scaffoldKey,
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
            icon: new Icon(
              Icons.arrow_back,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).accentColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.subscriptionMemberSingleOverview,                     // Single Member Overview
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
                            Tab(child: Text( AppLocalizations.of(context)!.subscriptionTabSubscriptions )), // Subscriptions
                            Tab(child: Text( AppLocalizations.of(context)!.subscriptionTabBookings )),      // Bookings
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
                              Stack(
                                children: [
                                  _subscriptionList(),
                                  if (permission == 1 || permission == 2)
                                    Positioned(
                                      right: 0,
                                      bottom: 20,
                                      child: InkWell(
                                        child: Icon(
                                          Icons.add_circle_rounded,
                                          size: 70,
                                          color: Theme.of(context).accentColor,
                                        ),
                                        onTap: () {
                                          Navigator.of(context).pushNamed(
                                            '/CreateSingleSubscription',
                                            arguments: widget.memberId,
                                          );
                                        },
                                      ),
                                    )
                                ],
                              ),
                              _bookingList(),
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
