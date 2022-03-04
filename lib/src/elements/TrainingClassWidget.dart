import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/s.dart';

import '../models/trainingClass.dart';
import '../repository/user_repository.dart' as user_repo;
import '../repository/class_repository.dart' as class_repo;

class TrainingClassWidget extends StatelessWidget {
  final TrainingClass classInfo;
  final Function onDelete;

  int? permission = 3;

  TrainingClassWidget(
      {Key? key, required this.classInfo, required this.onDelete})
      : super(key: key) {
    permission = user_repo.currentUserSocieties.value
        .firstWhere((so) => so.isPrimary == true)
        .permission;
  }

  @override
  Widget build(BuildContext context) {
    bool isTodayEventDate = false;
    final Locale myLocale = Localizations.localeOf(context);
    final String localeCode =
        myLocale.languageCode + '_' + myLocale.countryCode!;

    if (classInfo.eventNextDate != null || classInfo.eventNextDate != '') {
      try {
        final now = DateTime.now();
        final eventNextDate = DateTime.parse(classInfo.eventNextDate! + 'Z');
        isTodayEventDate =
            now.month == eventNextDate.month && now.day == eventNextDate.day;
      } catch (e) {
        debugPrint(classInfo.eventNextDate);
      }
    }
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
              color: Theme.of(context).backgroundColor.withOpacity(0.3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: CachedNetworkImage(
                        key: new Key(classInfo.id.toString()),
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                        imageUrl: classInfo.avatarUrl!,
                        httpHeaders: {
                          'X-WP-Nonce': user_repo.currentUser.value.nonce!,
                          'Cookie': user_repo.currentUser.value.cookie!,
                        },
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Center(
                                child: CircularProgressIndicator(
                                    value: downloadProgress.progress)),
                        errorWidget: (context, url, error) => Container(
                            child: Icon(Icons.sports,
                                size: 75,
                                color: Theme.of(context).primaryColor),
                            color: Theme.of(context).accentColor),
                      )),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            classInfo.name!.length < 20
                                ? classInfo.name!
                                : classInfo.name!.substring(0, 17) + '...',
                            style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).hintColor)),
                        SizedBox(height: 5),
                        if (classInfo.activeCount != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.people, size: 20),
                              Text(" " + classInfo.activeCount.toString()),
                            ],
                          ),
                        SizedBox(height: 5),
                        if (classInfo.eventNextDate != null &&
                            classInfo.eventNextDate!.length != 0)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.date_range,
                                  size: 20,
                                  color: isTodayEventDate
                                      ? Theme.of(context).accentColor
                                      : null),
                              Text(
                                  " " +
                                      DateFormat.yMMMd(localeCode).format(
                                          DateTime.parse(
                                              classInfo.eventNextDate!)) +
                                      ' ' +
                                      DateFormat.Hm().format(DateTime.parse(
                                          classInfo.eventNextDate!)),
                                  style: isTodayEventDate
                                      ? TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).accentColor)
                                      : null),
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
                class_repo.editId = classInfo.id;
                Navigator.of(context).pushNamed('/ManageClass');
              }
            },
          ),
          actions: <Widget>[
            if (permission == 1 || permission == 2)
              IconSlideAction(
                caption: AppLocalizations.of(context)!.appButtonEdit,                           // 'Edit',
                color: Theme.of(context).accentColor,
                icon: Icons.edit_outlined,
                onTap: () {
                  class_repo.editId = classInfo.id;
                  Navigator.of(context).pushNamed('/EditTrainingClass');
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
                  onDelete();
                },
              ),
          ],
        ),
      ),
    );
  }
}
