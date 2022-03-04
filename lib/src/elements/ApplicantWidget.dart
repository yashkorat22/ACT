import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:intl/intl.dart';

import '../models/applicant.dart';
import '../repository/user_repository.dart' as user_repo;
import 'package:flutter_gen/gen_l10n/s.dart';

class ApplicantWidget extends StatelessWidget {
  final Applicant applicantInfo;
  final Function onAccept;
  final Function onDecline;

  int? permission = 3;

  ApplicantWidget(
      {Key? key,
      required this.applicantInfo,
      required this.onAccept,
      required this.onDecline})
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

    Color backgroundColor = applicantInfo.societyMemberId! > 0
        ? Colors.greenAccent.withOpacity(0.5)
        : (applicantInfo.classBlocked! > 0
            ? Colors.redAccent.withOpacity(0.5)
            : Theme.of(context).backgroundColor.withOpacity(0.5));
    Color avatarColor = applicantInfo.societyMemberId! > 0
        ? Colors.greenAccent
        : (applicantInfo.classBlocked! > 0
            ? Colors.redAccent
            : Theme.of(context).accentColor);

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
                      child: applicantInfo.avatarUrl != null &&
                              applicantInfo.avatarUrl != ''
                          ? CachedNetworkImage(
                              key: new Key(applicantInfo.classId.toString()),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              imageUrl: applicantInfo.avatarUrl!,
                              httpHeaders: {
                                'X-WP-Nonce':
                                    user_repo.currentUser.value.nonce!,
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
                            )
                          : Container(
                              child: Icon(Icons.sports,
                                  size: 45,
                                  color: Theme.of(context).primaryColor),
                              color: avatarColor)),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              (applicantInfo.firstName! +
                                              " " +
                                              applicantInfo.lastName!)
                                          .length <
                                      20
                                  ? (applicantInfo.firstName! +
                                      " " +
                                      applicantInfo.lastName!)
                                  : (applicantInfo.firstName! +
                                              " " +
                                              applicantInfo.lastName!)
                                          .substring(0, 17) +
                                      '...',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).hintColor)),
                          SizedBox(height: 5),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.person, size: 20),
                              Text(" " + applicantInfo.className!),
                            ],
                          ),
                          SizedBox(height: 5),
                          if (applicantInfo.applicationSince != null &&
                              applicantInfo.applicationSince!.length != 0)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.date_range,
                                  size: 20,
                                ),
                                Text(
                                  " " +
                                      DateFormat.yMMMd(localeCode).format(
                                          DateTime.parse(applicantInfo
                                              .applicationSince!)) +
                                      ' ' +
                                      DateFormat.Hm().format(DateTime.parse(
                                          applicantInfo.applicationSince!)),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (applicantInfo.societyMemberId! > 0)
                    Icon(
                      Icons.check_circle,
                      color: Colors.greenAccent,
                      size: 50,
                    )
                  else if (applicantInfo.classBlocked! > 0)
                    Icon(
                      Icons.do_not_disturb,
                      color: Colors.redAccent,
                      size: 50,
                    )
                  else
                    SizedBox(width: 50),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            if (permission == 1 || permission == 2 || permission == 3)
              IconSlideAction(
                caption: AppLocalizations.of(context)!.appButtonAdmiss,                         //'Accept',
                color: Theme.of(context).accentColor,
                icon: Icons.person_add,
                onTap: onAccept as void Function()?,
              ),
          ],
          secondaryActions: <Widget>[
            if (permission == 1 || permission == 2 || permission == 3)
              IconSlideAction(
                caption: AppLocalizations.of(context)!.appButtonDismiss,                        //'Decline',
                color: Colors.red,
                icon: Icons.delete,
                onTap: onDecline as void Function()?,
              ),
          ],
        ),
      ),
    );
  }
}
