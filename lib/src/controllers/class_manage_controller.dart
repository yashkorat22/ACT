import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../helpers/helper.dart';
import '../repository/class_repository.dart' as class_repo;
import '../models/classMember.dart';
import '../models/classEvent.dart';
import 'package:flutter_gen/gen_l10n/s.dart';
class ClassMemberController extends ControllerMVC {
  GlobalKey<ScaffoldState>? scaffoldKey;
  OverlayEntry? loader;
  BuildContext? context;

  @override
  initState() {
    context = state!.context;
  }

  ClassMemberController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void showLoader() {
    loader = Helper.overlayLoader(context);
    Overlay.of(context!)!.insert(loader!);
  }

  void hideLoader() {
    Helper.hideLoader(loader);
  }

  Future<List<ClassMember>> getClassMembers() async {
    try {
      return await class_repo.fetchClassMembers();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<ClassEvent>> getClassEvents() async {
    try {
      return await class_repo.fetchClassEvents();
    } catch (e) {
      print(e);
      return [];
    }
  }
  Future<void> getCalendarEvents(DateTime? first, DateTime? last) async {
    try {
      await class_repo.fetchCalendarEvents(first: first, last: last);
    } catch(e) {
      print(e);
    }
  }

  Future<bool> admissClassMember(int? classId, int memberId) async {
    showLoader();
    bool success = false;
    try {
      final response = await class_repo.admissClassMember(classId, memberId);
      if (response != 'true') {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text( AppLocalizations.of(context!)!.appInfoAdmissSuccessfully ),             // "The member has been successfully admissed."
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

  Future<bool> dismissClassMember(int? classId, int memberId) async {
    showLoader();
    bool success = false;
    try {
      final response = await class_repo.dismissClassMember(classId, memberId);
      if (response != 'true') {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text( AppLocalizations.of(context!)!.appInfoDismissSuccessfully ),            // "The member has been successfully dismissed."
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

  Future<bool> deleteClassEvent(int eventId) async {
    showLoader();
    bool success = false;
    try {
      final response = await class_repo.deleteClassEvent(eventId);
      if (response != 'true') {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text( AppLocalizations.of(context!)!.appInfoRemoveSuccessfully ),            // "The event has been successfully deleted."
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

  Future<bool> cancelCalendarEvent(ClassEvent event) async {
    showLoader();
    bool success = false;
    try {
      final response = await class_repo.cancelCalendarEvent(event);
      if (response != 'true') {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text( AppLocalizations.of(context!)!.appInfoAbsagenSuccessfully ),            // "The event has been successfully deleted."
        ));
        success = true;
      }
    } catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text((e as dynamic).message),
      ));
    } finally {
      if (!success) {
        Helper.hideLoader(loader);
      }
    }
    return success;
  }

  Future<bool> scheduleCalendarEvent(ClassEvent event) async {
    showLoader();
    bool success = false;
    try {
      final response = await class_repo.scheduleCalendarEvent(event);
      if (response != 'true') {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text( AppLocalizations.of(context!)!.appInfoScheduleSuccessfully ),           // "The event has been successfully scheduled."
        ));
        success = true;
      }
    } catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text((e as dynamic).message),
      ));
    } finally {
      if (!success) {
        Helper.hideLoader(loader);
      }
    }
    return success;
  }
}
