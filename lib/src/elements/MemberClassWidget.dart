import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:intl/intl.dart';

import '../models/memberClass.dart';
import '../repository/user_repository.dart' as user_repo;

class MemberClassWidget extends StatelessWidget {
  final MemberClass classInfo;
  final Function onDelete;

  int? permission = 3;

  MemberClassWidget(
      {Key? key, required this.classInfo, required this.onDelete})
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
          child: Container(
            padding: EdgeInsets.all(15),
            color: Theme.of(context).backgroundColor.withOpacity(0.3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: CachedNetworkImage(
                      key: Key(classInfo.classId.toString()),
                      width: 75,
                      height: 75,
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
                              size: 75, color: Theme.of(context).primaryColor),
                          color: Theme.of(context).accentColor),
                    )),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          classInfo.className!.length < 20
                              ? classInfo.className!
                              : classInfo.className!.substring(0, 17) + '...',
                          style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).hintColor)),
                      SizedBox(height: 5),
                      if (classInfo.ownerFirstName != null &&
                          classInfo.ownerFirstName!.length != 0)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.person, size: 20),
                            Text(" " + classInfo.ownerFirstName! + " " + classInfo.ownerLastName!),
                          ],
                        ),
                      SizedBox(height: 5),
                      if (classInfo.classMemberSince != null &&
                          classInfo.classMemberSince!.length != 0)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.beenhere,
                                size: 20,),
                            Text(
                                " " +
                                    DateFormat.yMMMd(localeCode).format(
                                        DateTime.parse(
                                            classInfo.classMemberSince!)),),
                          ],
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
