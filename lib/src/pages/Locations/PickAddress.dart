import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';

import '../../controllers/location_controller.dart';

import '../../helpers/app_config.dart' as config;
import '../../helpers/helper.dart';

import '../../models/location.dart';
import '../../models/country.dart';

import '../../repository/user_repository.dart' as user_repo;
import 'package:flutter_gen/gen_l10n/s.dart';

class PickAddressWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;
  final ActLocation location;

  PickAddressWidget({Key? key, this.parentScaffoldKey, required this.location})
      : super(key: key);
  @override
  _PickAddressWidgetState createState() => _PickAddressWidgetState();
}

class _PickAddressWidgetState extends StateMVC<PickAddressWidget> {
  late LocationController _con;
  late TextEditingController streetController;
  late TextEditingController streetNumberController;
  late TextEditingController zipController;
  late TextEditingController cityController;
  GeoPoint? point;
  late List<Country> countries;
  String? country;

  late MapController? _mapCon;

  String phoneNum = '', phoneCode = '';

  _PickAddressWidgetState() : super(LocationController()) {
    _con = controller as LocationController;
  }

  @override
  void initState() {
    // TODO: implement initState
    _mapCon = new MapController(
      initMapWithUserPosition: widget.location.locationId != null,
    );

    streetController = new TextEditingController(text: widget.location.address);
    streetNumberController =
        new TextEditingController(text: widget.location.addressNumber);
    zipController = new TextEditingController(text: widget.location.addressZip);
    cityController =
        new TextEditingController(text: widget.location.addressCity);
    country = widget.location.addressCountryValue;
    if ((widget.location.mapLat ?? 0) != 0 &&
        (widget.location.mapLon ?? 0) != 0) {
      point = GeoPoint(
        latitude: widget.location.mapLat!,
        longitude: widget.location.mapLon!,
      );
    }
    countries = List<Country>.from(user_repo.countries.value);
    if (country == "") {
      if (countries.length > 0) {
        country = countries[0].value;
      }
    }

    if (countries
            .where((c) => c.name?.contains(country ?? '') == true)
            .length ==
        0) {
      countries.add(Country.fromJSON({
        "name": country,
        "value": country,
      }));
    }

    // _mapCon!.listenerMapIsReady.addListener(() async {
    //   debugPrint("map is ready");
    //   if (_mapCon!.listenerMapIsReady.value && point != null) {
    //     await _mapCon!.goToLocation(point!);
    //     await _mapCon!.cancelAdvancedPositionPicker();
    //     await _mapCon!.advancedPositionPicker();
    //   }
    //   Future.delayed(Duration(seconds: 1)).then((value) => pickFromMap());
    // });

    // _mapCon!.listenerMapSingleTapping.addListener(() {
    //   debugPrint(_mapCon!.listenerMapSingleTapping.value.toString());
    // });

    super.initState();
  }

  showOnMap() {
    if (_mapCon == null) return;
    final query = streetController.text +
        " " +
        streetNumberController.text +
        " " +
        cityController.text +
        " " +
        (country ?? "") +
        " " +
        zipController.text;
    locationFromAddress(query).then((List<Location> locations) {
      if (locations.length > 0) {
        point = GeoPoint(
            latitude: locations[0].latitude, longitude: locations[0].longitude);
        debugPrint(point.toString());
        // _mapCon!.goToLocation(point!);
      }
    });
  }

