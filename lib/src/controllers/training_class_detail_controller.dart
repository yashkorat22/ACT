import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../repository/class_repository.dart' as class_repo;
import '../helpers/helper.dart';
import '../models/trainingClass.dart';

//final activityIds = <String>['Unknown', 'Female', 'Male', 'Other'];

class TrainingClassDetailController extends ControllerMVC {
  GlobalKey<ScaffoldState>? scaffoldKey;
  GlobalKey<FormState>? classFormKey;
  OverlayEntry? loader;
  int? avatarId;

  String? avatarURL;
  int? activityId = 0;
  int? public = 1;
  int? autoAssign = 1;

  TextEditingController nameController = TextEditingController();
  BuildContext? context;

  TrainingClassDetailController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    classFormKey = new GlobalKey<FormState>();
  }

  @override
  void initState() {
    super.initState();
    nameController.text = '';
    activityId = 0;
    public = 1;
    autoAssign = 1;

    context = state!.context;
    loader = Helper.overlayLoader(context);
  }

  Future<void> createClass() async {
    FocusScope.of(context!).requestFocus(new FocusNode());
    if (!classFormKey!.currentState!.validate()) {
      return;
    }
    Overlay.of(context!)!.insert(loader!);
    try {
      avatarId = null;
      if (avatarURL != null) {
        final avatar = class_repo.avatarList.value
            .firstWhere((avatar) => avatar.avatarUrl == avatarURL);
        avatarId = avatar.id;
      }
      final response = await class_repo.createTrainingClass({
        'name': nameController.text,
        'avatar_id': avatarId,
        'activity_id': activityId,
        'public': public,
        'autoAssign': autoAssign,
      });
      if (response == 'true') {
        Helper.hideLoader(loader);
        Navigator.of(scaffoldKey!.currentContext!).pop();
      } else {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      }
    } catch (e) {
      var message = jsonDecode((e as dynamic).message)['message'];
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text(message),
      ));
    } finally {
      Helper.hideLoader(loader);
    }
  }

  Future<void> fetchDetail() async {
    try {
      final TrainingClass response = await class_repo.fetchTrainingClass();

      nameController.text = response.name!;

      setState(() {
        activityId = response.activityId;
        avatarURL = response.avatarUrl;
        public = response.public;
        autoAssign = response.autoAssign;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateClass() async {
    FocusScope.of(context!).requestFocus(new FocusNode());
    if (!classFormKey!.currentState!.validate()) {
      return;
    }
    Overlay.of(context!)!.insert(loader!);
    try {
      avatarId = null;
      if (avatarURL != null &&
          class_repo.avatarList.value
                  .where((avatar) => avatar.avatarUrl == avatarURL)
                  .length >
              0) {
        final avatar = class_repo.avatarList.value
            .firstWhere((avatar) => avatar.avatarUrl == avatarURL);
        avatarId = avatar.id;
      }
      final response = await class_repo.updateClass({
        'name': nameController.text,
        'avatar_id': avatarId,
        'activity_id': activityId,
        'public': public,
        'autoAssign': autoAssign,
      });
      if (response == 'true') {
        Helper.hideLoader(loader);
        Navigator.of(scaffoldKey!.currentContext!).pop();
      } else {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      }
    } catch (e) {
      print(e);
      print((e as dynamic).message);
      // var message = jsonDecode(e.message)['message'];
      // ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
      //   content: Text(message),
      // ));
    } finally {
      Helper.hideLoader(loader);
    }
  }

  Future<void> deleteClass(int? classId) async {
    Overlay.of(context!)!.insert(loader!);
    try {
      final response = await class_repo.deleteClass(classId);
      if (response != 'true') {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        class_repo.deletedTrainingClassId.value = classId;
        Navigator.of(context!).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text((e as dynamic).message),
      ));
    } finally {
      Helper.hideLoader(loader);
    }
  }
}
