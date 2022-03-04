import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:intl/intl.dart';

import '../models/member.dart';
import '../helpers/custom_trace.dart';
import '../repository/user_repository.dart' as user_repo;
import '../repository/member_repository.dart' as member_repo;

class MemberWidget extends StatelessWidget {
  final Member member;
  final Function onDelete;

  int? permission = 3;

  MemberWidget({Key? key, required this.member, required this.onDelete})
      : super(key: key) {
    permission = user_repo.currentUserSocieties.value
        .firstWhere((so) => so.isPrimary == true)
        .permission;
  }

  @override
  Widget build(BuildContext context) {
    bool isTodayBirthday = false;
    final Locale myLocale = Localizations.localeOf(context);
    final String localeCode =
        myLocale.languageCode + '_' + myLocale.countryCode!;
    if (member.birthday != null || member.birthday != '') {
      try {
        final now = DateTime.now();
        final birthday = DateTime.parse(member.birthday!);
        isTodayBirthday =
            now.month == birthday.month && now.day == birthday.day;
      } catch (e) {
        debugPrint(member.birthday);
      }
    }
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          child: Container(
            padding: EdgeInsets.all(15),
            color: Theme.of(context).backgroundColor.withOpacity(0.3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: member.avatarUrl != null && member.avatarUrl != ''
                        ? CachedNetworkImage(
                            key: new Key(member.id.toString()),
                            width: 75,
                            height: 75,
                            fit: BoxFit.cover,
                            imageUrl: member.avatarUrl!,
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
                                color: Theme.of(context).accentColor),
                          )
                        : Container(
                            child: Icon(Icons.person,
                                size: 75,
                                color: Theme.of(context).primaryColor),
                            color: Theme.of(context).accentColor)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          (member.firstName! + ' ' + member.lastName!).length <
                                  20
                              ? member.firstName! + ' ' + member.lastName!
                              : (member.firstName! + ' ' + member.lastName!)
                                      .substring(0, 17) +
                                  '...',
                          style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).hintColor)),
                      SizedBox(height: 5),
                      if (member.birthday != null &&
                          member.birthday!.length != 0)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.date_range,
                                size: 20,
                                color: isTodayBirthday
                                    ? Theme.of(context).accentColor
                                    : null),
                            Text(
                                " " +
                                    DateFormat.yMMMd(localeCode).format(
                                        DateTime.parse(member.birthday!)),
                                style: isTodayBirthday
                                    ? TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).accentColor)
                                    : null),
                          ],
                        ),
                      SizedBox(height: 5),
                      if (member.phoneMobile != null &&
                          member.phoneMobile!.length != 0)
                        InkWell(
                          onTap: () async {
                            try {
                              await launch(
                                'tel://${member.phoneMobile}',
                              );
                            } catch (e) {
                              debugPrint(CustomTrace(StackTrace.current,
                                  message: (e as dynamic).message).toString());
                            }
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.phone, size: 20),
                              Text(" " + member.phoneMobile!),
                            ],
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            if (permission == 1 || permission == 2)
              IconSlideAction(
                caption: AppLocalizations.of(context)!.appButtonEdit,                           // 'Edit',
                color: Theme.of(context).accentColor,
                icon: Icons.edit_outlined,
                onTap: () {
                  member_repo.editId = member.id;
                  Navigator.of(context).pushNamed('/EditMember');
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
