import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../controllers/user_controller.dart';
import '../../elements/BlockButtonWidget.dart';
import '../../helpers/app_config.dart' as config;
import '../../repository/user_repository.dart' as userRepo;

class ConfirmWidget extends StatefulWidget {
  @override
  _ConfirmWidgetState createState() => _ConfirmWidgetState();
}

class _ConfirmWidgetState extends StateMVC<ConfirmWidget> {
  late UserController _con;

  _ConfirmWidgetState() : super(UserController(false)) {
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
    return Scaffold(
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
                child: Container(
                  width: config.App(context).appWidth(100),
                  height: config.App(context).appHeight(40),
                  decoration:
                      BoxDecoration(color: Theme.of(context).accentColor),
                ),
              ),
              Positioned(
                top: 50,
                child: Container(
                    width: config.App(context).appWidth(84),
                    height: config.App(context).appHeight(30),
                    child: Column(children: <Widget>[
                      Row(children: <Widget>[
                        Container(
                          width: config.App(context).appWidth(12),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back),
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        Container(
                          width: config.App(context).appWidth(60),
                          child: Center(
                            child: Text(
                              "Confirm",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .merge(
                                    TextStyle(
                                        color: Theme.of(context).primaryColor),
                                  ),
                            ),
                          ),
                        ),
                      ]),
                      SizedBox(height: 20),
                      Text(
                        "You will receive a verification code via email.",
                        style: Theme.of(context).textTheme.headline6!.merge(
                            TextStyle(color: Theme.of(context).primaryColor)),
                      ),
                    ])),
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
                  padding:
                      EdgeInsets.only(top: 50, right: 27, left: 27, bottom: 20),
                  width: config.App(context).appWidth(88),
                  // height: config.App(context).appHeight(55),
                  child: Form(
                    key: _con.loginFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextFormField(
                          keyboardType: TextInputType.text,
                          onSaved: (input) => _con.code = input,
                          validator: (input) => input!.length < 1
                              ? "Please input the code"
                              : (_con.invalidCode && input == _con.code
                                  ? 'Invalid Code'
                                  : null),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          obscureText: _con.hidePassword,
                          decoration: InputDecoration(
                            labelText: "Code",
                            labelStyle:
                                TextStyle(color: Theme.of(context).accentColor),
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
                        SizedBox(height: 30),
                        BlockButtonWidget(
                          text: Text(
                            "Confirm",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                          color: Theme.of(context).accentColor,
                          onPressed: () {
                            _con.confirmSignUp();
                          },
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 50,
                child: TextButton(
                  onPressed: () {
                    _con.resendConfirmEmail();
                  },
                  child: Text("Resend Code",
                      style: TextStyle(color: Theme.of(context).hintColor)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
