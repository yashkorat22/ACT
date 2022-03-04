import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../repository/class_repository.dart' as class_repo;
import '../../../repository/user_repository.dart' as user_repo;

import '../../../helpers/app_config.dart' as config;

class ClassAvatarList extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  ClassAvatarList({Key? key, this.parentScaffoldKey}) : super(key: key);
  @override
  _ClassAvatarListState createState() => _ClassAvatarListState();
}

class _ClassAvatarListState extends StateMVC<ClassAvatarList> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).accentColor,
          elevation: 0,
          centerTitle: true,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back,
                color: Theme.of(context).primaryColor),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            AppLocalizations.of(context)!.classAvatarSelect,                                    // 'Select Avatar',
            style: Theme.of(context).textTheme.headline6!.merge(
                  TextStyle(
                    letterSpacing: 1.3,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
          ),
        ),
        body: Container(
          height: config.App(context).appHeight(100),
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          padding: EdgeInsets.only(left: 25, right: 25, top: 15),
          child: GridView.count(
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            children: class_repo.avatarList.value.map((avatar) {
              return InkWell(
                onTap: () {
                  class_repo.avatarId.value = avatar.id;
                  Navigator.of(context).pop();
                },
                child: Column(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: avatar.avatarUrl!,
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
                                size: 80,
                                color: Theme.of(context).primaryColor),
                            color: Theme.of(context).accentColor),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
