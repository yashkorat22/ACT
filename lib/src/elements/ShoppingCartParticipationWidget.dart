import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/s.dart';

import '../models/shoppingCartItem.dart';

import '../elements/CustomFloatFormField.dart';

import '../repository/user_repository.dart' as user_repo;

class ShoppingCartParticipationWidget extends StatelessWidget {
  final ShoppingCartItem participationInfo;
  final Function onDelete;
  final Function onPriceChange;
  final bool disabled;

  int? permission = 3;

  ShoppingCartParticipationWidget(
      {Key? key,
      required this.participationInfo,
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
                  if (participationInfo.paymentId! > 0)
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
                        Text( AppLocalizations.of(context)!.shoppingCartBooking,                //'Participation',
                            style: TextStyle(
                              fontSize: 20,
                            )),
                        SizedBox(height: 5),
                        if (participationInfo.className != null &&
                            participationInfo.className != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people,
                                size: 20,
                              ),
                              Text(
                                " " + participationInfo.className!,
                              ),
                            ],
                          ),
                        if (participationInfo.eventName != null &&
                            participationInfo.eventName!.length != 0)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_available,
                                size: 20,
                              ),
                              Text(
                                " " + participationInfo.eventName!,
                              ),
                            ],
                          ),
                        if (participationInfo.eventDateTimeReplace != null &&
                            participationInfo.eventDateTimeReplace!.length != 0)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_note,
                                size: 20,
                              ),
                              Text(
                                " " +
                                    DateFormat.yMMMd(localeCode).format(
                                        DateTime.parse(participationInfo
                                            .eventDateTimeReplace!)),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Container(
                      width: 100,
                      child: CustomFloatFormField(
                        value: participationInfo.shoppingCartPrice,
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
                participationInfo.paymentId! < 1)
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
