import 'dart:math';

import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../elements/CustomDatePicker.dart';

import '../../helpers/helper.dart';

import '../../models/subscription.dart';

import '../../controllers/subscription_controller.dart';

import '../../repository/user_repository.dart' as user_repo;

class ManageSingleSubscriptionWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;
  final Subscription? subscriptionInfo;

  ManageSingleSubscriptionWidget(
      {Key? key, this.parentScaffoldKey, this.subscriptionInfo})
      : super(key: key);
  @override
  _ManageSingleSubscriptionWidgetState createState() =>
      _ManageSingleSubscriptionWidgetState();
}

class _ManageSingleSubscriptionWidgetState
    extends StateMVC<ManageSingleSubscriptionWidget> {
  late SubscriptionController _con;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;

  String phoneNum = '', phoneCode = '';

  _ManageSingleSubscriptionWidgetState() : super(SubscriptionController()) {
    _con = controller as SubscriptionController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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
    await _con.getSubscriptionDetail(widget.subscriptionInfo!.memberId,
        widget.subscriptionInfo!.subscriptionId,
        mine: widget.subscriptionInfo!.mine);
  }

  void _onRefresh() async {
    try {
      await _getData();
    } catch (e) {
      print(e.toString());
    }

    _refreshController.refreshCompleted();
  }

  Future<void> _showDeleteConfirmDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.appDialogTitleConfirmation),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations.of(context)!.subscriptionRemoveSubscriptionConfirmText),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.appButtonOk),
              onPressed: () {
                Navigator.of(context).pop();
                _con.deleteMemberSubscription();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.appButtonCancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _expired() {
    DateTime endDate = DateTime.parse(_con.endDate);
    final DateTime now = DateTime.now();
    return endDate.year < now.year ||
        endDate.year == now.year && endDate.month < now.month ||
        endDate.year == now.year &&
            endDate.month == now.month &&
            endDate.day < now.day;
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
            AppLocalizations.of(context)!.subscriptionManageTitle,
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
                    child: Form(
                      key: _con.subscriptionFormKey,
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
                                  imageUrl: _con.subscriptionInfo.avatarUrl!,
                                  httpHeaders: {
                                    'X-WP-Nonce':
                                        user_repo.currentUser.value.nonce!,
                                    'Cookie':
                                        user_repo.currentUser.value.cookie!,
                                  },
                                  progressIndicatorBuilder: (context, url,
                                          downloadProgress) =>
                                      Center(
                                          child: CircularProgressIndicator(
                                              value:
                                                  downloadProgress.progress)),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                          child: Icon(Icons.person,
                                              size: 80,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          color: Theme.of(context).accentColor),
                                )),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            _con.subscriptionInfo.memberFirstName! +
                                " " +
                                _con.subscriptionInfo.memberLastName!,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 24),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: const Divider(
                              height: 10,
                              thickness: 5,
                            ),
                          ),
                          GridView.count(
                            primary: false,
                            padding: const EdgeInsets.only(top: 5),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            childAspectRatio: 3,
                            children: <Widget>[
                              CustomDatePicker(
                                value: _con.startDate,
                                disabled:
                                    _con.subscriptionInfo.permissionSociety! <
                                        1,
                                onChange: (value) {
                                  setState(() {
                                    _con.startDate = value;
                                  });
                                },
                                label: AppLocalizations.of(context)!.subscriptionStartDate,
                              ),
                              Center(
                                child: Text(
                                  _expired()
                                      ? AppLocalizations.of(context)!.subscriptionExpired
                                      : '',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              CustomDatePicker(
                                value: _con.endDate,
                                label: AppLocalizations.of(context)!.subscriptionEndDate,
                                disabled:
                                    _con.subscriptionInfo.permissionSociety! <
                                        1,
                                onChange: (newEndDate) =>
                                    setState(() => _con.endDate = newEndDate),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_con.subscriptionInfo.permissionSociety! >
                                      0)
                                    TextButton(
                                      child: Text(
                                        AppLocalizations.of(context)!.subscriptionPlusOneWeek,
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                      onPressed: () {
                                        final endDate =
                                            DateTime.parse(_con.endDate);
                                        final newEndDate = new DateTime(
                                            endDate.year,
                                            endDate.month,
                                            endDate.day + 7);
                                        final DateFormat dateFormatter =
                                            DateFormat('yyyy-MM-dd');
                                        setState(() => _con.endDate =
                                            dateFormatter.format(newEndDate));
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Theme.of(context).accentColor),
                                      ),
                                    ),
                                  SizedBox(width: 10),
                                  if (_con.subscriptionInfo.permissionSociety! >
                                      0)
                                    TextButton(
                                      child: Text(
                                        AppLocalizations.of(context)!.subscriptionPlusOneMonth,
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                      onPressed: () {
                                        final endDate =
                                            DateTime.parse(_con.endDate);
                                        final newEndDate = new DateTime(
                                            endDate.year,
                                            endDate.month + 1,
                                            endDate.day);
                                        final DateFormat dateFormatter =
                                            DateFormat('yyyy-MM-dd');
                                        setState(() => _con.endDate =
                                            dateFormatter.format(newEndDate));
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Theme.of(context).accentColor),
                                      ),
                                    ),
                                ],
                              ),
                              if (_con.subscriptionInfo.permissionSociety! < 1)
                                TextFormField(
                                    readOnly: true,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    initialValue: _con
                                        .maxCount
                                        .toString(),
                                    decoration: Helper.of(context)
                                        .textInputDecoration(
                                        AppLocalizations.of(context)
                                                !.subscriptionBookingAmount,
                                            '',
                                            filled: true,
                                            fillColor: Theme.of(context)
                                                .hintColor
                                                .withOpacity(0.05)))
                              else
                                DropdownButtonFormField(
                                  decoration: Helper.of(context)
                                      .textInputDecoration(
                                      AppLocalizations
                                              .of(context)
                                              !.subscriptionBookingAmount,
                                          ''),
                                  value: _con.maxCount,
                                  onTap: () {
                                    FocusScope.of(context)
                                        .requestFocus(new FocusNode());
                                  },
                                  onChanged: (int? newValue) {
                                    setState(() => _con.maxCount = newValue);
                                  },
                                  items: List<DropdownMenuItem<int>>.generate(
                                      361, (i) {
                                    return DropdownMenuItem<int>(
                                      value: i,
                                      child: Text(i.toString()),
                                    );
                                  }).toList(),
                                ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_con.subscriptionInfo.permissionSociety! >
                                      0)
                                    TextButton(
                                      child: Text(
                                        '+1',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                      onPressed: () {
                                        setState(() => _con.maxCount =
                                            min(_con.maxCount! + 1, 360));
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Theme.of(context).accentColor),
                                      ),
                                    ),
                                  SizedBox(width: 10),
                                  if (_con.subscriptionInfo.permissionSociety! >
                                      0)
                                    TextButton(
                                      child: Text(
                                        '+5',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                      onPressed: () {
                                        setState(() => _con.maxCount =
                                            min(_con.maxCount! + 5, 360));
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Theme.of(context).accentColor),
                                      ),
                                    ),
                                ],
                              ),
                              TextFormField(
                                  readOnly: true,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  initialValue: _con
                                      .subscriptionInfo.subscriptionCount
                                      .toString(),
                                  decoration: Helper.of(context)
                                      .textInputDecoration(
                                      AppLocalizations
                                              .of(context)
                                              !.subscriptionBookingQuantity,
                                          '',
                                          filled: true,
                                          fillColor: Theme.of(context)
                                              .hintColor
                                              .withOpacity(0.05))),
                              Center(
                                child: Text(
                                  _con.subscriptionInfo.subscriptionCount! >
                                          _con.maxCount!
                                      ? AppLocalizations.of(context)!.subscriptionOverbooked
                                      : '',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: const Divider(
                              height: 10,
                              thickness: 5,
                            ),
                          ),
                          TextFormField(
                            readOnly: true,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            initialValue: _con
                                .subscriptionInfo.subscriptionStateText
                                .toString(),
                            decoration: Helper.of(context)
                                .textInputDecoration(
                                AppLocalizations.of(context)!.subscriptionValidity,
                                '',
                                filled: true,
                                fillColor: Theme.of(context)
                                    .hintColor
                                    .withOpacity(0.05),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            readOnly: true,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            initialValue: _con
                                .subscriptionInfo.subscriptionPaidText
                                .toString(),
                            decoration: Helper.of(context)
                                .textInputDecoration(
                                AppLocalizations.of(context)!.subscriptionPayment,
                                '',
                                filled: true,
                                fillColor: Theme.of(context)
                                    .hintColor
                                    .withOpacity(0.05),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: const Divider(
                              height: 20,
                              thickness: 5,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (_con.subscriptionInfo.permissionSociety! > 0)
                                TextButton(
                                  child: Text(
                                    AppLocalizations.of(context)!.appButtonRemove,
                                    style: TextStyle(
                                      color: Colors.red,
                                      decoration: TextDecoration.underline,
                                      fontSize: 18,
                                    ),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.pressed))
                                          return Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5);
                                        return Theme.of(context).primaryColor;
                                      },
                                    ),
                                    minimumSize:
                                        MaterialStateProperty.all<Size>(
                                      Size(100, 40),
                                    ),
                                  ),
                                  onPressed: _showDeleteConfirmDialog,
                                ),
                              if (_con.subscriptionInfo.permissionSociety! > 0)
                                TextButton(
                                  child: Text(
                                    AppLocalizations.of(context)!.appButtonSave,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 18),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.pressed))
                                          return Theme.of(context)
                                              .accentColor
                                              .withOpacity(0.5);
                                        return Theme.of(context).accentColor;
                                      },
                                    ),
                                    minimumSize:
                                        MaterialStateProperty.all<Size>(
                                      Size(100, 40),
                                    ),
                                  ),
                                  onPressed: _con.saveSubscriptionDetail,
                                ),
                            ],
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
