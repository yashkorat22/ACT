import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:intl/intl.dart';

import '../models/shoppingCartItem.dart';

import '../elements/CustomFloatFormField.dart';

import '../repository/user_repository.dart' as user_repo;

class ShoppingCartSubscriptionWidget extends StatelessWidget {
  final ShoppingCartItem subscriptionInfo;
  final Function onDelete;
  final Function onPriceChange;
  final bool disabled;

  int? permission = 3;

  ShoppingCartSubscriptionWidget(
      {Key? key,
      required this.subscriptionInfo,
      required this.onDelete,
      required this.onPriceChange,
      required this.disabled})
      : super(key: key) {
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
              padding: EdgeInsets.all(15),
              color: Theme.of(context).backgroundColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (subscriptionInfo.paymentId! > 0)
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.greenAccent,
                      child: Icon(
                        Icons.attach_money,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  else
                    SizedBox(width: 30),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text( AppLocalizations.of(context)!.shoppingCartSubscription,           //'Subscription',
                            style: TextStyle(
                              fontSize: 20,
                            )),
                        SizedBox(height: 5),
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
                              Text(
                                " " +
                                    DateFormat.yMMMd(localeCode).format(
                                        DateTime.parse(subscriptionInfo
                                            .subscriptionStartDate!)),
                              ),
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
                                      .toString(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                      width: 100,
                      child: CustomFloatFormField(
                        value: subscriptionInfo.shoppingCartPrice,
                        onBlur: onPriceChange,
                        disabled: disabled,
                      )),
                ],
              ),
            ),
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
          ),
          secondaryActions: <Widget>[
            if ((permission == 1 || permission == 2 || permission == 3) &&
                subscriptionInfo.paymentId! < 1)
              IconSlideAction(
                caption: AppLocalizations.of(context)!.appButtonRemove,                         //'Delete',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () {
                  onDelete();
                },
              ),
          ],
        ),
      ),
    );
  }
}
