import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';

import '../../controllers/user_controller.dart';
import '../../elements/BlockButtonWidget.dart';
import '../../helpers/app_config.dart' as config;
import '../../helpers/helper.dart';
import '../../repository/user_repository.dart' as userRepo;
import 'package:flutter_gen/gen_l10n/s.dart';

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends StateMVC<LoginWidget> {
  late UserController _con;

  final emailFocusNode = FocusNode();
  var passwordFocusNode = FocusNode();

  _LoginWidgetState() : super(UserController(true)) {
    _con = controller as UserController;
  }
  @override
  void initState() {
    super.initState();
    if (userRepo.currentUser.value.auth == true) {
      Navigator.of(context).pushReplacementNamed('/Home', arguments: 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
        key: _con.scaffoldKey,
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Container(
            height: config.App(context).appHeight(100),
            child: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: <Widget>[
                Positioned(
                    top: 0,
                    child: Image.asset(
                      'assets/img/welcome.jpg',
                      width: config.App(context).appHeight(100),
                      height: config.App(context).appHeight(40),
                    )),
                Positioned(
                  top: 0,
                  child: Container(
                    width: config.App(context).appWidth(100),
                    height: config.App(context).appHeight(40),
                    decoration: BoxDecoration(
                        color: Theme.of(context).accentColor,
                        gradient: LinearGradient(
                            begin: FractionalOffset.topCenter,
                            end: FractionalOffset.bottomCenter,
                            colors: [
                              Theme.of(context).accentColor.withOpacity(0.0),
                              Theme.of(context).accentColor,
                            ],
                            stops: [
                              0.0,
                              1.0
                            ])),
                  ),
                ),
                Positioned(
                  bottom: config.App(context).appHeight(40) + 10,
                  child: Container(
                    width: config.App(context).appWidth(84),
                    height: config.App(context).appHeight(40),
                    child: Text(
                      AppLocalizations.of(context)!.appLoginWelcomeText,                        //"Every day is a chance to get better!\nManage your classes as a course instructor!\nGet your classes and see how often you train!",
                      style: Theme.of(context).textTheme.headline6!.merge(
                          TextStyle(color: Theme.of(context).primaryColor)),
                    ),
                  ),
                ),
                Positioned(
                  top: config.App(context).appHeight(40) - 50,
                  child: Container(
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
                        top: 50, right: 27, left: 27, bottom: 20),
                    width: config.App(context).appWidth(88),
                    // height: config.App(context).appHeight(55),
                    child: Form(
                      key: _con.loginFormKey,
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            TextFormField(
                              focusNode: emailFocusNode,
                              keyboardType: TextInputType.emailAddress,
                              onSaved: (input) => _con.user.email = input,
                              validator: (input) =>
                                  EmailValidator.validate(input!)
                                      ? null
                                      : AppLocalizations.of(context)!.appInputValidationEmail,  // "Should be a valid email",
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              autofillHints: <String>[AutofillHints.username],
                              initialValue:
                                  userRepo.currentUser.value.email == null
                                      ? ''
                                      : userRepo.currentUser.value.email,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.appInputEmail,         // "Email",
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
                            SizedBox(height: 30),
                            TextFormField(
                              focusNode: passwordFocusNode,
                              keyboardType: TextInputType.text,
                              onSaved: (input) => _con.user.password = input,
                              validator: (input) => input!.length < 8
                                  ? AppLocalizations.of(context)!.appInputValidationLengthMin + '8'           //"Should be more than 8 characters"
                                  : (RegExp(r'[0-9]').hasMatch(input)
                                      ? null
                                      : AppLocalizations.of(context)!.appInputValidationPasswordNumber ),     // Should include at least one number
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              autofillHints: <String>[AutofillHints.password],
                              obscureText: _con.hidePassword,
                              initialValue:
                                  userRepo.currentUser.value.password == null
                                      ? ''
                                      : userRepo.currentUser.value.password,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.appInputPassword,      // "Password",
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
                                AppLocalizations.of(context)!.appButtonSignIn,                  // "Login",
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                              color: Theme.of(context).accentColor,
                              onPressed: () async {
                                TextInput.finishAutofillContext();
                                await Future.delayed(
                                    Duration(milliseconds: 10));
                                _con.login();
                              },
                            ),
                            SizedBox(height: 15),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 50,
                  left: 20,
                  child: TextButton(
                    onPressed: () {
                      _con.checkEmailToRestPassword();
                    },
                    child: Text( AppLocalizations.of(context)!.appButtonForgetPassword,         // "Forgot password?",
                        style: TextStyle(color: Theme.of(context).hintColor)),
                  ),
                ),
                Positioned(
                  bottom: 50,
                  right: 20,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/SignUp');
                    },
                    child: Text( AppLocalizations.of(context)!.appButtonSignUp,                 // "Sign up",
                        style: TextStyle(color: Theme.of(context).hintColor)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    debugPrint("Form widget disposed");
    super.dispose();
  }
}
