import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../elements/BlockButtonWidget.dart';

import '../../../models/activity.dart';

import '../../../controllers/training_class_detail_controller.dart';

import '../../../repository/user_repository.dart' as user_repo;
import '../../../repository/class_repository.dart' as class_repo;

class CreateTrainingWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  CreateTrainingWidget({Key? key, this.parentScaffoldKey}) : super(key: key);
  @override
  _CreateTrainingWidgetState createState() => _CreateTrainingWidgetState();
}

class _CreateTrainingWidgetState extends StateMVC<CreateTrainingWidget> {
  late TrainingClassDetailController _con;

  String phoneNum = '', phoneCode = '';
  List<Activity> activities = [];

  _CreateTrainingWidgetState() : super(TrainingClassDetailController()) {
    _con = controller as TrainingClassDetailController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    activities = user_repo.activities.value;
    user_repo.activities.addListener(() {
      setState(() {
        activities = user_repo.activities.value;
      });
    });
    class_repo.avatarId.addListener(() {
      final avatar = class_repo.avatarList.value
          .firstWhere((avatar) => avatar.id == class_repo.avatarId.value);
      setState(() {
        _con.avatarURL = avatar.avatarUrl;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        key: _con.scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).accentColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.classCreateClass,                                     // 'Create Class',
            style: Theme.of(context).textTheme.headline6!.merge(
                  TextStyle(
                    letterSpacing: 1.3,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            padding: EdgeInsets.only(left: 25, right: 25, top: 15),
            child: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: <Widget>[
                Positioned(
                  top: -5,
                  left: -15,
                  child: IconButton(
                    icon: new Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Column(children: [
                  SizedBox(height: 10),
                  Stack(children: <Widget>[
                    CircleAvatar(
                      radius: 82,
                      backgroundColor: Theme.of(context).accentColor,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(155.0),
                          child: _con.avatarURL != null
                              ? CachedNetworkImage(
                                  width: 158,
                                  height: 158,
                                  fit: BoxFit.cover,
                                  imageUrl: _con.avatarURL!,
                                  httpHeaders: {
                                    'X-WP-Nonce':
                                        user_repo.currentUser.value.nonce!,
                                    'Cookie':
                                        user_repo.currentUser.value.cookie!,
                                  },
                                  progressIndicatorBuilder: (context, url,
                                          downloadProgress) =>
                                      Center(
                                          child: CircularProgressIndicator(
                                              value:
                                                  downloadProgress.progress)),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                          child: Icon(Icons.sports,
                                              size: 120,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          color: Theme.of(context).accentColor),
                                )
                              : Container(
                                  child: Icon(Icons.person,
                                      size: 120,
                                      color: Theme.of(context).primaryColor),
                                  color: Theme.of(context).accentColor)),
                    ),
                    Positioned(
                      top: 120,
                      right: 5,
                      child: InkWell(
                        splashColor: Theme.of(context).hoverColor,
                        onTap: () =>
                            Navigator.of(context).pushNamed('/ClassAvatarList'),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(context).hoverColor,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Icon(
                              Icons.add_a_photo,
                              color: Theme.of(context).accentColor,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_con.avatarURL != null)
                      Positioned(
                        top: 120,
                        left: 5,
                        child: InkWell(
                          splashColor: Theme.of(context).hoverColor,
                          onTap: () {
                            setState(() {
                              _con.avatarURL = null;
                            });
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Theme.of(context).hoverColor,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ]),
                  SizedBox(height: 50),
                  Form(
                    key: _con.classFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _con.nameController,
                          onSaved: (input) => _con.nameController.text = input!,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.sentences,
                          validator: (input) => input!.length < 1
                              ? AppLocalizations.of(context)!.appInputMandatoryField            // 'Input the class name'
                              : (input.length > 255
                                  ? AppLocalizations.of(context)!.appInputValidationLengthMax +'255'          //'Class name should be less than 255 letters.'
                                  : null),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.className,                 // "Class Name",
                            labelStyle:
                                TextStyle(color: Theme.of(context).accentColor),
                            contentPadding: EdgeInsets.all(12),
                            hintText: 'My First Class',
                            hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .focusColor
                                    .withOpacity(0.7)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.2))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.5))),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.2))),
                          ),
                        ),
                        SizedBox(height: 15),
                        SizedBox(height: 15),
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.classActivity,             // "Activity",
                            labelStyle:
                                TextStyle(color: Theme.of(context).accentColor),
                            contentPadding: EdgeInsets.all(12),
                            hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .focusColor
                                    .withOpacity(0.7)),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.2))),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.5))),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.2))),
                          ),
                          value: _con.activityId != null &&
                                  activities.length > _con.activityId!
                              ? activities[_con.activityId!].name
                              : 'Unknown',
                          onTap: () {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                          },
                          onChanged: (String? newValue) {
                            setState(() {
                              _con.activityId = activities.indexWhere(
                                  (activity) => activity.name == newValue);
                            });
                          },
                          items: activities.map<DropdownMenuItem<String>>(
                              (Activity activity) {
                            return DropdownMenuItem<String>(
                              value: activity.name,
                              child: Text(activity.name!),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: <Widget>[
                            Checkbox(
                              value: _con.public! > 0,
                              onChanged: (value) {
                                setState(() => _con.public = (value! ? 1 : 0));
                              },
                              activeColor: Theme.of(context).accentColor,
                              checkColor: Theme.of(context).primaryColor,
                              hoverColor: Theme.of(context).accentColor,
                              focusColor: Theme.of(context).accentColor,
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() => _con.public = 1 - _con.public!);
                              },
                              child: Text(
                                AppLocalizations.of(context)!.classPublic,                      // "Public",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .merge(
                                      TextStyle(
                                          color: Theme.of(context).accentColor),
                                    ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 1),
                        Row(
                          children: <Widget>[
                            Checkbox(
                              value: _con.autoAssign! > 0,
                              onChanged: (value) {
                                setState(() => _con.autoAssign = (value! ? 1 : 0));
                              },
                              activeColor: Theme.of(context).accentColor,
                              checkColor: Theme.of(context).primaryColor,
                              hoverColor: Theme.of(context).accentColor,
                              focusColor: Theme.of(context).accentColor,
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() => _con.autoAssign = 1 - _con.autoAssign!);
                              },
                              child: Text(
                                AppLocalizations.of(context)!.classAutoAssignMembers,                // "Assign my members automatically",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .merge(
                                  TextStyle(
                                      color: Theme.of(context).accentColor),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 15),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          child: BlockButtonWidget(
                            text: Text(
                              AppLocalizations.of(context)!.appButtonCreate,                    // "Save",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                            color: Theme.of(context).accentColor,
                            onPressed: () {
                              TextInput.finishAutofillContext(shouldSave: true);
                              _con.createClass();
                            },
                          ),
                        ),
                        SizedBox(height: 50),
                      ],
                    ),
                  ),
                ])
              ],
            ),
          ),
        ),
      ),
    );
  }
}
