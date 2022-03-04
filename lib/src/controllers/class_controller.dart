import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../helpers/helper.dart';
import '../repository/class_repository.dart' as class_repo;
import '../models/memberClass.dart';
import '../models/trainingClass.dart';
import '../models/discoveredClass.dart';
import 'package:flutter_gen/gen_l10n/s.dart';

class ClassController extends ControllerMVC {
  GlobalKey<ScaffoldState>? scaffoldKey;
  OverlayEntry? loader;
  BuildContext? context;

  @override
  initState() {
    context = state!.context;
    class_repo.fetchAvatarList();
  }

  ClassController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    loader = Helper.overlayLoader(context);
  }

  void showLoader() {
    Overlay.of(context!)!.insert(loader!);
  }

  void hideLoader() {
    Helper.hideLoader(loader);
  }

  Future<List<MemberClass>> getMemberClasses() async {
    try {
      return await class_repo.fetchMemberClasses();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<TrainingClass>> getTrainingClasses() async {
    try {
      return await class_repo.fetchTrainingClasses();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<bool> deleteTrainingClass(int? classId) async {
    Overlay.of(context!)!.insert(loader!);
    bool success = false;
    try {
      final response = await class_repo.deleteClass(classId);
      if (response != 'true') {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text( AppLocalizations.of(context!)!.appInfoDeleteSuccessfully ),             // "The class has successfully been deleted."
        ));
        success = true;
      }
    } catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text((e as dynamic).message),
      ));
    } finally {
      Helper.hideLoader(loader);
    }
    return success;
  }

  Future<List<DiscoveredClass>> discoverClasses() async {
    try {
      return await class_repo.discoverClasses();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<int?> requestApplication(societyId, classId) async {
    Overlay.of(context!)!.insert(loader!);
    int? applicationId = 0;
    try {
      final response = await class_repo.requestApplication(societyId, classId);
      if (response is String) {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text( AppLocalizations.of(context!)!.appInfoRegisterSuccessfully ),           // "Your application has been successfully stored"
        ));
        applicationId = response["application_id"];
      }
    } catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text((e as dynamic).message),
      ));
    } finally {
      Helper.hideLoader(loader);
    }
    return applicationId;
  }

  Future<bool> cancelApplication(societyId, classId, applicationId) async {
    Overlay.of(context!)!.insert(loader!);
    bool result = false;
    try {
      final response = await class_repo.cancelApplication(
        societyId,
        classId,
        applicationId,
      );
      if (response is String) {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text( AppLocalizations.of(context!)!.appInfoCancelSuccessfully ),             // "Your application has been successfully cancelled"
        ));
        result = true;
      }
    } catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text((e as dynamic).message),
      ));
    } finally {
      Helper.hideLoader(loader);
    }
    return result;
  }
}
