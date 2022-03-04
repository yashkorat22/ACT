import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:email_validator/email_validator.dart';

import '../../controllers/user_controller.dart';
import '../../elements/BlockButtonWidget.dart';
import '../../helpers/app_config.dart' as config;
import '../../repository/user_repository.dart' as userRepo;
import 'package:flutter_gen/gen_l10n/s.dart';

class ForgotPasswordWidget extends StatefulWidget {
  @override
  _ForgotPasswordWidgetState createState() => _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends StateMVC<ForgotPasswordWidget> {
  late UserController _con;
  bool? acceptTerms = false;
  String? password;

  _ForgotPasswordWidgetState() : super(UserController(false)) {
    _con = controller as UserController;
  }
  @override
  void initState() {
    super.initState();
    if (userRepo.currentUser.value.auth == true) {
      Navigator.of(context).pushReplacementNamed('/Home', arguments: 2);
    }
    userRepo.acceptTerms.value = false;
    userRepo.acceptTerms.addListener(() {
      setState(() => acceptTerms = userRepo.acceptTerms.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          child: Stack(
            alignment: AlignmentDirectional.topCenter,
            children: <Widget>[
              Positioned(
                top: 0,
                child: Container(
                  width: config.App(context).appWidth(100),
                  height: config.App(context).appHeight(33),
                  decoration:
                      BoxDecoration(color: Theme.of(context).accentColor),
                ),
              ),
              Positioned(
                top: 60,
                child: Container(
                    width: config.App(context).appWidth(84),
                    height: config.App(context).appHeight(33),
                    child: Column(children: <Widget>[
                      Center(
                        child: Text(
                          AppLocalizations.of(context)!.appButtonForgetPassword,                // "Forgot password?",
                          style: Theme.of(context).textTheme.headline2!.merge(
                                TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                        ),
                      ),
                      SizedBox(height: 25),
                      Text(
                        AppLocalizations.of(context)!.appLoginSentVerificationCode,             // "Verification code has been sent to your email.",
                        style: Theme.of(context).textTheme.headline6!.merge(
                              TextStyle(color: Theme.of(context).primaryColor),
                            ),
                      ),
                    ])),
              ),
              Container(
                width: config.App(context).appWidth(100),
                child: Column(children: [
                  SizedBox(height: config.App(context).appHeight(33) - 50),
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 50,
                            color: Theme.of(context).hintColor.withOpacity(0.2),
                          )
                        ]),
                    margin: EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    padding: EdgeInsets.only(
                        top: 40, right: 27, left: 27, bottom: 15),
                    width: config.App(context).appWidth(88),
                    // height: config.App(context).appHeight(55),
                    child: Form(
                      key: _con.loginFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            readOnly: true,
                            initialValue: userRepo.pendingUser.email,
                            validator: (input) =>
                                EmailValidator.validate(input!)
                                    ? null
                                    : AppLocalizations.of(context)!.appLoginValidEmail,         // "Should be a valid email",
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.appInputEmail,           // "Email",
                              labelStyle: TextStyle(
                                  color: Theme.of(context).accentColor),
                              contentPadding: EdgeInsets.all(12),
                              hintText: 'john.doe@gmail.com',
                              hintStyle: TextStyle(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.7)),
                              prefixIcon: Icon(Icons.alternate_email,
                                  color: Theme.of(context).accentColor),
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
                          // SizedBox(height: 20),
                          // Text(
                          //   "Enter your 6 digit verification code received by email.",
                          //   style: TextStyle(
                          //       color: Theme.of(context).accentColor),
                          // ),
                          SizedBox(height: 15),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            onSaved: (input) => _con.code = input,
                            validator: (input) => input!.length < 1
                                ? AppLocalizations.of(context)!.appLoginInputVerificationCode   // "Please input the code"
                                : (_con.invalidCode && input == _con.code
                                    ? AppLocalizations.of(context)!.appInputValidationVerificationCode  // 'Invalid Code'
                                    : null),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            obscureText: _con.hideCode,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.appInputVerificationCode,  // "Code",
                              labelStyle: TextStyle(
                                  color: Theme.of(context).accentColor),
                              contentPadding: EdgeInsets.all(12),
                              hintText: '••••••',
                              hintStyle: TextStyle(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.7)),
                              prefixIcon: Icon(Icons.verified_outlined,
                                  color: Theme.of(context).accentColor),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _con.hideCode = !_con.hideCode;
                                  });
                                },
                                color: Theme.of(context).focusColor,
                                icon: Icon(_con.hideCode
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2),
                                ),
                              ),
                            ),
                          ),
                          // SizedBox(height: 20),
                          // Text(
                          //   "Enter and confirm your new password.",
                          //   style: TextStyle(
                          //       color: Theme.of(context).accentColor),
                          // ),
                          SizedBox(height: 15),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            onChanged: (txt) => password = txt,
                            onSaved: (input) => _con.user.password = input,
                            validator: (input) => input!.length < 8
                                ? AppLocalizations.of(context)!.appInputValidationLengthMin     // "Should be more than 8 characters"
                                : (RegExp(r'[0-9]').hasMatch(input)
                                    ? null
                                    : AppLocalizations.of(context)!.appInputValidationPasswordNumber ), //"Should include at least one number"),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            obscureText: _con.hidePassword,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.appInputPassword,        // "Password",
                              labelStyle: TextStyle(
                                  color: Theme.of(context).accentColor),
                              contentPadding: EdgeInsets.all(12),
                              hintText: '••••••••••••',
                              hintStyle: TextStyle(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.7)),
                              prefixIcon: Icon(Icons.lock_outline,
                                  color: Theme.of(context).accentColor),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _con.hidePassword = !_con.hidePassword;
                                  });
                                },
                                color: Theme.of(context).focusColor,
                                icon: Icon(_con.hidePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            validator: (input) => input == password
                                ? null
                                : AppLocalizations.of(context)!.appInputValidationPasswordMatch,  // 'Password does not match.',
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.appInputConfirmPassword, // "Confirm Password",
                              labelStyle: TextStyle(
                                  color: Theme.of(context).accentColor),
                              contentPadding: EdgeInsets.all(12),
                              hintText: '••••••••••••',
                              hintStyle: TextStyle(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.7)),
                              prefixIcon: Icon(Icons.lock_outline,
                                  color: Theme.of(context).accentColor),
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
                          SizedBox(height: 30),
                          BlockButtonWidget(
                            text: Text(
                              AppLocalizations.of(context)!.appInputResetPassword,              // "Reset Password",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                            color: Theme.of(context).accentColor,
                            onPressed: () {
                              _con.resetPassword();
                            },
                          ),
                          SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text( AppLocalizations.of(context)!.appButtonBackToLogin,            // "Back to Login",
                        style: TextStyle(color: Theme.of(context).hintColor)),
                  ),
                  SizedBox(height: 30),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
