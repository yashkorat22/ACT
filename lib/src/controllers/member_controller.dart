import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../helpers/helper.dart';
import '../repository/member_repository.dart' as member_repo;
import '../models/member.dart';
import '../models/applicant.dart';
import 'package:flutter_gen/gen_l10n/s.dart';
// = Helper for missing context when use for AppLocalizations.of(context)!...


class MemberController extends ControllerMVC {
  GlobalKey<ScaffoldState>? scaffoldKey;
  OverlayEntry? loader;
  BuildContext? context;

  MemberController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    context = state!.context;
    loader = Helper.overlayLoader(context);
  }

  void showLoader() {
    Overlay.of(context!)!.insert(loader!);
  }
  void hideLoader() {
    Helper.hideLoader(loader);
  }
  Future<List<Member>> getMembers() async {
    try {
      return await member_repo.fetchMembers();
    } catch(e) {
      print(e);
      return [];
    }
  }
  Future<bool> deleteMember(int? memberId) async {
    Overlay.of(context!)!.insert(loader!);
    bool success = false;
    try {
      final response = await member_repo.deleteMember(memberId);
      if (response != 'true') {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text( AppLocalizations.of(context!)!.appInfoDeleteSuccessfully ),             // "The member has successfully been deleted."
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

  Future<List<Applicant>> getApplicants() async {
    try {
      return await member_repo.fetchApplicants();
    } catch(e) {
      print(e);
      return [];
    }
  }

  Future<bool> acceptApplication(int? applicationId) async {
    Overlay.of(context!)!.insert(loader!);
    bool success = false;
    try {
      final response = await member_repo.acceptApplication(applicationId);
      if (response != 'true') {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text( AppLocalizations.of(context!)!.appInfoAcceptSuccessfully ),              // "The application has successfully been accepted."
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

  Future<bool> declineApplication(int? applicationId) async {
    Overlay.of(context!)!.insert(loader!);
    bool success = false;
    try {
      final response = await member_repo.declineApplication(applicationId);
      if (response != 'true') {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text( AppLocalizations.of(context!)!.appInfoAcceptSuccessfully ),              // "The application has successfully been accepted."
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
}
