import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:map_launcher/map_launcher.dart';

import '../../controllers/location_controller.dart';

import '../../elements/MapSheet.dart';

import '../../helpers/app_config.dart' as config;
import '../../helpers/helper.dart';

import '../../models/location.dart';
import 'package:flutter_gen/gen_l10n/s.dart';

class LocationDetailWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;
  final ActLocation location;

  LocationDetailWidget(
      {Key? key, this.parentScaffoldKey, required this.location})
      : super(key: key);

  @override
  _LocationDetailWidgetState createState() => _LocationDetailWidgetState();
}

class _LocationDetailWidgetState extends StateMVC<LocationDetailWidget> {
  late LocationController _con;
  GeoPoint? point;
  late List<AvailableMap> availableMaps;

  MapController? _mapCon;

  String phoneNum = '', phoneCode = '';

  _LocationDetailWidgetState() : super(LocationController()) {
    _con = controller as LocationController;
  }

  @override
  void initState() {
    // TODO: implement initState
    final lat = widget.location.mapLat ?? 0;
    final lon = widget.location.mapLon ?? 0;
    _mapCon = new MapController(
      initMapWithUserPosition: false,
      initPosition: GeoPoint(latitude: lat, longitude: lon),
      areaLimit: BoundingBox(
          east: lon + 0.0001,
          north: lat + 0.0001,
          south: lat - 0.0001,
          west: lon - 0.0001),
    );

    MapLauncher.installedMaps.then((value) => availableMaps = value);

    super.initState();
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
            widget.location.name ?? "Location Detail",
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
                        initialValue: widget.location.address ?? "",
                        readOnly: true,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.sentences,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: Helper.of(context).textInputDecoration(
                            AppLocalizations.of(context)!
                                .locationAddressStreetOrPlace,
                            "Aarbergergasse"), // "Street or name of place"
                      ),
                    ),
                    Container(
                      width: 100,
                      padding: EdgeInsets.only(left: 10),
                      child: TextFormField(
                        initialValue: widget.location.addressNumber ?? "",
                        readOnly: true,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: Helper.of(context).textInputDecoration(
                            AppLocalizations.of(context)!
                                .locationAddressStreetNumber,
                            "13"), // "Number"
                      ),
                    ),
                  ]),
                  SizedBox(height: 10),
                  Row(children: [
                    Container(
                      width: 120,
                      padding: EdgeInsets.only(right: 10),
                      child: TextFormField(
                        initialValue: widget.location.addressZip ?? "",
                        readOnly: true,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: Helper.of(context).textInputDecoration(
                            AppLocalizations.of(context)!.locationAddressZIP,
                            "3011"), // "ZIP Code"
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: widget.location.addressCity ?? "",
                        readOnly: true,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: Helper.of(context).textInputDecoration(
                            AppLocalizations.of(context)!.locationAddressCity,
                            "Bern"), // "City"
                      ),
                    ),
                  ]),
                  SizedBox(height: 10),
                  TextFormField(
                    initialValue: widget.location.addressCountryValue ?? "",
                    readOnly: true,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: Helper.of(context).textInputDecoration(
                        AppLocalizations.of(context)!.locationAddressCountry,
                        ""), // "Country"
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(),
                      /*
                      TextButton(
                        child: Row(children: [
                          Text("Reset"),
                          Icon(Icons.arrow_downward),
                        ]),
                        onPressed: () {
                          final lat = widget.location.mapLat ?? 0;
                          final lon = widget.location.mapLon ?? 0;
                          if (_mapCon != null)
                            _mapCon!.goToLocation(
                                GeoPoint(latitude: lat, longitude: lon));
                        },
                      ),
*/
                      TextButton(
                        child: Text(
                          AppLocalizations.of(context)!
                              .locationAddressStartNavigation,
                          // "Start Navigation",
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context).accentColor),
                        onPressed: () {
                          MapsSheet.show(
                            context: context,
                            onMapTap: (map) {
                              map.showMarker(
                                coords: Coords(widget.location.mapLat ?? 0,
                                    widget.location.mapLon ?? 0),
                                title: widget.location.name ?? "",
                              );
                            },
                          );
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
                  roadConfiguration: RoadConfiguration(
                    startIcon: MarkerIcon(
                      icon: Icon(
                        Icons.person,
                        size: 64,
                        color: Colors.brown,
                      ),
                    ) ,
                    roadColor: Colors.yellowAccent,

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
                  // markerIcon: MarkerIcon(
                  //   icon: Icon(
                  //     Icons.person_pin_circle,
                  //     color: Colors.blue,
                  //     size: 56,
                  //   ),
                  // ),
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
