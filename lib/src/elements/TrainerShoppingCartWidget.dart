import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cached_network_image/cached_network_image.dart';


import '../models/shoppingCart.dart';
import '../repository/user_repository.dart' as user_repo;

class TrainerShoppingCartWidget extends StatelessWidget {
  final ShoppingCart shoppingCartInfo;
  final Function onDelete;

  int? permission = 3;

  TrainerShoppingCartWidget(
      {Key? key, required this.shoppingCartInfo, required this.onDelete})
      : super(key: key) {
    permission = user_repo.currentUserSocieties.value
        .firstWhere((so) => so.isPrimary == true)
        .permission;
  }

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
              color: shoppingCartInfo.shoppingCartPaymentId! > 0
                  ? Colors.greenAccent.withOpacity(0.5)
                  : (shoppingCartInfo.shoppingCartCount! > 0 &&
                          shoppingCartInfo.shoppingCartPaymentId! < 1
                      ? Colors.redAccent.withOpacity(0.5)
                      : (shoppingCartInfo.shoppingCartCount == 0
                          ? Colors.blueAccent.withOpacity(0.5)
                          : Theme.of(context).accentColor.withOpacity(0.5))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: CachedNetworkImage(
                        key: new Key(shoppingCartInfo.memberId.toString()),
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                        imageUrl: shoppingCartInfo.avatarUrl!,
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
                          color: shoppingCartInfo.shoppingCartPaymentId! > 0
                              ? Colors.greenAccent
                              : (shoppingCartInfo.shoppingCartCount! > 0 &&
                                      shoppingCartInfo
                                              .shoppingCartPaymentId! <
                                          1
                                  ? Colors.redAccent
                                  : (shoppingCartInfo.shoppingCartCount == 0
                                      ? Colors.blueAccent
                                      : Theme.of(context).accentColor)),
                        ),
                      )),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            (shoppingCartInfo.memberFirstName! +
                                            " " +
                                            shoppingCartInfo.memberLastName!)
                                        .length <
                                    20
                                ? (shoppingCartInfo.memberFirstName! +
                                    " " +
                                    shoppingCartInfo.memberLastName!)
                                : (shoppingCartInfo.memberFirstName! +
                                            " " +
                                            shoppingCartInfo.memberLastName!)
                                        .substring(0, 17) +
                                    '...',
                            style: TextStyle(
                              fontSize: 20,
                            )),
                        SizedBox(height: 5),
                        if (shoppingCartInfo.shoppingCartPrice != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.money,
                                size: 20,
                              ),
                              Text(" " +
                                  shoppingCartInfo.shoppingCartCurrencyText! +
                                  " " +
                                  shoppingCartInfo.shoppingCartPrice
                                      .toString()),
                            ],
                          ),
                        if (shoppingCartInfo.shoppingCartCount != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_basket,
                                size: 20,
                              ),
                              Text(
                                " " +
                                    shoppingCartInfo.shoppingCartCount
                                        .toString(),
                              ),
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
                Navigator.of(context).pushNamed('/ManageSingleShoppingCart',
                    arguments: shoppingCartInfo);
              }
            },
          ),
          secondaryActions: <Widget>[
            if (permission == 1 || permission ==2)
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
