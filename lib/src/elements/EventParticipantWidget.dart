import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/eventParticipant.dart';

import '../repository/user_repository.dart' as user_repo;

class EventParticipantWidget extends StatelessWidget {
  final EventParticipant participant;
  final Function onAdmiss;
  final Function onDismiss;

  int? permission = 3;

  EventParticipantWidget(
      {Key? key,
      required this.participant,
      required this.onAdmiss,
      required this.onDismiss})
      : super(key: key) {
    permission = user_repo.currentUserSocieties.value
        .firstWhere((so) => so.isPrimary == true)
        .permission;
  }

  @override
  Widget build(BuildContext context) {
    final Color classMemberAccentColor = Color.alphaBlend(
        Colors.greenAccent.shade400.withOpacity(0.7),
        Theme.of(context).accentColor);

    final List<Color> participantColors = [
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
            color: participant.participationStatusId! > 0 &&
                    participant.participationStatusId! < 4
                ? participantColors[participant.participationStatusId! - 1]
                    .withOpacity(0.3)
                : Theme.of(context).backgroundColor.withOpacity(0.3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: CachedNetworkImage(
                      key: new Key(participant.memberId.toString()),
                      width: 75,
                      height: 75,
                      fit: BoxFit.cover,
                      imageUrl: participant.avatarUrl!,
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
                          color: Theme.of(context).accentColor),
                    )),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        (participant.memberFirstName! +
                                        ' ' +
                                        participant.memberLastName!)
                                    .length <
                                20
                            ? participant.memberFirstName! +
                                ' ' +
                                participant.memberLastName!
                            : (participant.memberFirstName! +
                                        ' ' +
                                        participant.memberLastName!)
                                    .substring(0, 17) +
                                '...',
                        style: TextStyle(
                            fontSize: 20, color: Theme.of(context).hintColor),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          if (participant.participationStatusId == 1)
                            Icon(Icons.thumb_up),
                          if (participant.participationStatusId == 2)
                            Icon(Icons.thumb_down),
                          if (participant.participationStatusId == 3)
                            Icon(Icons.close),
                          if (participant.participationStatusId == 4)
                            Icon(Icons.app_registration),
                          Text(participant.participationStatusName!),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            if ((permission == 1 || permission == 2 || permission == 3) &&
                participant.participationStatusId != 1)
              IconSlideAction(
                caption: AppLocalizations.of(context)!.appButtonParticipated,                   // 'Admiss',
                foregroundColor: Theme.of(context).primaryColor,
                color: classMemberAccentColor,
                icon: Icons.login_rounded,
                onTap: () {
                  onAdmiss();
                },
              ),
          ],
          secondaryActions: <Widget>[
            if ((permission == 1 || permission == 2 || permission == 3) &&
                participant.participationStatusId != 0)
              IconSlideAction(
                caption: AppLocalizations.of(context)!.appButtonStornieren,                     // 'Dismiss',
                color: Colors.red,
                icon: Icons.logout,
                onTap: () {
                  onDismiss();
                },
              ),
          ],
        ),
      ),
    );
  }
}
