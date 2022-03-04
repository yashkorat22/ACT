import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/services.dart';

import '../../controllers/location_controller.dart';

import '../../models/location.dart';

import '../../elements/BlockButtonWidget.dart';

import '../../helpers/helper.dart';

class CreateLocationWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  CreateLocationWidget({Key? key, this.parentScaffoldKey}) : super(key: key);
  @override
  _CreateLocationWidgetState createState() => _CreateLocationWidgetState();
}

class _CreateLocationWidgetState extends StateMVC<CreateLocationWidget> {
  late LocationController _con;
  late TextEditingController _addressCon;

  ActLocation location = ActLocation.fromJSON({});

  _CreateLocationWidgetState() : super(LocationController()) {
    _con = controller as LocationController;
    _addressCon = new TextEditingController();
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
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back,
                color: Theme.of(context).primaryColor),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            AppLocalizations.of(context)!.locationCreateLocation, // Create location
            style: Theme.of(context).textTheme.headline6!.merge(
                  TextStyle(
                    letterSpacing: 1.3,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          padding: EdgeInsets.only(left: 25, right: 25, top: 15),
          child: Form(
            key: _con.locationFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _con.nameController,
                  onSaved: (input) => _con.nameController.text = input!,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (input) => input!.length < 1
                      ? AppLocalizations
                          .of(context)
                          !.appInputMandatoryField // 'Input the location name'
                      : (input.length > 255
                          ? AppLocalizations.of(context)!.appInputValidationLengthMax +
                              ' 255' // 'Location name should be less than 255 letters.'
                          : (input.length < 3
                              ? AppLocalizations.of(context)!.appInputValidationLengthMin +
                                  ' 3' // 'Location name should be more than 3 letters'
                              : null)),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: Helper.of(context).textInputDecoration(
                      AppLocalizations.of(context)!.locationName, AppLocalizations.of(context)!.locationName),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _con.commentController,
                  onSaved: (input) => _con.commentController.text = input!,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (input) => input!.length < 1
                      ? null
                      : (input.length > 255
                          ? AppLocalizations.of(context)!.appInputValidationLengthMax +
                              ' 255' // 'Description should be less than 255 letters.'
                          : (input.length < 3
                              ? AppLocalizations.of(context)!.appInputValidationLengthMin +
                                  ' 3' //'Description should be more than 3 letters'
                              : null)),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: Helper.of(context).textInputDecoration(
                      AppLocalizations.of(context)!.locationDescription,
                      AppLocalizations.of(context)!.locationDescriptionHint),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _addressCon,
                  onSaved: (input) => _addressCon.text = input ?? '',
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  readOnly: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: Helper.of(context)
                      .textInputDecoration( AppLocalizations.of(context)!.locationPickAddress, AppLocalizations.of(context)!.locationTapToPickAnAddress ), // 'Tap to pick an address' // 'Address'
                  onTap: () {
                    Navigator.pushNamed(context, '/PickAddress',
                            arguments: location)
                        .then((value) {
                          if (value != null ) {
                            location = value as ActLocation;
                            _addressCon.text = location.getAddress();
                          }
                    });
                  },
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  child: BlockButtonWidget(
                    text: Text(
                      AppLocalizations.of(context)!.appButtonCreate,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      TextInput.finishAutofillContext(shouldSave: true);
                      _con.createLocation(location);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
