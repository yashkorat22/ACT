import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../helpers/helper.dart';
import '../repository/class_repository.dart' as class_repo;
import '../repository/user_repository.dart' as user_repo;
import '../models/classEvent.dart';
import '../models/myEvent.dart';
import 'package:flutter_gen/gen_l10n/s.dart';

class EventsController extends ControllerMVC {
  GlobalKey<ScaffoldState>? scaffoldKey;
  OverlayEntry? loader;
  BuildContext? context;

  EventsController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void showLoader() {
    Overlay.of(context!)!.insert(loader!);
  }

  @override
  initState() {
    context = state!.context;
    loader = Helper.overlayLoader(context);
  }

  void hideLoader() {
    Helper.hideLoader(loader);
  }

  Future<void> getMemberEvents(DateTime? first, DateTime? last) async {
    try {
      await user_repo.getMyEvents(first: first, last: last);
    } catch(e) {
      print(e);
    }
  }

  Future<void> getTrainerEvents(DateTime? first, DateTime? last) async {
    try {
      await class_repo.fetchAllCalendarEvents(first: first, last: last);
    } catch(e) {
      print(e);
    }
  }

  Future<bool> cancelCalendarEvent(ClassEvent event) async {
    Overlay.of(context!)!.insert(loader!);
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
          content: Text( AppLocalizations.of(context!)!.appInfoAbsagenSuccessfully ),            //"The event has been successfully cancelled."
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
    Overlay.of(context!)!.insert(loader!);
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

  Future<bool> cancelMyCalendarEvent(MyEvent event) async {
    Overlay.of(context!)!.insert(loader!);
    bool success = false;
    try {
      final response = await user_repo.cancelCalendarEvent(event);
      if (response != 'true') {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text( AppLocalizations.of(context!)!.appInfoAbsagenSuccessfully ),            //"The event has been successfully cancelled."
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

  Future<bool> registerCalendarEvent(MyEvent event) async {
    Overlay.of(context!)!.insert(loader!);
    bool success = false;
    try {
      final response = await user_repo.registerCalendarEvent(event);
      if (response != 'true') {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text( AppLocalizations.of(context!)!.appInfoRegisterSuccessfully ),           // "You've registered successfully."
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
