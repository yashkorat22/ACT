import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../models/classEvent.dart';
import '../repository/user_repository.dart' as user_repo;
import '../repository/class_repository.dart' as class_repo;

class ClassEventWidget extends StatelessWidget {
  final ClassEvent event;
  final Function onDelete;

  int? permission = 3;

  ClassEventWidget({Key? key, required this.event, required this.onDelete})
      : super(key: key) {
    permission = user_repo.currentUserSocieties.value
        .firstWhere((so) => so.isPrimary == true)
        .permission;
  }

  @override
  Widget build(BuildContext context) {
    final Locale myLocale = Localizations.localeOf(context);
    final String localeCode = myLocale.languageCode + '_' + myLocale.countryCode!;

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
                          Text(user_repo.repetitions.value
                              .firstWhere(
                                  (rep) => rep.value == event.eventDateRepeat)
                              .name!)
                        ])
                      : Column(children: [
                    Icon(
                      Icons.repeat_one,
                      size: 50,
                    ),
                    Text(user_repo.repetitions.value
                        .firstWhere(
                            (rep) => rep.value == event.eventDateRepeat)
                        .name!)
                  ])
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.eventName!.length < 20
                            ? event.eventName!
                            : event.eventName!.substring(0, 17) + '...',
                        style: TextStyle(
                            fontSize: 20, color: Theme.of(context).hintColor),
                      ),
                      if (event.eventDateTimeStart != null)
                        SizedBox(height: 5),
                      if (event.eventDateTimeStart != null)
                        Row(children: [
                          Icon(Icons.play_arrow),
                          Text(DateFormat.yMMMd(localeCode).format(DateTime.parse(
                              event.eventDateTimeStart!)) +
                              ' ' +
                              DateFormat.Hm().format(DateTime.parse(
                                  event.eventDateTimeStart! + 'Z')),
                            style:
                                TextStyle(color: Theme.of(context).hintColor),
                          ),
                        ]),
                      if (event.eventDateTimeEnd != null &&
                          event.eventDateRepeat! > 0)
                        SizedBox(height: 5),
                      if (event.eventDateTimeEnd != null &&
                          event.eventDateRepeat! > 0)
                        Row(children: [
                          Icon(Icons.stop),
                          Text(
                            event.eventDateTimeEnd!,
                            style:
                                TextStyle(color: Theme.of(context).hintColor),
                          ),
                        ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            if (permission == 1 || permission == 2)
              IconSlideAction(
                caption: AppLocalizations.of(context)!.appButtonEdit,                           //'Edit',
                foregroundColor: Theme.of(context).primaryColor,
                color: Theme.of(context).accentColor,
                icon: Icons.edit_outlined,
                onTap: () {
                  class_repo.editEvent = event;
                  Navigator.of(context).pushNamed('/EditClassEvent');
                },
              ),
          ],
          secondaryActions: <Widget>[
            if (permission == 1 || permission == 2)
              IconSlideAction(
                caption: AppLocalizations.of(context)!.appButtonDelete,                         //'Delete',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () {
                  onDelete(event.eventId);
                },
              ),
          ],
        ),
      ),
    );
  }
}
