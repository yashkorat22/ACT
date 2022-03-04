import 'dart:math';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../elements/BlockButtonWidget.dart';
import '../../elements/CustomDatePicker.dart';

import '../../models/template.dart';

import '../../controllers/subscription_controller.dart';

import '../../repository/user_repository.dart' as user_repo;
import 'package:flutter_gen/gen_l10n/s.dart';

class CreateSingleSubscriptionWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;
  final memberId;

  CreateSingleSubscriptionWidget(
      {Key? key, this.parentScaffoldKey, this.memberId})
      : super(key: key);
  @override
  _CreateSingleSubscriptionWidgetState createState() =>
      _CreateSingleSubscriptionWidgetState();
}

class _CreateSingleSubscriptionWidgetState
    extends StateMVC<CreateSingleSubscriptionWidget> {
  late SubscriptionController _con;

  List<Template> templates = [];

  _CreateSingleSubscriptionWidgetState() : super(SubscriptionController()) {
    _con = controller as SubscriptionController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    templates = user_repo.templates.value;
    user_repo.templates.addListener(() {
      setState(() {
        templates = user_repo.templates.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        key: _con.scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/Home');
                },
                icon: Icon(
                  Icons.home,
                  size: 26.0,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back,
                color: Theme.of(context).primaryColor),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).accentColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.subscriptionCreateTitle,                              // Create subscription
            style: Theme.of(context).textTheme.headline6!.merge(
                  TextStyle(
                    letterSpacing: 1.3,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            padding: EdgeInsets.only(left: 25, right: 25, top: 50),
            child: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: <Widget>[
                Column(children: [
                  Form(
                    key: _con.subscriptionFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.subscriptionTemplate,  // Subscription Template
                            labelStyle:
                                TextStyle(color: Theme.of(context).accentColor),
                            contentPadding: EdgeInsets.all(12),
                            hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .focusColor
                                    .withOpacity(0.7)),
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
                          value: _con.templateId != null &&
                                  templates.length > _con.templateId!
                              ? templates[_con.templateId!].name
                              : null,
                          onTap: () {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                          },
                          onChanged: (String? newValue) {
                            final newIndex = templates.indexWhere(
                                (template) => template.name == newValue);
                            final startDate = DateTime.parse(_con.startDate);
                            DateTime endDate = DateTime.parse(_con.endDate);
                            switch (templates[newIndex].unit) {
                              case "Year":
                                endDate = new DateTime(
                                    startDate.year +
                                        templates[newIndex].unitAmount!,
                                    startDate.month,
                                    startDate.day);
                                break;
                              case "Month":
                                endDate = new DateTime(
                                    startDate.year,
                                    startDate.month +
                                        templates[newIndex].unitAmount!,
                                    startDate.day);
                                break;
                              case "Week":
                                endDate = new DateTime(
                                    startDate.year,
                                    startDate.month,
                                    startDate.day +
                                        7 * templates[newIndex].unitAmount!);
                                break;
                              case "Day":
                                endDate = new DateTime(
                                    startDate.year,
                                    startDate.month,
                                    startDate.day +
                                        templates[newIndex].unitAmount!);
                                break;
                            }
                            final DateFormat dateFormatter =
                                DateFormat('yyyy-MM-dd');
                            setState(() {
                              _con.templateId = newIndex;
                              _con.endDate =
                                  dateFormatter.format(endDate);
                              _con.maxCount = templates[newIndex].maxCount;
                            });
                          },
                          items: templates.map<DropdownMenuItem<String>>(
                              (Template template) {
                            return DropdownMenuItem<String>(
                              value: template.name,
                              child: Text(template.name!),
                            );
                          }).toList(),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: const Divider(
                            height: 20,
                            thickness: 5,
                          ),
                        ),
                        GridView.count(
                          primary: false,
                          padding: const EdgeInsets.only(top: 5),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          childAspectRatio: 3,
                          children: <Widget>[
                            CustomDatePicker(
                              value: _con.startDate,
                              onChange: (value) {
                                setState(() {
                                  _con.startDate = value;
                                });
                              },
                              label: AppLocalizations.of(context)!.subscriptionStartDate, // Start Date
                            ),
                            Text(''),
                            CustomDatePicker(
                              value: _con.endDate,
                              onChange: (value) {
                                setState(() {
                                  _con.endDate = value;
                                });
                              },
                              label: AppLocalizations.of(context)!.subscriptionEndDate,   // End Date
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton(
                                  child: Text(
                                    AppLocalizations.of(context)!.subscriptionPlusOneWeek, // + 1 week
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  onPressed: () {
                                    final endDate =
                                        DateTime.parse(_con.endDate);
                                    final newEndDate = new DateTime(
                                        endDate.year,
                                        endDate.month,
                                        endDate.day + 7);
                                    final DateFormat dateFormatter =
                                        DateFormat('yyyy-MM-dd');
                                    _con.endDate =
                                        dateFormatter.format(newEndDate);
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Theme.of(context).accentColor),
                                  ),
                                ),
                                SizedBox(width: 10),
                                TextButton(
                                  child: Text(
                                    AppLocalizations.of(context)!.subscriptionPlusOneMonth, // + 1 month
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  onPressed: () {
                                    final endDate =
                                        DateTime.parse(_con.endDate);
                                    final newEndDate = new DateTime(
                                        endDate.year,
                                        endDate.month + 1,
                                        endDate.day);
                                    final DateFormat dateFormatter =
                                        DateFormat('yyyy-MM-dd');
                                    _con.endDate =
                                        dateFormatter.format(newEndDate);
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Theme.of(context).accentColor),
                                  ),
                                ),
                              ],
                            ),
                            DropdownButtonFormField(
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.subscriptionBookingAmount, // Booking Amount
                                labelStyle: TextStyle(
                                    color: Theme.of(context).accentColor),
                                contentPadding: EdgeInsets.all(12),
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.7)),
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
                              value: _con.maxCount,
                              onTap: () {
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                              },
                              onChanged: (int? newValue) {
                                setState(() => _con.maxCount = newValue);
                              },
                              items: List<DropdownMenuItem<int>>.generate(361,
                                  (i) {
                                return DropdownMenuItem<int>(
                                  value: i,
                                  child: Text(i.toString()),
                                );
                              }).toList(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton(
                                  child: Text(
                                    '+1',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  onPressed: () {
                                    setState(() => _con.maxCount =
                                        min(_con.maxCount! + 1, 360));
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Theme.of(context).accentColor),
                                  ),
                                ),
                                SizedBox(width: 10),
                                TextButton(
                                  child: Text(
                                    '+5',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  onPressed: () {
                                    setState(() => _con.maxCount =
                                        min(_con.maxCount! + 5, 360));
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Theme.of(context).accentColor),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: const Divider(
                            height: 20,
                            thickness: 5,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.subscriptionAddShoppingCart,      // Add to shopping cart
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ToggleButtons(
                          children: [
                            Icon(Icons.remove_shopping_cart),
                            Icon(Icons.add_shopping_cart),
                          ],
                          onPressed: (int index) {
                            setState(() {
                              _con.addToShoppingCart = (index == 1);
                            });
                          },
                          isSelected: [
                            !_con.addToShoppingCart,
                            _con.addToShoppingCart
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: const Divider(
                            height: 20,
                            thickness: 5,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          child: BlockButtonWidget(
                            text: Text(
                              AppLocalizations.of(context)!.appButtonCreate,                      // Create
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                            color: Theme.of(context).accentColor,
                            onPressed: () {
                              _con.createSubscription(widget.memberId);
                            },
                          ),
                        ),
                        SizedBox(height: 50),
                      ],
                    ),
                  ),
                ])
              ],
            ),
          ),
        ),
      ),
    );
  }
}
