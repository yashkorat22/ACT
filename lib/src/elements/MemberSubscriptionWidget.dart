import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:intl/intl.dart';

import '../models/subscription.dart';
import '../repository/user_repository.dart' as user_repo;

class MemberSubscriptionWidget extends StatelessWidget {
  final Subscription subscriptionInfo;
  final Function onCancel;
  final Function onOrder;

  int? permission = 3;

  MemberSubscriptionWidget({
    Key? key,
    required this.subscriptionInfo,
    required this.onCancel,
    required this.onOrder,
  }) : super(key: key) {
    permission = user_repo.currentUserSocieties.value
        .firstWhere((so) => so.isPrimary == true)
        .permission;
  }

  @override
  Widget build(BuildContext context) {
    final Locale myLocale = Localizations.localeOf(context);
    final String localeCode =
        myLocale.languageCode + '_' + myLocale.countryCode!;
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          child: InkWell(
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 20,
              ),
              color: subscriptionInfo.subscriptionId! > 0
                  ? (subscriptionInfo.subscriptionOverbooked! ||
                          subscriptionInfo.subscriptionState == 1 ||
                          subscriptionInfo.subscriptionPaid == 1
                      ? Colors.redAccent.withOpacity(0.5)
                      : Colors.greenAccent.withOpacity(0.5))
                  : Theme.of(context).accentColor.withOpacity(0.5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (subscriptionInfo.subscriptionPaid == 2)
                    Icon(
                      Icons.attach_money,
                      size: 50,
                      color: Colors.greenAccent,
                    )
                  else
                    Icon(
                      Icons.money_off,
                      size: 50,
                      color: Colors.red,
                    ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((subscriptionInfo.ownerFullName ?? '').length > 0)
                            Text(
                                subscriptionInfo.ownerFullName!.length > 20
                                    ? subscriptionInfo.ownerFullName!
                                            .substring(0, 17) +
                                        "..."
                                    : subscriptionInfo.ownerFullName!,
                                style: TextStyle(fontSize: 18)),
                          if (subscriptionInfo.subscriptionStartDate != null &&
                              subscriptionInfo.subscriptionStartDate!.length !=
                                  0)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.play_arrow,
                                  size: 20,
                                ),
                                Text(" " +
                                    DateFormat.yMMMd(localeCode).format(
                                        DateTime.parse(subscriptionInfo
                                            .subscriptionStartDate!))),
                              ],
                            ),
                          if (subscriptionInfo.subscriptionEndDate != null &&
                              subscriptionInfo.subscriptionEndDate!.length != 0)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.stop,
                                  size: 20,
                                ),
                                Text(
                                  " " +
                                      DateFormat.yMMMd(localeCode).format(
                                          DateTime.parse(subscriptionInfo
                                              .subscriptionEndDate!)),
                                ),
                              ],
                            ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calculate,
                                size: 20,
                              ),
                              Text(
                                " " +
                                    subscriptionInfo.subscriptionCount
                                        .toString() +
                                    " / " +
                                    subscriptionInfo.subscriptionMaxCount
                                        .toString() +
                                    " ( " +
                                    subscriptionInfo.participationUncovered
                                        .toString() +
                                    " )",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (subscriptionInfo.shoppingCartItemsSubscriptionId! > 0)
                    Icon(Icons.shopping_cart, size: 50, color: Colors.red)
                  else
                    SizedBox(width: 50),
                ],
              ),
            ),
            onTap: () {
              if (permission == 1 || permission == 2) {
                Navigator.of(context).pushNamed(
                  '/ManageSingleSubscription',
                  arguments: subscriptionInfo,
                );
              }
            },
          ),
          actions: <Widget>[
            if ( ( subscriptionInfo.subscriptionPaid != 2 &&
                subscriptionInfo.shoppingCartItemsSubscriptionId! <= 0 ) && ( subscriptionInfo.permissionSociety! > 0 && subscriptionInfo.permissionSociety! < 4 ) )
              IconSlideAction(
                caption: AppLocalizations.of(context)!.appButtonToInvoice, //'Order',
                foregroundColor: Theme.of(context).primaryColor,
                color: Colors.greenAccent,
                icon: Icons.add_shopping_cart,
                onTap: () {
                  this.onOrder(
                    subscriptionInfo.memberId,
                    subscriptionInfo.subscriptionId,
                  );
                },
              ),
          ],
          secondaryActions: <Widget>[
            if ( ( subscriptionInfo.shoppingCartItemsSubscriptionId! > 0 ) && ( subscriptionInfo.permissionSociety! > 0 && subscriptionInfo.permissionSociety! < 4 ) )
              IconSlideAction(
                caption: AppLocalizations.of(context)!.appButtonRemove, //'Cancel',
                color: Colors.redAccent,
                icon: Icons.remove_shopping_cart,
                onTap: () {
                  this.onCancel(
                      subscriptionInfo.memberId,
                      subscriptionInfo.shoppingCartId,
                      subscriptionInfo.shoppingCartItemsSubscriptionId,
                      "subscription");
                },
              ),
          ],
        ),
      ),
    );
  }
}
