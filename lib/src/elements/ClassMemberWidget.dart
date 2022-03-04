import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/classMember.dart';
import '../repository/user_repository.dart' as user_repo;

class ClassMemberWidget extends StatelessWidget {
  final ClassMember member;
  final Function onAdmiss;
  final Function onDismiss;

  ClassMemberWidget(
      {Key? key,
      required this.member,
      required this.onAdmiss,
      required this.onDismiss})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color classMemberBackgroundColor = Color.alphaBlend(
        Colors.greenAccent.shade400.withOpacity(0.7), Theme.of(context).backgroundColor);
    final Color classMemberAccentColor = Color.alphaBlend(
        Colors.greenAccent.shade400.withOpacity(0.7), Theme.of(context).accentColor);
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          child: Container(
            padding: EdgeInsets.all(15),
            color: member.isClassMember!
                ? classMemberBackgroundColor.withOpacity(0.3)
                : Theme.of(context).backgroundColor.withOpacity(0.3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: CachedNetworkImage(
                      key: new Key(member.memberId.toString()),
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
                              size: 75, color: Theme.of(context).primaryColor),
                          color: member.isClassMember!
                              ? classMemberAccentColor
                              : Theme.of(context).accentColor),
                    )),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          (member.memberFirstName! +
                                          ' ' +
                                          member.memberLastName!)
                                      .length <
                                  20
                              ? member.memberFirstName! +
                                  ' ' +
                                  member.memberLastName!
                              : (member.memberFirstName! +
                                          ' ' +
                                          member.memberLastName!)
                                      .substring(0, 17) +
                                  '...',
                          style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).hintColor)),
                    ],
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            if (!member.isClassMember!)
              IconSlideAction(
                caption: AppLocalizations.of(context)!.appButtonAdmiss,                         //'Admiss',
                foregroundColor: Theme.of(context).primaryColor,
                color: classMemberAccentColor,
                icon: Icons.login_rounded,
                onTap: () {
                  onAdmiss(member.memberId);
                },
              ),
          ],
          secondaryActions: <Widget>[
            if (member.isClassMember!)
              IconSlideAction(
                caption: AppLocalizations.of(context)!.appButtonDismiss,                         //'Dismiss',
                color: Colors.red,
                icon: Icons.logout,
                onTap: () {
                  onDismiss(member.memberId);
                },
              ),
          ],
        ),
      ),
    );
  }
}
