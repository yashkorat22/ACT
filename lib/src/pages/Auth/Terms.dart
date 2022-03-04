import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../elements/BlockButtonWidget.dart';
import '../../helpers/app_config.dart' as config;
import '../../repository/user_repository.dart' as userRepo;
import '../../helpers/custom_trace.dart';
import '../../helpers/helper.dart';

class TermsWidget extends StatefulWidget {
  @override
  _TermsWidgetState createState() => _TermsWidgetState();
}

class _TermsWidgetState extends StateMVC<TermsWidget> {
  bool? acceptTerms = userRepo.acceptTerms.value;
  String? password;
  String? htmlData;

  _TermsWidgetState() : super();

  @override
  void initState() {
    super.initState();
    if (userRepo.currentUser.value.auth == true) {
      Navigator.of(context).pushReplacementNamed('/Home', arguments: 2);
    }
    userRepo.acceptTerms.addListener(() {
      setState(() => acceptTerms = userRepo.acceptTerms.value);
    });
    rootBundle.loadString(Helper.termsAndConditionsUrl()).then((value) {
      setState(() => htmlData = value);
    });
  }

  Future<bool> onWillPop() {
    Navigator.of(context).pop();
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back,
                color: Theme.of(context).primaryColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).accentColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.appTermsAndConditions,                                // "User Agreement",
            style: Theme.of(context).textTheme.headline6!.merge(TextStyle(
                letterSpacing: 1.3, color: Theme.of(context).primaryColor)),
          ),
        ),
        body: Container(
          padding: EdgeInsets.only(top: 30, right: 27, left: 27, bottom: 0),
          height: config.App(context).appHeight(100),
          child: Stack(
            children: [
              if (htmlData != null)
              Container(
                height: config.App(context).appHeight(100) - 280,
                child: SingleChildScrollView(
                  child: Html(
                    data: htmlData,
                    onLinkTap: (url, context, attributes, element) async {
                      try{
                        await launch(
                          url!,
                          forceSafariVC: false,
                          forceWebView: false,
                        );
                      } catch(e) {
                        debugPrint(CustomTrace(StackTrace.current, message: (e as dynamic).message).toString());
                      }
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                child: Container(
                  width: config.App(context).appWidth(100) - 54,
                  child: Column(children: <Widget>[
                    Row(
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
                        Text( AppLocalizations.of(context)!.appInputAcceptTerms_D,              // "I accept the usage terms",
                            style: Theme.of(context).textTheme.headline6!.merge(
                                TextStyle(
                                    color: Theme.of(context).accentColor))),
                      ],
                    ),
                    SizedBox(height: 10),
                    BlockButtonWidget(
                      text: Text(
                        AppLocalizations.of(context)!.appButtonBack,                            // "Back",
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      color: Theme.of(context).accentColor,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
