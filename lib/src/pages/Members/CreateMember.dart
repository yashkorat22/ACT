import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:email_validator/email_validator.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:flutter/services.dart';

import '../../controllers/member_detail_controller.dart';

import '../../elements/BlockButtonWidget.dart';
import '../../elements/CustomDatePicker.dart';

class CreateMemberWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  CreateMemberWidget({Key? key, this.parentScaffoldKey}) : super(key: key);
  @override
  _CreateMemberWidgetState createState() => _CreateMemberWidgetState();
}

class _CreateMemberWidgetState extends StateMVC<CreateMemberWidget> {
  late MemberDetailController _con;

  String phoneNum = '', phoneCode = '';

  _CreateMemberWidgetState() : super(MemberDetailController()) {
    _con = controller as MemberDetailController;
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
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).accentColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            AppLocalizations.of(context)!.memberCreateMember,                                   // Create member
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
            padding: EdgeInsets.only(left: 25, right: 25, top: 15),
            child: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: <Widget>[
                Positioned(
                  top: -5,
                  left: -15,
                  child: IconButton(
                    icon: new Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Column(children: [
                  SizedBox(height: 50),
                  Form(
                    key: _con.memberFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _con.firstNameController,
                          onSaved: (input) =>
                              _con.firstNameController.text = input!,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.sentences,
                          validator: (input) => input!.length < 1
                              ? AppLocalizations.of(context)!.appInputMandatoryField
                              : (input.length > 255
                                  ? AppLocalizations.of(context)!.appInputValidationLengthMax +' 255' //'First name should be less than 255 letters.'
                                  : null),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.memberFirstname,           // Firstname
                            labelStyle:
                                TextStyle(color: Theme.of(context).accentColor),
                            contentPadding: EdgeInsets.all(12),
                            hintText: 'John',
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
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _con.lastNameController,
                          onSaved: (input) =>
                              _con.lastNameController.text = input!,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.sentences,
                          validator: (input) => input!.length < 1
                              ? AppLocalizations.of(context)!.appInputMandatoryField
                              : (input.length > 255
                                  ? AppLocalizations.of(context)!.appInputValidationLengthMax +' 255'     // 'Last name should be less than 255 letters.'
                                  : null),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.memberLastname,          // Last Name
                            labelStyle:
                                TextStyle(color: Theme.of(context).accentColor),
                            contentPadding: EdgeInsets.all(12),
                            hintText: 'Doe',
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
                        ),
                        SizedBox(height: 15),
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.memberGender,              // Sex
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
                          value: _con.gender != null
                              ? genders[_con.gender!]
                              : 'Unknown',
                          onTap: () {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                          },
                          onChanged: (String? newValue) {
                            setState(() {
                              _con.gender = genders
                                  .indexWhere((gender) => gender == newValue);
                            });
                          },
                          items: genders
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 15),
                        CustomDatePicker(
                          value: _con.birthday,
                          onChange: (value) {
                            setState(() {
                              _con.birthday = value;
                            });
                          },
                          label: AppLocalizations.of(context)!.memberBirthday,                  // Birthday
                        ),
                        SizedBox(height: 15),
                        Container(
                          key: Key(_con.phoneNumber.isoCode ?? '1'),
                          child: InternationalPhoneNumberInput(
                            onInputChanged: (PhoneNumber number) async {
                              _con.phone = number.phoneNumber;
                            },
                            selectorConfig: SelectorConfig(
                              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                            ),
                            textFieldController: _con.phoneController,
                            validator: (input) => _con.phone!.length > 0 &&
                                    _con.phone!.length < 10
                                ? AppLocalizations.of(context)!.memberPhoneInvalid              // 'Phone number should be longer.'
                                : (_con.phone!.length > 14
                                    ? AppLocalizations.of(context)!.memberPhoneInvalid          // 'Phone number should be shorter.'
                                    : null),
                            ignoreBlank: false,
                            autoValidateMode:
                                AutovalidateMode.onUserInteraction,
                            initialValue: _con.phoneNumber,
                            formatInput: false,
                            keyboardType: TextInputType.numberWithOptions(
                                signed: true, decimal: true),
                            inputDecoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.memberPhone,             // Phone number
                              labelStyle: TextStyle(
                                  color: Theme.of(context).accentColor),
                              contentPadding: EdgeInsets.all(12),
                              hintText: '79 000 00 00',
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
                            countries: isoCodes
                                .map((item) => item['locale'] ?? '')
                                .toList(),
                          ),
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _con.emailController,
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (input) =>
                              _con.emailController.text = input!,
                          validator: (input) => input!.length == 0 ||
                                  EmailValidator.validate(input)
                              ? null
                              : AppLocalizations.of(context)!.memberMailInvalid,                //"Should be a valid email"
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          autofillHints: <String>[AutofillHints.username],
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.memberMail,                // e-Mail
                            labelStyle:
                                TextStyle(color: Theme.of(context).accentColor),
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
                        SizedBox(height: 15),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          child: BlockButtonWidget(
                            text: Text(
                              AppLocalizations.of(context)!.appButtonCreate,                       // Create
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                            color: Theme.of(context).accentColor,
                            onPressed: () {
                              TextInput.finishAutofillContext(shouldSave: true);
                              _con.createMember();
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