  pickFromMap() async {
    debugPrint('pickFromMap');
    if (_mapCon == null) {
      debugPrint("null");
      return;
    }
    point = await _mapCon!.getCurrentPositionAdvancedPositionPicker();
    List<Placemark> placeMarks =
        await placemarkFromCoordinates(point!.latitude, point!.longitude);
    if (placeMarks.length > 0) {
      debugPrint(placeMarks[0].toString());
      streetController.text = placeMarks[0].thoroughfare ?? '';
      streetNumberController.text = placeMarks[0].subThoroughfare ?? '';
      if (streetController.text.endsWith(streetNumberController.text)) {
        if (streetController.text.length ==
            streetNumberController.text.length) {
          streetNumberController.text = '';
        } else {
          streetController.text = streetController.text.substring(
            0,
            streetController.text.length - streetNumberController.text.length,
          );
        }
      }
      zipController.text = placeMarks[0].postalCode ?? '';
      cityController.text = placeMarks[0].locality ?? '';
      if (cityController.text.length == 0) {
        cityController.text = placeMarks[0].subAdministrativeArea ?? '';
      }
      if (cityController.text.length == 0) {
        cityController.text = placeMarks[0].administrativeArea ?? '';
      }
      setState(() {
        if (countries
                .where((c) =>
                    c.name?.contains(placeMarks[0].country ?? '') == true)
                .length ==
            0) {
          countries.add(Country.fromJSON({
            "name": placeMarks[0].country,
            "value": placeMarks[0].country,
          }));
        }
        country = countries
            .firstWhere(
                (c) => c.name?.contains(placeMarks[0].country ?? '') == true)
            .value;
      });
    }
    await _mapCon!.advancedPositionPicker();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: _con.scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).accentColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),
          title: Text(
            AppLocalizations.of(context)!.locationPickAddress,                                  // "Pick Address",
            style: Theme.of(context).textTheme.headline6!.merge(
                  TextStyle(
                    letterSpacing: 1.3,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
          ),
        ),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              padding: EdgeInsets.only(left: 25, right: 25, top: 15),
              child: Column(
                children: [
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        controller: streetController,
                        onSaved: (input) => streetController.text = input!,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.sentences,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: Helper.of(context).textInputDecoration(
                            AppLocalizations.of(context)!.locationAddressStreetOrPlace, "Aarbergergasse"), // "Street or name of place"
                      ),
                    ),
                    Container(
                      width: 100,
                      padding: EdgeInsets.only(left: 10),
                      child: TextFormField(
                        controller: streetNumberController,
                        onSaved: (input) =>
                            streetNumberController.text = input!,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: Helper.of(context)
                            .textInputDecoration( AppLocalizations.of(context)!.locationAddressStreetNumber, "13"), // "Number"
                      ),
                    ),
                  ]),
                  SizedBox(height: 10),
                  Row(children: [
                    Container(
                      width: 120,
                      padding: EdgeInsets.only(right: 10),
                      child: TextFormField(
                        controller: zipController,
                        onSaved: (input) => zipController.text = input!,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: Helper.of(context)
                            .textInputDecoration( AppLocalizations.of(context)!.locationAddressZIP, "3011"), // "ZIP Code"
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: cityController,
                        onSaved: (input) => cityController.text = input!,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: Helper.of(context)
                            .textInputDecoration( AppLocalizations.of(context)!.locationAddressCity, "Bern"), // "City"
                      ),
                    ),
                  ]),
                  SizedBox(height: 10),
                  DropdownButtonFormField(
                    decoration:
                        Helper.of(context).textInputDecoration( AppLocalizations.of(context)!.locationAddressCountry, ""),  // "Country"
                    value: country,
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    onChanged: (String? newValue) {
                      setState(() {
                        country = newValue;
                      });
                    },
                    items: countries
                        .map<DropdownMenuItem<String>>((Country country) {
                      return DropdownMenuItem<String>(
                        value: country.value,
                        child: Text(country.name!),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        child: Text(
                          AppLocalizations.of(context)!.locationAddressClear,                   // "Clear",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.red,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            streetController.text = "";
                            streetNumberController.text = "";
                            zipController.text = "";
                            cityController.text = "";
                            if (countries.length > 0) {
                              country = countries[0].value;
                            }
                          });
                        },
                      ),
                      TextButton(
                        child: Row(children: [
                          Text( '' ),            // R.of(context).locationAddressShow // "Show"
                          Icon(Icons.arrow_downward),
                        ]),
                        onPressed: () {
                          showOnMap();
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                      ),
                      IconButton(
                        onPressed: () async {
                          if (_mapCon != null) {
                            await _mapCon!.currentLocation();
                            await _mapCon!.advancedPositionPicker();
                            Future.delayed(Duration(seconds: 1))
                                .then((value) => pickFromMap());
                          }
                        },
                        icon: Icon(Icons.my_location),
                        color: Theme.of(context).accentColor,
                      ),
                      TextButton(
                        child: Row(children: [
                          Text( '' ),            // R.of(context).locationAddressPick // "Pick"
                          Icon(Icons.arrow_upward),
                        ]),
                        onPressed: () {
                          pickFromMap();
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                      ),
                      TextButton(
                        child: Text(
                          AppLocalizations.of(context)!.appButtonSave,                          // "Save",
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context).accentColor),
                        onPressed: () {
                          Navigator.pop(
                              context,
                              ActLocation.fromJSON({
                                'location_id': widget.location.locationId,
                                'address': streetController.text,
                                'address_number': streetNumberController.text,
                                'address_zip': zipController.text,
                                'address_city': cityController.text,
                                'address_country_value': country,
                                'map_lat':
                                    point != null ? point!.latitude : null,
                                'map_lon':
                                    point != null ? point!.longitude : null,
                              }));
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
            const Divider(
              height: 20,
              thickness: 3,
            ),
            if (_mapCon != null)
              Expanded(
                // height: config.App(context).appHeight(100) - 500,
                child: OSMFlutter(
                  controller: _mapCon!,
                  trackMyPosition: false,
                  initZoom: 17,
                  minZoomLevel: 2,
                  maxZoomLevel: 19,
                  stepZoom: 1.0,
                  isPicker: true,
                  userLocationMarker: UserLocationMaker(
                    personMarker: MarkerIcon(
                      icon: Icon(
                        Icons.location_history_rounded,
                        color: Colors.red,
                        size: 48,
                      ),
                    ),
                    directionArrowMarker: MarkerIcon(
                      icon: Icon(
                        Icons.double_arrow,
                        size: 48,
                      ),
                    ),
                  ),
                  // road: Road(
                  //   startIcon: MarkerIcon(
                  //     icon: Icon(
                  //       Icons.person,
                  //       size: 64,
                  //       color: Colors.brown,
                  //     ),
                  //   ),
                  //   roadColor: Colors.yellowAccent,
                  // ),
                  roadConfiguration: RoadConfiguration(
                    startIcon: MarkerIcon(
                      icon: Icon(
                        Icons.person,
                        size: 64,
                        color: Colors.brown,
                      ),
                    ),
                    roadColor: Colors.yellowAccent,
                  ),
                  markerOption: MarkerOption(
                      defaultMarker: MarkerIcon(
                    icon: Icon(
                      Icons.person_pin_circle,
                      color: Colors.blue,
                      size: 56,
                    ),
                  )),
                ),
              ),
            Container(
              width: config.App(context).appWidth(100),
              color: Theme.of(context).backgroundColor,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.copyright,
                    size: 17,
                    color: Theme.of(context).primaryColor,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 5),
                    child: InkWell(
                      child: Text(
                        "OpenStreetMap contributors",
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onTap: () async {
                        await launch("https://www.openstreetmap.org/copyright");
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
