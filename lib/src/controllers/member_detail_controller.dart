import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../repository/member_repository.dart' as member_repo;
import '../helpers/helper.dart';
import '../models/member.dart';

final genders = <String>['Unknown', 'Female', 'Male', 'Other'];
final isoCodes = [
  {
    'locale': 'GB',
    'code': '+44',
  },
  {
    'locale': 'US',
    'code': '+1',
  },
  {
    'locale': 'RU',
    'code': '+7',
  },
  {
    'locale': 'CH',
    'code': '+41',
  },
  {
    'locale': 'DE',
    'code': '+49',
  },
  {
    'locale': 'LI',
    'code': '+423',
  },
  {
    'locale': 'FR',
    'code': '+33',
  },
  {
    'locale': 'IT',
    'code': '+39',
  },
];

class MemberDetailController extends ControllerMVC {
  GlobalKey<ScaffoldState>? scaffoldKey;
  GlobalKey<FormState>? memberFormKey;
  OverlayEntry? loader;

  int? gender = 0;
  String? phone;
  PhoneNumber phoneNumber = PhoneNumber();
  String? avatarURL;

  bool? isWpUser = false;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String birthday = "";

  BuildContext? context;

  MemberDetailController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    memberFormKey = new GlobalKey<FormState>();
  }

  @override
  void initState() {
    super.initState();
    firstNameController.text = '';
    lastNameController.text = '';
    gender = 0;
    birthday = '';
    emailController.text = '';
    phone = '';

    context = state!.context;
    loader = Helper.overlayLoader(context);
  }

  Future<void> createMember() async {
    FocusScope.of(context!).requestFocus(new FocusNode());
    if (!memberFormKey!.currentState!.validate()) {
      return;
    }
    Overlay.of(context!)!.insert(loader!);
    try {
      final response = await member_repo.createMember({
        'firstname': firstNameController.text,
        'lastname': lastNameController.text,
        'gender': gender,
        'birthday': birthday,
        'phone_mobile': phone,
        'email': emailController.text,
      });
      if (response == 'true') {
        Helper.hideLoader(loader);
        Navigator.of(scaffoldKey!.currentContext!)
            .pushReplacementNamed('/Members');
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

  Future<void> fetchMemberDetail() async {
    try {
      final Member response = await member_repo.fetchMember();

      firstNameController.text = response.firstName!;
      lastNameController.text = response.lastName!;
      emailController.text = response.email!;
      phone = response.phoneMobile;
      setState(() {
        birthday = response.birthday!;
      });

      if (phone != null) {
        final code = isoCodes.firstWhere(
            (item) => phone!.startsWith(item['code']!),
            orElse: () => {'locale': '', 'code': ''});
        setState(() {
          phoneNumber = PhoneNumber(isoCode: code['locale']);
        });
        phoneController.text =
            response.phoneMobile!.substring(code['code']!.length);
      }
      setState(() {
        gender = response.gender;
        isWpUser = response.isWpUser;
        avatarURL = response.avatarUrl;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateMember() async {
    FocusScope.of(context!).requestFocus(new FocusNode());
    if (!memberFormKey!.currentState!.validate()) {
      return;
    }
    Overlay.of(context!)!.insert(loader!);
    try {
      final response = await member_repo.updateMember({
        'firstname': firstNameController.text,
        'lastname': lastNameController.text,
        'gender': gender,
        'birthday': birthday,
        'phone_mobile': phone,
        'email': emailController.text,
      });
      if (response == 'true') {
        Helper.hideLoader(loader);
        Navigator.of(scaffoldKey!.currentContext!)
            .pushReplacementNamed('/Members');
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

  Future<void> deleteMember(int? memberId) async {
    Overlay.of(context!)!.insert(loader!);
    try {
      final response = await member_repo.deleteMember(memberId);
      if (response != 'true') {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        Navigator.of(scaffoldKey!.currentContext!).pushReplacementNamed('/Members');
      }
    } catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text((e as dynamic).message),
      ));
    } finally {
      Helper.hideLoader(loader);
    }
  }

  Future<void> disconnectSelfManaged() async {

    Overlay.of(context!)!.insert(loader!);
    try {
      final response = await member_repo.disconnectSelfManaged();
      if (response != 'true') {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        await fetchMemberDetail();
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
