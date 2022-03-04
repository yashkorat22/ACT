import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:intl/intl.dart';

import '../models/booking.dart';
import '../repository/user_repository.dart' as user_repo;

class MemberBookingWidget extends StatelessWidget {
  final Booking bookingInfo;
  final Function onCancel;
  final Function onOrder;

  int? permission = 3;

  MemberBookingWidget({
    Key? key,
    required this.bookingInfo,
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
              color:
                  bookingInfo.paymentId == null || bookingInfo.paymentId! <= 0
                      ? (bookingInfo.subscriptionId! > 0
                          ? Colors.greenAccent.withOpacity(0.5)
                          : Colors.redAccent.withOpacity(0.5))
                      : Colors.blueAccent.withOpacity(0.5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (bookingInfo.paymentId != null &&
                      bookingInfo.paymentId! > 0)
                    Icon(
                      Icons.attach_money,
                      size: 50,
                      color: Colors.blueAccent,
                    )
                  else if (bookingInfo.subscriptionId! > 0)
                    Icon(
                      Icons.card_membership,
                      size: 50,
                      color: Colors.greenAccent,
                    )
                  else
                    SizedBox(width: 50),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((bookingInfo.ownerFullName ?? '').length > 0)
                            Text(
                                bookingInfo.ownerFullName!.length > 20
                                    ? bookingInfo.ownerFullName!
                                            .substring(0, 17) +
                                        "..."
                                    : bookingInfo.ownerFullName!,
                                style: TextStyle(fontSize: 18)),
                          Text(bookingInfo.className!,
                              style: TextStyle(fontSize: 15)),
                          if (bookingInfo.eventDateTimePlan != null &&
                              bookingInfo.eventDateTimePlan!.length != 0)
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
                                          DateTime.parse(
                                              bookingInfo.eventDateTimePlan!)),
                                ),
                              ],
                            ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.stop,
                                size: 20,
                              ),
                              Text(" " + bookingInfo.participationStatusName!),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (bookingInfo.shoppingCartItemsParticipationId! > 0)
                    Icon(Icons.shopping_cart, size: 50, color: Colors.redAccent)
                  else
                    SizedBox(width: 50),
                ],
              ),
            ),
            onTap: () {
              if (permission == 1 || permission == 2) {
                // Navigator.of(context).pushNamed(
                //   '/ManageSingleBooking',
                //   arguments: bookingInfo,
                // );
              }
            },
          ),
          actions: <Widget>[
            if ( (((bookingInfo.subscriptionId == null ||
                    bookingInfo.subscriptionId! <= 0) &&
                bookingInfo.paymentId == null &&
                (bookingInfo.shoppingCartItemsParticipationId == null ||
                    bookingInfo.shoppingCartItemsParticipationId! <= 0))) && ( bookingInfo.permissionSociety! > 0 && bookingInfo.permissionSociety! < 4 ) )
              IconSlideAction(
                caption: AppLocalizations.of(context)!.appButtonToInvoice, //'Order',
                foregroundColor: Theme.of(context).primaryColor,
                color: Colors.greenAccent,
                icon: Icons.add_shopping_cart,
                onTap: () {
                  this.onOrder(
                    bookingInfo.memberId,
                    bookingInfo.participationId,
                  );
                },
              ),
          ],
          secondaryActions: <Widget>[
            if ( ( bookingInfo.shoppingCartItemsParticipationId! > 0 ) && ( bookingInfo.permissionSociety! > 0 && bookingInfo.permissionSociety! < 4 ) )
              IconSlideAction(
                caption: AppLocalizations.of(context)!.appButtonRemove, //'Cancel',
                color: Colors.redAccent,
                icon: Icons.remove_shopping_cart,
                onTap: () {
                  this.onCancel(
                    bookingInfo.memberId,
                    bookingInfo.shoppingCartId,
                    bookingInfo.shoppingCartItemsParticipationId,
                    "booking",
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
