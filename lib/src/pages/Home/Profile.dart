import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:flutter/services.dart';

import '../../controllers/profile_controller.dart';

import '../../repository/settings_repository.dart';

import '../../elements/BlockButtonWidget.dart';
import '../../elements/CustomDatePicker.dart';

class ProfileWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  ProfileWidget({Key? key, this.parentScaffoldKey}) : super(key: key);
  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends StateMVC<ProfileWidget> {
  late ProfileController _con;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String phonenum = '', phonecode = '';

  _ProfileWidgetState() : super(ProfileController()) {
    _con = controller as ProfileController;
  }

  void _onRefresh() async {
    // monitor network fetch
    await _con.getProfile();
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  Future<void> _showMyDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.appDialogTitleConfirmation),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations.of(context)!.homeProfilePictureRemoveText),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.appButtonYes), // = Yes
              onPressed: () {
                Navigator.of(context).pop();
                _con.removeAvatar();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.appButtonNo), // = No
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> uploadAvatar() async {
    switch (await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Camera');
              },
              child: Text(
                AppLocalizations.of(context)!.appSelectCamera, // = Get Selfie
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Gallery');
              },
              child:
                  Text(AppLocalizations.of(context)!.appSelectGallery, // = Picture from gallery
                      style: Theme.of(context).textTheme.headline4),
            ),
          ],
        );
      },
    )) {
      case 'Camera':
        _con.getImage(ImageSource.camera);
        break;
      case 'Gallery':
        _con.getImage(ImageSource.gallery);
        break;
    }
  }

  Future<void> deleteAvatar() async {
    _showMyDialog();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacementNamed('/Home');
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
            setting.value.appName!,
            style: Theme.of(context).textTheme.headline6!.merge(
                  TextStyle(
                    letterSpacing: 1.3,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
          ),
        ),
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: ClassicHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              padding: EdgeInsets.only(left: 15, right: 15, top: 15),
              child: Stack(
                alignment: AlignmentDirectional.topCenter,
                children: <Widget>[
                  Positioned(
                    top: -5,
                    left: 0,
                    child: IconButton(
                      icon: new Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/Home');
                      },
                    ),
                  ),
                  Column(children: [
                    Text(
                      AppLocalizations.of(context)!.homeProfileTitle, // = Profile
                      style: Theme.of(context).textTheme.headline1,
                    ),
                    SizedBox(height: 10),
                    Stack(children: <Widget>[
                      CircleAvatar(
                        radius: 82,
                        backgroundColor: Theme.of(context).accentColor,
                        child: _con.imageFile == null
                            ? CircleAvatar(
                                child: Icon(Icons.person,
                                    size: 120,
                                    color: Theme.of(context).accentColor),
                                radius: 79,
                                backgroundColor: Theme.of(context).primaryColor,
                              )
                            : CircleAvatar(
                                backgroundImage: MemoryImage(_con.imageFile!),
                                radius: 79,
                              ),
                      ),
                      Positioned(
                        top: 120,
                        right: 5,
                        child: InkWell(
                          splashColor: Theme.of(context).hoverColor,
                          onTap: () => uploadAvatar(),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Theme.of(context).hoverColor,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Icon(
                                Icons.add_a_photo,
                                color: Theme.of(context).accentColor,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_con.imageFile != null)
                        Positioned(
                          top: 120,
                          left: 5,
                          child: InkWell(
                            splashColor: Theme.of(context).hoverColor,
                            onTap: () => deleteAvatar(),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Theme.of(context).hoverColor,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.red,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ]),
                    SizedBox(height: 20),
                    Form(
                      key: _con.profileFormKey,
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
                                ? 'Input your first name'
                                : (input.length > 255
                                    ? 'First name should be less than 255 letters.'
                                    : null),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.homeProfileFirstname,
                              labelStyle: TextStyle(
                                  color: Theme.of(context).accentColor),
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
                                ? 'Input your last name'
                                : (input.length > 255
                                    ? 'Last name should be less than 255 letters.'
                                    : null),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.homeProfileLastname,
                              labelStyle: TextStyle(
                                  color: Theme.of(context).accentColor),
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
                              labelText: AppLocalizations.of(context)!.homeProfileGender,
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
                              label: AppLocalizations.of(context)!.homeProfileBirthday),
                          SizedBox(height: 15),
                          Container(
                            key: Key(_con.phoneNumber.isoCode!),
                            child: InternationalPhoneNumberInput(
                              onInputChanged: (PhoneNumber number) async {
                                debugPrint(number.phoneNumber);
                                _con.phone = number.phoneNumber;
                              },
                              selectorConfig: SelectorConfig(
                                selectorType:
                                    PhoneInputSelectorType.BOTTOM_SHEET,
                              ),
                              textFieldController: _con.phoneController,
                              validator: (input) => null,
                              ignoreBlank: false,
                              autoValidateMode: AutovalidateMode.disabled,
                              // selectorTextStyle: TextStyle(color: Colors.black),
                              initialValue: _con.phoneNumber,
                              formatInput: false,
                              keyboardType: TextInputType.numberWithOptions(
                                  signed: true, decimal: true),
                              inputDecoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.homeProfilePhone,
                                labelStyle: TextStyle(
                                    color: Theme.of(context).accentColor),
                                contentPadding: EdgeInsets.all(12),
                                hintText: '(123) 456 7890',
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
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 10),
                            child: BlockButtonWidget(
                              text: Text(
                                AppLocalizations.of(context)!.appButtonSave,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                              color: Theme.of(context).accentColor,
                              onPressed: () {
                                TextInput.finishAutofillContext(
                                    shouldSave: true);
                                _con.saveProfile();
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
      ),
    );
  }
}
