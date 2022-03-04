import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:intl/intl.dart';

import '../models/subscription.dart';
import '../repository/user_repository.dart' as user_repo;

class TrainerSubscriptionWidget extends StatelessWidget {
  final Subscription subscriptionInfo;
  final Function onDelete;

  int? permission = 3;

  TrainerSubscriptionWidget(
      {Key? key, required this.subscriptionInfo, required this.onDelete})
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
              color: subscriptionInfo.subscriptionId! > 0
                  ? (subscriptionInfo.subscriptionOverbooked! ||
                          subscriptionInfo.subscriptionState == 1 ||
                          subscriptionInfo.subscriptionPaid == 1
                      ? Colors.redAccent.withOpacity(0.5)
                      : Colors.greenAccent.withOpacity(0.5))
                  : Theme.of(context).accentColor.withOpacity(0.5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: CachedNetworkImage(
                        key: new Key(subscriptionInfo.memberId.toString()),
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                        imageUrl: subscriptionInfo.avatarUrl!,
                        httpHeaders: {
                          'X-WP-Nonce': user_repo.currentUser.value.nonce!,
                          'Cookie': user_repo.currentUser.value.cookie!,
                        },
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Center(
                                child: CircularProgressIndicator(
                                    value: downloadProgress.progress)),
                        errorWidget: (context, url, error) => Container(
                            child: Icon(Icons.person,
                                size: 75,
                                color: Theme.of(context).primaryColor),
                            color: subscriptionInfo.subscriptionId! > 0
                                ? (subscriptionInfo.subscriptionOverbooked! ||
                                        subscriptionInfo.subscriptionState ==
                                            1 ||
                                        subscriptionInfo.subscriptionPaid == 1
                                    ? Colors.redAccent
                                    : Colors.greenAccent)
                                : Theme.of(context).accentColor),
                      )),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            (subscriptionInfo.memberFirstName! +
                                            " " +
                                            subscriptionInfo.memberLastName!)
                                        .length <
                                    20
                                ? (subscriptionInfo.memberFirstName! +
                                    " " +
                                    subscriptionInfo.memberLastName!)
                                : (subscriptionInfo.memberFirstName! +
                                            " " +
                                            subscriptionInfo.memberLastName!)
                                        .substring(0, 17) +
                                    '...',
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
                  )
                ],
              ),
            ),
            onTap: () {
              if (permission == 1 || permission == 2 || permission == 3) {
                Navigator.of(context).pushNamed(
                    '/ManageSingleMemberSubscription',
                    arguments: subscriptionInfo.memberId);
              }
            },
          ),
        ),
      ),
    );
  }
}
