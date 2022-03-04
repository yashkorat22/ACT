import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/location.dart';
import '../repository/user_repository.dart' as user_repo;

class MemberLocationWidget extends StatelessWidget {
  final ActLocation location;
  final Function? onDelete;
  final Function? onEdit;


  MemberLocationWidget(
      {Key? key, required this.location, this.onDelete, this.onEdit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      borderRadius: BorderRadius.circular(10.0),
                      child: Container(
                          padding: EdgeInsets.all(3),
                          child: Icon(
                              location.mapServiceType == 0
                                  ? Icons.not_listed_location_outlined
                                  : Icons.location_on_outlined,
                              size: 45,
                              color: Theme.of(context).primaryColor),
                          color: Theme.of(context).accentColor)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.name!.length < 20
                              ? location.name!
                              : location.name!.substring(0, 17) + '...',
                          style: TextStyle(
                              fontSize: 20, color: Theme.of(context).hintColor),
                        ),
                        SizedBox(height: 5),
                        if (location.ownerFullName != null)
                          Text(
                            location.ownerFullName!,
                            style:
                                TextStyle(color: Theme.of(context).hintColor),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            onTap: () {
              Navigator.of(context)
                  .pushNamed('/LocationDetail', arguments: location);
            },
          ),
          actions: <Widget>[
            if ((location.locationPermission ?? 0) > 0 && onEdit != null)
              IconSlideAction(
                  caption: AppLocalizations.of(context)!.appButtonEdit,
                  color: Colors.green,
                  icon: Icons.edit_outlined,
                  onTap: () {
                    if (onEdit != null) onEdit!();
                  }),
          ],
          secondaryActions: <Widget>[
            if ((location.locationPermission ?? 0) > 0 && onDelete != null)
              IconSlideAction(
                  caption: AppLocalizations.of(context)!.appButtonDelete,
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () {
                    if (onDelete != null) onDelete!();
                  }),
          ],
        ),
      ),
    );
  }
}
