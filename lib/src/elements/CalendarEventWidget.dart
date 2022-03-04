import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../models/classEvent.dart';
import '../repository/user_repository.dart' as user_repo;
import 'package:flutter_gen/gen_l10n/s.dart';

final eventIcons = [
  Icons.event,
  Icons.event_busy,
  Icons.event_note,
  Icons.event_available,
];

class CalendarEventWidget extends StatelessWidget {
  final ClassEvent event;
  final Function onCancel;
  final Function onSchedule;

  int? permission = 3;

  CalendarEventWidget(
      {Key? key,
      required this.event,
      required this.onSchedule,
      required this.onCancel})
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

    final List<Color> classEventColors = [
      Color.alphaBlend(Colors.greenAccent.shade400.withOpacity(0.7),
          Theme.of(context).backgroundColor),
      Color.alphaBlend(Colors.redAccent.shade400.withOpacity(0.7),
          Theme.of(context).backgroundColor),
      Color.alphaBlend(Colors.orangeAccent.shade400.withOpacity(0.7),
          Theme.of(context).backgroundColor),
    ];
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
              color: event.eventStatusId! > 0 && event.eventStatusId! < 4
                  ? classEventColors[event.eventStatusId! - 1].withOpacity(0.3)
                  : Theme.of(context).backgroundColor.withOpacity(0.3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      width: 60,
                      child: event.eventDateRepeat! > 0
                          ? Column(children: [
                              Icon(
                                Icons.refresh,
                                size: 50,
                              ),
                              Text(event.eventDateRepeatName.toString(),textAlign: TextAlign.left, style: TextStyle(fontSize: 14))
                            ])
                          : Column(children: [
                              Icon(
                                Icons.repeat_one,
                                size: 50,
                              ),
                              Text(event.eventDateRepeatName.toString(),textAlign: TextAlign.left, style: TextStyle(fontSize: 14))
                            ])),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.className!.length < 20
                                ? event.className!
                                : event.className!.substring(0, 17) + '...',
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).hintColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              event.eventStatusId == 2
                                  ? Icon(Icons.event_busy)
                                  : Icon(Icons.event_available),
                              Text(
                                event.eventName!.length < 20
                                    ? event.eventName!
                                    : event.eventName!.substring(0, 17) + '...',
                                style: TextStyle(
                                    color: Theme.of(context).hintColor),
                              ),
                            ],
                          ),
                          if (event.eventDateTime != null) SizedBox(height: 5),
                          if (event.eventDateTime != null)
                            Row(children: [
                              Icon(Icons.date_range),
                              Text(
                                DateFormat.yMMMd(localeCode).format(
                                        DateTime.parse(event.eventDateTime!)) +
                                    ' ' +
                                    DateFormat.Hm().format(DateTime.parse(
                                        event.eventDateTime! + 'Z')),
                                style: TextStyle(
                                    color: Theme.of(context).hintColor),
                              ),
                            ]),
                          SizedBox(height: 5),
                          Row(children: [
                            Icon(Icons.people),
                            Text(
                              event.eventRegParticipants.toString() +
                                  (event.evenMaxParticipants == 0
                                      ? ''
                                      : ' / ' +
                                          event.evenMaxParticipants
                                              .toString()),
                              style:
                                  TextStyle(color: Theme.of(context).hintColor),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(right: 5),
                      width: 80,
                      child: Column(
                        children: [
                          Icon(eventIcons[event.eventStatusId! - 1], size: 40,),
                          Text(event.eventStatusText.toString(), style: TextStyle(fontSize: 16)),
                        ],
                      ))
                ],
              ),
            ),
            onTap: () {
              if (event.societyPermission == 1 ||
                  event.societyPermission == 2) {
                Navigator.of(context)
                    .pushNamed('/ManageCalendarEvent', arguments: event);
              }
            },
          ),
          actions: <Widget>[
            if ((event.societyPermission == 1 ||
                    event.societyPermission == 2) &&
                event.eventStatusId == 2)
              IconSlideAction(
                caption: AppLocalizations.of(context)!.appButtonSchedule,                       //'Schedule',
                foregroundColor: Theme.of(context).primaryColor,
                color: Theme.of(context).accentColor,
                icon: Icons.event_available,
                onTap: () {
                  onSchedule();
                },
              ),
          ],
          secondaryActions: <Widget>[
            if ((event.societyPermission == 1 ||
                    event.societyPermission == 2) &&
                event.eventStatusId != 2)
              IconSlideAction(
                caption: AppLocalizations.of(context)!.appButtonAbsagen,                        //'Cancel',
                color: Colors.red,
                icon: Icons.event_busy,
                onTap: () {
                  onCancel();
                },
              ),
          ],
        ),
      ),
    );
  }
}
