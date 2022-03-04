import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:intl/intl.dart';

import '../models/discoveredClass.dart';
import '../repository/user_repository.dart' as user_repo;

class DiscoveredClassWidget extends StatelessWidget {
  final DiscoveredClass classInfo;
  final Function onRequest;
  final Function onRetract;

  int? permission = 3;

  DiscoveredClassWidget(
      {Key? key,
      required this.classInfo,
      required this.onRequest,
      required this.onRetract})
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

    Color backgroundColor = classInfo.classApplicationId! > 0
        ? Colors.orangeAccent.withOpacity(0.5)
        : (classInfo.classMemberId! > 0
            ? Colors.greenAccent.withOpacity(0.5)
            : Theme.of(context).backgroundColor.withOpacity(0.5));
    Color avatarColor = classInfo.classApplicationId! > 0
        ? Colors.orangeAccent
        : (classInfo.classMemberId! > 0
            ? Colors.greenAccent
            : Theme.of(context).accentColor);

    if (classInfo.classEventNextDateTime != null ||
        classInfo.classEventNextDateTime != '') {
      try {
        final now = DateTime.now();
        final eventNextDate =
            DateTime.parse(classInfo.classEventNextDateTime! + 'Z');
        isTodayEventDate =
            now.month == eventNextDate.month && now.day == eventNextDate.day;
      } catch (e) {
        debugPrint(classInfo.classEventNextDateTime);
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
              color: backgroundColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: CachedNetworkImage(
                        key: new Key(classInfo.classId.toString()),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        imageUrl: classInfo.classAvatarUrl!,
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
                                size: 45,
                                color: Theme.of(context).primaryColor),
                            color: avatarColor),
                      )),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              classInfo.className!.length < 20
                                  ? classInfo.className!
                                  : classInfo.className!.substring(0, 17) +
                                      '...',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).hintColor)),
                          SizedBox(height: 5),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.person, size: 20),
                              Text(" " +
                                  classInfo.ownerFirstName! +
                                  " " +
                                  classInfo.ownerLastName!),
                            ],
                          ),
                          SizedBox(height: 5),
                          if (classInfo.classEventNextDateTime != null &&
                              classInfo.classEventNextDateTime!.length != 0)
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
                                            DateTime.parse(classInfo
                                                .classEventNextDateTime!)) +
                                        ' ' +
                                        DateFormat.Hm().format(DateTime.parse(
                                            classInfo
                                                .classEventNextDateTime!)),
                                    style: isTodayEventDate
                                        ? TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).accentColor)
                                        : null),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (classInfo.classApplicationId! > 0)
                    Icon(
                      Icons.assignment_late,
                      color: Colors.redAccent,
                      size: 50,
                    )
                  else if (classInfo.classMemberId! > 0)
                    Icon(
                      Icons.assignment_turned_in,
                      color: Colors.greenAccent,
                      size: 50,
                    )
                  else
                    SizedBox(width: 50),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            if (classInfo.classApplicationId! < 1 &&
                classInfo.classMemberId! < 1)
              IconSlideAction(
                caption: AppLocalizations.of(context)!.appButtonJoin,                           //'Request',
                color: Theme.of(context).accentColor,
                icon: Icons.assignment_turned_in,
                onTap: onRequest as void Function()?,
              ),
          ],
          secondaryActions: <Widget>[
            if (classInfo.classApplicationId! > 0)
              IconSlideAction(
                caption: AppLocalizations.of(context)!.appButtonLeave,                           //'Retract',
                color: Colors.red,
                icon: Icons.delete,
                onTap: onRetract as void Function()?,
              ),
          ],
        ),
      ),
    );
  }
}
