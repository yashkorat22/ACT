import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../models/location.dart';

import '../repository/location_repository.dart' as location_repo;
import '../helpers/helper.dart';
import 'package:flutter_gen/gen_l10n/s.dart';

class LocationController extends ControllerMVC {
  GlobalKey<ScaffoldState>? scaffoldKey;
  GlobalKey<FormState>? locationFormKey;
  OverlayEntry? loader;
  BuildContext? context;

  TextEditingController nameController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  LocationController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    locationFormKey = new GlobalKey<FormState>();
  }

  @override
  void initState() {
    super.initState();
    nameController.text = '';
    commentController.text = '';
    context = state!.context;
    loader = Helper.overlayLoader(context);
  }

  Future<void> createLocation(ActLocation location) async {
    FocusScope.of(context!).requestFocus(new FocusNode());
    if (!locationFormKey!.currentState!.validate()) {
      return;
    }
    Overlay.of(context!)!.insert(loader!);
    try {
      final response = await location_repo.createLocation({
        'name': nameController.text,
        'comment': commentController.text,
        'map_service_type': 1,
        'map_service_engine': 1,
        'address': location.address,
        'address_number': location.addressNumber,
        'address_zip': location.addressZip,
        'address_city': location.addressCity,
        'address_country': location.addressCountryValue,
        'map_lat': location.mapLat,
        'map_lon': location.mapLon,
      });
      if (response == 'true') {
        Helper.hideLoader(loader);
        Navigator.of(scaffoldKey!.currentContext!).pop();
      } else {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      }
    } catch (e) {
      print(e);
      var message = jsonDecode((e as dynamic).message)['message'];
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text(message),
      ));
    } finally {
      Helper.hideLoader(loader);
    }
  }

  Future<void> updateLocation(ActLocation location) async {
    FocusScope.of(context!).requestFocus(new FocusNode());
    if (!locationFormKey!.currentState!.validate()) {
      return;
    }
    Overlay.of(context!)!.insert(loader!);
    try {
      final response = await location_repo.updateLocation(location.locationId, {
        'location_id': location.locationId,
        'name': nameController.text,
        'comment': commentController.text,
        'map_service_type': 1,
        'map_service_engine': 1,
        'address': location.address,
        'address_number': location.addressNumber,
        'address_zip': location.addressZip,
        'address_city': location.addressCity,
        'address_country': location.addressCountryValue,
        'map_lat': location.mapLat,
        'map_lon': location.mapLon,
      });
      if (response == 'true') {
        Helper.hideLoader(loader);
        Navigator.of(scaffoldKey!.currentContext!).pop();
      } else {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      }
    } catch (e) {
      print(e);
      var message = jsonDecode((e as dynamic).message)['message'];
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text(message),
      ));
    } finally {
      Helper.hideLoader(loader);
    }
  }

  Future<void> getMyLocations() async {
    try {
      await location_repo.fetchMyLocations();
    } catch(e) {
      print(e);
    }
  }

  Future<bool> deleteLocation(locationId) async {
    Overlay.of(context!)!.insert(loader!);
    bool success = false;
    try {
      final response = await location_repo.deleteLocation(locationId);
      if (response != 'true') {
        final bodyData = jsonDecode(response);
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text(bodyData['message']),
        ));
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
          content: Text( AppLocalizations.of(context!)!.appInfoDeleteSuccessfully ),
        ));
        success = true;
      }
    } catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
        content: Text((e as dynamic).message),
      ));
    } finally {
      Helper.hideLoader(loader);
    }
    return success;
  }
}
