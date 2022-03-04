import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:email_validator/email_validator.dart';

import '../helpers/helper.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as repository;
import 'package:flutter_gen/gen_l10n/s.dart';
// = Helper for missing context when use for AppLocalizations.of(context!)!...

class UserController extends ControllerMVC {
  User user = new User();
  String? code = "";
  bool invalidCode = false;
  bool hidePassword = true;
  bool hideCode = true;
  bool loading = false;
  bool acceptTermValidate = false;
  GlobalKey<FormState>? loginFormKey;
  GlobalKey<ScaffoldState>? scaffoldKey;
  OverlayEntry? loader;
  bool isLogin = false;
  BuildContext? context;

  UserController(bool isL) {
    isLogin = isL;
    loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    context = state!.context;
    loader = Helper.overlayLoader(context);
  }

  void login() async {
    FocusScope.of(context!).unfocus();
    if (loginFormKey!.currentState!.validate()) {
      loginFormKey!.currentState!.save();
      Overlay.of(context!)!.insert(loader!);
      repository.login(user).then((value) {
        if (value != null) {
          Navigator.of(scaffoldKey!.currentContext!).pushReplacementNamed(
              '/Home');
        } else {
          ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
            content: Text( AppLocalizations.of(context!)!.appInputValidationCredentials ),       // Username or password invalid
          ));
        }
      }).catchError((e) {
        var message = jsonDecode(e.message)['message'];
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  void checkEmailToRestPassword() async {
    loginFormKey!.currentState!.save();
    if (EmailValidator.validate(user.email!)) {
      Overlay.of(context!)!.insert(loader!);
      repository.emailForResetPassword(user).then((value) {
        if (value) {
          Navigator.of(scaffoldKey!.currentContext!).pushNamed(
              '/ForgotPassword');
        } else {
          ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
            content: Text( AppLocalizations.of(context!)!.appInfoErrorOccured ),                 // 'Something went wrong.'
          ));
        }
      }).catchError((e) {
        var message = jsonDecode(e.message)['message'];
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });

    }
    else {
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text( AppLocalizations.of(context!)!.appInputValidationEmail ),                 // "Please input a valid email."
      ));
    }
  }

  void resetPassword() async {
    FocusScope.of(context!).unfocus();

    if (loginFormKey!.currentState!.validate()) {
      loginFormKey!.currentState!.save();
      Overlay.of(context!)!.insert(loader!);
      repository.resetPassword(code, user.password).then((value) {
        if (value) {
          Navigator.of(scaffoldKey!.currentContext!).pushReplacementNamed(
              '/Home');
        } else {
          ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
            content: Text( AppLocalizations.of(context!)!.appInfoErrorOccured ),                 // 'Something went wrong.'
          ));
        }
      }).catchError((e) {
        var message = jsonDecode(e.message)['message'];
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(message),
        ));
        setState(() => invalidCode = true);
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }
  void signUp() async {
    FocusScope.of(context!).unfocus();

    if (repository.acceptTerms.value != true) {
      setState(() => acceptTermValidate = true);
    }
    if (loginFormKey!.currentState!.validate()) {
      if (repository.acceptTerms.value != true) {
        return;
      }
      loginFormKey!.currentState!.save();
      Overlay.of(context!)!.insert(loader!);
      repository.register(user).then((value) {
        if (value) {
          Navigator.of(scaffoldKey!.currentContext!).pushNamed(
              '/Confirm');
        } else {
          ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
            content: Text( AppLocalizations.of(context!)!.appInfoErrorOccured ),                 // 'Something went wrong.'
          ));
        }
      }).catchError((e) {
        loader!.remove();
        var message = jsonDecode(e.message)['message'];
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  void confirmSignUp() async {
    FocusScope.of(context!).unfocus();
    if (loginFormKey!.currentState!.validate()) {
      loginFormKey!.currentState!.save();
      setState(() => invalidCode = false);
      Overlay.of(context!)!.insert(loader!);
      repository.confirmSignUp(code).then((value) {
        if (value) {
          Navigator.of(scaffoldKey!.currentContext!).pushReplacementNamed(
              '/Home');
        } else {
          ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
            content: Text( AppLocalizations.of(context!)!.appInfoErrorOccured ),                 // 'Something went wrong.'
          ));
        }
      }).catchError((e) {
        var message = jsonDecode(e.message)['message'];
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(message),
        ));
        setState(() => invalidCode = true);
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  void resendConfirmEmail() async {
    FocusScope.of(context!).unfocus();
    Overlay.of(context!)!.insert(loader!);
    repository.resendConfirmEmail().then((value) {
      if (value) {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text( AppLocalizations.of(context!)!.appInputValidationVerificationCodeResend ), // "The confirmation code has been successfully resent via email."
        ));
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text( AppLocalizations.of(context!)!.appInfoErrorOccured ),                 // 'Something went wrong.'
        ));
      }
    }).catchError((e) {
      var message = jsonDecode(e.message)['message'];
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text(message),
      ));
      setState(() => invalidCode = true);
    }).whenComplete(() {
      Helper.hideLoader(loader);
    });
  }
}