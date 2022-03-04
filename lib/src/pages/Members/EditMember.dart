import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:email_validator/email_validator.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../elements/CustomDatePicker.dart';
import '../../elements/BlockButtonWidget.dart';

import '../../controllers/member_detail_controller.dart';

import '../../repository/user_repository.dart' as user_repo;
import '../../repository/member_repository.dart' as mem_repo;

class EditMemberWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  EditMemberWidget({Key? key, this.parentScaffoldKey}) : super(key: key);
  @override
  _EditMemberWidgetState createState() => _EditMemberWidgetState();
}

class _EditMemberWidgetState extends StateMVC<EditMemberWidget> {
  late MemberDetailController _con;

  String phoneNum = '', phoneCode = '';
  bool isFetching = true;
  bool editted = false;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  _EditMemberWidgetState() : super(MemberDetailController()) {
    _con = controller as MemberDetailController;
  }

  void _onRefresh() async {
    try {
      await fetchMemberDetail();
    } catch (e) {
      print(e.toString());
    }

    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchMemberDetail();
  }

  Future<void> fetchMemberDetail() async {
    await _con.fetchMemberDetail();
    setState(() => isFetching = false);
  }

  Future<void> _showMyDialog(int? memberId) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text( AppLocalizations.of(context)!.appDialogTitleConfirmation ),              // Confirmation
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text( AppLocalizations.of(context)!.memberRemoveMemberConfirmText ),            // Sure to delet this member
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text( AppLocalizations.of(context)!.appButtonYes ),                        // Yes
              onPressed: () {
                Navigator.of(context).pop();
                _con.deleteMember(memberId);
              },
            ),
            TextButton(
              child: Text( AppLocalizations.of(context)!.appButtonCancel ),                      // Cancel
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMember() async {
    _showMyDialog(mem_repo.editId);
  }

  Widget _mainForm() {
    return Form(
      key: _con.memberFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: _con.firstNameController,
            onSaved: (input) => _con.firstNameController.text = input!,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.sentences,
            enabled: !_con.isWpUser!,
            validator: (input) => input!.length < 1
                ? AppLocalizations.of(context)!.appInputMandatoryField                          //'Input your first name'
                : (input.length > 255
                    ? AppLocalizations.of(context)!.appInputValidationLengthMax +' 255'         // 'First name should be less than 255 letters.'
                    : null),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.memberFirstname,                         // First Name
              labelStyle: TextStyle(color: Theme.of(context).accentColor),
              contentPadding: EdgeInsets.all(12),
              hintText: 'John',
              hintStyle: TextStyle(
                  color: Theme.of(context).focusColor.withOpacity(0.7)),
              border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).focusColor.withOpacity(0.2))),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).focusColor.withOpacity(0.5))),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).focusColor.withOpacity(0.2))),
            ),
          ),
          SizedBox(height: 15),
          TextFormField(
            controller: _con.lastNameController,
            onSaved: (input) => _con.lastNameController.text = input!,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.sentences,
            enabled: !_con.isWpUser!,
            validator: (input) => input!.length < 1
                ? AppLocalizations.of(context)!.appInputMandatoryField                          // Input your last name
                : (input.length > 255
                    ? AppLocalizations.of(context)!.appInputValidationLengthMax +' 255'         // 'Last name should be less than 255 letters.'
                    : null),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.memberLastname,                          // Last Name
              labelStyle: TextStyle(color: Theme.of(context).accentColor),
              contentPadding: EdgeInsets.all(12),
              hintText: 'Doe',
              hintStyle: TextStyle(
                  color: Theme.of(context).focusColor.withOpacity(0.7)),
              border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).focusColor.withOpacity(0.2))),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).focusColor.withOpacity(0.5))),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).focusColor.withOpacity(0.2))),
            ),
          ),
          SizedBox(height: 15),
          DropdownButtonFormField(
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.memberGender,                            // Sex
              labelStyle: TextStyle(color: Theme.of(context).accentColor),
              contentPadding: EdgeInsets.all(12),
              hintStyle: TextStyle(
                  color: Theme.of(context).focusColor.withOpacity(0.7)),
              border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).focusColor.withOpacity(0.2))),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).focusColor.withOpacity(0.5))),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).focusColor.withOpacity(0.2))),
            ),
            value: _con.gender != null ? genders[_con.gender!] : 'Unknown',
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            onChanged: (String? newValue) {
              setState(() {
                _con.gender =
                    genders.indexWhere((gender) => gender == newValue);
              });
            },
            items: (_con.isWpUser!
                    ? genders
                        .where((ge) => ge == genders[_con.gender!])
                        .toList()
                    : genders)
                .map((String value) {
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
            label: AppLocalizations.of(context)!.memberBirthday,                                // Birthday
            disabled: _con.isWpUser,
          ),
          SizedBox(height: 15),
          Container(
            key: Key(_con.phoneNumber.isoCode!),
            child: InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) async {
                _con.phone = number.phoneNumber;
              },
              isEnabled: !_con.isWpUser!,
              selectorConfig: SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              ),
              textFieldController: _con.phoneController,
              validator: (input) =>
                  _con.phone!.length > 0 && _con.phone!.length < 10
                      ? AppLocalizations.of(context)!.memberPhoneInvalid                        // 'Phone number should be longer.'
                      : (_con.phone!.length > 14
                          ? AppLocalizations.of(context)!.memberPhoneInvalid                    // 'Phone number should be shorter.'
                          : null),
              ignoreBlank: false,
              autoValidateMode: AutovalidateMode.onUserInteraction,
              initialValue: _con.phoneNumber,
              formatInput: false,
              keyboardType:
                  TextInputType.numberWithOptions(signed: true, decimal: true),
              inputDecoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.memberPhone,                           //"Phone Number",
                labelStyle: TextStyle(color: Theme.of(context).accentColor),
                contentPadding: EdgeInsets.all(12),
                hintText: '79 000 00 00',
                hintStyle: TextStyle(
                    color: Theme.of(context).focusColor.withOpacity(0.7)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).focusColor.withOpacity(0.2))),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).focusColor.withOpacity(0.5))),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).focusColor.withOpacity(0.2))),
              ),
              countries: isoCodes.map((item) => item['locale'] ?? '').toList(),
            ),
          ),
          SizedBox(height: 15),
          TextFormField(
            controller: _con.emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !_con.isWpUser!,
            onSaved: (input) => _con.emailController.text = input!,
            validator: (input) =>
                input!.length == 0 || EmailValidator.validate(input)
                    ? null
                    : AppLocalizations.of(context)!.memberMailInvalid,                          // "Should be a valid email",
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.memberMail,                              // Email
              labelStyle: TextStyle(color: Theme.of(context).accentColor),
              contentPadding: EdgeInsets.all(12),
              hintText: 'john.doe@gmail.com',
              hintStyle: TextStyle(
                  color: Theme.of(context).focusColor.withOpacity(0.7)),
              prefixIcon: Icon(Icons.alternate_email,
                  color: Theme.of(context).accentColor),
              border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).focusColor.withOpacity(0.2))),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).focusColor.withOpacity(0.5))),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).focusColor.withOpacity(0.2))),
            ),
          ),
          SizedBox(height: _con.isWpUser! ? 30 : 15),
          if (_con.isWpUser!)
            Center(
                child: Text(
                  AppLocalizations.of(context)!.memberSelfManagedProfile,                       //'This is a self-managed profile.',
              style: TextStyle(color: Colors.red),
            )),
          if (_con.isWpUser!)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              child: BlockButtonWidget(
                text: Text(
                  AppLocalizations.of(context)!.memberSelfManagedProfileDisconnect,             // "Disconnect Self-managed",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                color: Theme.of(context).accentColor,
                onPressed: () async {
                  await _con.disconnectSelfManaged();
                  editted = true;
                },
              ),
            ),
          if (!_con.isWpUser!)
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              TextButton(
                child: Text(
                  AppLocalizations.of(context)!.appButtonDelete,                                // Delete
                  style: TextStyle(
                      color: Colors.red,
                      decoration: TextDecoration.underline,
                      fontSize: 18),
                ),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed))
                          return Theme.of(context)
                              .primaryColor
                              .withOpacity(0.5);
                        return Theme.of(context).primaryColor;
                      },
                    ),
                    minimumSize:
                        MaterialStateProperty.all<Size>(Size(100, 40))),
                onPressed: () {
                  _deleteMember();
                },
              ),
              TextButton(
                child: Text(
                  AppLocalizations.of(context)!.appButtonSave,                                  // Save
                  style: TextStyle(
                      color: Theme.of(context).primaryColor, fontSize: 18),
                ),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed))
                          return Theme.of(context).accentColor.withOpacity(0.5);
                        return Theme.of(context).accentColor;
                      },
                    ),
                    minimumSize:
                        MaterialStateProperty.all<Size>(Size(100, 40))),
                onPressed: () {
                  TextInput.finishAutofillContext(shouldSave: true);
                  _con.updateMember();
                },
              ),
            ]),
          SizedBox(height: 50),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (editted) {
          Navigator.of(context).pushReplacementNamed("/Members");
        } else {
          Navigator.of(context).pop();
        }
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
            AppLocalizations.of(context)!.memberEditMember,                                     // 'Edit member',
            style: Theme.of(context).textTheme.headline6!.merge(
                  TextStyle(
                    letterSpacing: 1.3,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
          ),
        ),
        body: isFetching
            ? Center(child: CircularProgressIndicator())
            : SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                header: ClassicHeader(),
                controller: _refreshController,
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  child: Container(
                    decoration:
                        BoxDecoration(color: Theme.of(context).primaryColor),
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
                              if (editted) {
                                Navigator.of(context)
                                    .pushReplacementNamed("/Members");
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ),
                        Column(children: [
                          if (_con.isWpUser!) SizedBox(height: 10),
                          if (_con.isWpUser!)
                            CircleAvatar(
                              radius: 82,
                              backgroundColor: Theme.of(context).accentColor,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(155.0),
                                  child: CachedNetworkImage(
                                    width: 158,
                                    height: 158,
                                    fit: BoxFit.cover,
                                    imageUrl: _con.avatarURL!,
                                    httpHeaders: {
                                      'X-WP-Nonce':
                                          user_repo.currentUser.value.nonce!,
                                      'Cookie':
                                          user_repo.currentUser.value.cookie!,
                                    },
                                    progressIndicatorBuilder: (context, url,
                                            downloadProgress) =>
                                        Center(
                                            child: CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress)),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                            child: Icon(Icons.person,
                                                size: 75,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                            color:
                                                Theme.of(context).accentColor),
                                  )),
                            ),
                          SizedBox(height: _con.isWpUser! ? 20 : 50),
                          _mainForm(),
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
