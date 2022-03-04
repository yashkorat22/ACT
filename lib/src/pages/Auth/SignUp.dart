import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:email_validator/email_validator.dart';

import '../../controllers/user_controller.dart';
import '../../elements/BlockButtonWidget.dart';
import '../../helpers/app_config.dart' as config;
import '../../repository/user_repository.dart' as userRepo;
import 'package:flutter_gen/gen_l10n/s.dart';

class SignUpWidget extends StatefulWidget {
  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends StateMVC<SignUpWidget> {
  late UserController _con;
  bool? acceptTerms = false;
  String? password;

  _SignUpWidgetState() : super(UserController(false)) {
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
    var S = AppLocalizations;
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
                  height: config.App(context).appHeight(30),
                  decoration:
                      BoxDecoration(color: Theme.of(context).accentColor),
                ),
              ),

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
                top: 50,
                child: Container(
                    width: config.App(context).appWidth(84),
                    height: config.App(context).appHeight(30),
                    child: Column(children: <Widget>[
                      Center(
                          child: Text( AppLocalizations.of(context)!.appButtonSignUp,           // "Sign Up",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .merge(TextStyle(
                                      color: Theme.of(context).primaryColor)))),
                      SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context)!.appLoginEnterSignUpInformation,           //"Enter your information and get notified by email",
                        style: Theme.of(context).textTheme.headline6!.merge(
                            TextStyle(color: Theme.of(context).primaryColor)),
                      ),
                    ])),
              ),
              Container(
                width: config.App(context).appWidth(100),
                child: Column(children: [
                  SizedBox(height: config.App(context).appHeight(30) - 50),
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
                        top: 30, right: 27, left: 27, bottom: 15),
                    width: config.App(context).appWidth(88),
                    // height: config.App(context).appHeight(55),
                    child: Form(
                      key: _con.loginFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextFormField(
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.sentences,
                            onSaved: (input) => _con.user.firstName = input,
                            validator: (input) => input!.length < 1
                                ? AppLocalizations.of(context)!.appInputMandatoryField          //'Input your first name'
                                : (input.length > 255
                                    ? 'First name should be less than 255 letters.'
                                    : null),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.appInputFirstname,       // "First Name",
                              labelStyle: TextStyle(
                                  color: Theme.of(context).accentColor),
                              contentPadding: EdgeInsets.all(12),
                              hintText: 'John',
                              hintStyle: TextStyle(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.7)),
                              prefixIcon: Icon(Icons.person_outline,
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
                          SizedBox(height: 10),
                          TextFormField(
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.sentences,
                            onSaved: (input) => _con.user.lastName = input,
                            validator: (input) => input!.length < 1
                                ? AppLocalizations.of(context)!.appInputMandatoryField          // 'Input your last name'
                                : (input.length > 255
                                    ? AppLocalizations.of(context)!.appInputValidationLengthMax +' 255'       //'Last name should be less than 255 letters.'
                                    : null),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.appInputLastname,       // "Last Name",
                              labelStyle: TextStyle(
                                  color: Theme.of(context).accentColor),
                              contentPadding: EdgeInsets.all(12),
                              hintText: 'Doe',
                              hintStyle: TextStyle(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.7)),
                              prefixIcon: Icon(Icons.person_outline,
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
                          SizedBox(height: 10),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            onSaved: (input) => _con.user.email = input,
                            validator: (input) =>
                                EmailValidator.validate(input!)
                                    ? null
                                    : AppLocalizations.of(context)!.appInputMandatoryField,     //"Should be a valid email",
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
                          SizedBox(height: 10),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            onChanged: (txt) => password = txt,
                            onSaved: (input) => _con.user.password = input,
                            validator: (input) => input!.length < 8
                                ? AppLocalizations.of(context)!.appInputValidationLengthMin +' 8'             //"Should be more than 8 characters"
                                : (RegExp(r'[0-9]').hasMatch(input)
                                    ? null
                                    : AppLocalizations.of(context)!.appInputValidationPasswordNumber ),   // "Should include at least one number"),
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
                          SizedBox(height: 10),
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
                          SizedBox(height: 5),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Checkbox(
                                value: acceptTerms,
                                onChanged: (value) {
                                  userRepo.acceptTerms.value = value;
                                },
                                activeColor: Theme.of(context).accentColor,
                                checkColor: Theme.of(context).primaryColor,
                                hoverColor: Theme.of(context).accentColor,
                                focusColor: Theme.of(context).accentColor,
                              ),
                              Expanded(
                                child: Wrap(
                                  runSpacing: -17,
                                  spacing: 5,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      child: Text(
                                        AppLocalizations.of(context)!.appInputAcceptTerms_A,      //"I accept the",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .merge(
                                          TextStyle(
                                            color: Theme.of(context)
                                                .accentColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushNamed('/Terms');
                                      },
                                      style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          ),
                                      child: Text(
                                        AppLocalizations.of(context)!.appInputAcceptTerms_B,      // "usage terms",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .merge(
                                              TextStyle(
                                                  color: Theme.of(context)
                                                      .accentColor,
                                                  decoration:
                                                      TextDecoration.underline),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          acceptTerms != true && _con.acceptTermValidate
                              ? Text(
                            AppLocalizations.of(context)!.appInputAcceptTerms_C,                // '    Please accept the usage terms.',
                                  style: TextStyle(
                                      color: Color(0xFFD74242),
                                      fontWeight: FontWeight.w300),
                                )
                              : SizedBox(
                                  height: 1,
                                ),
                          SizedBox(height: 15),
                          BlockButtonWidget(
                            text: Text(
                              AppLocalizations.of(context)!.appButtonSignUp,                    // "Sign Up",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                            color: Theme.of(context).accentColor,
                            onPressed: () {
                              _con.signUp();
                            },
                          ),
                          SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/Login');
                    },
                    child: Text( AppLocalizations.of(context)!.appLoginAlreadyAccount,                        // "I have an account? Back to Login",
                        style: TextStyle(color: Theme.of(context).hintColor, decoration: TextDecoration.underline)),
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
