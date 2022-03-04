import '../helpers/custom_trace.dart';
import 'package:flutter/foundation.dart';

class ActLocation {
  int? locationId;
  String? name;
  String? comment;
  int? mapServiceType;
  int? mapServiceEngine;
  String? address;
  String? addressNumber;
  String? addressZip;
  String? addressCity;
  String? addressCountryValue;
  double? mapLat;
  double? mapLon;
  int? locationPermission;
  String? ownerFullName;

  ActLocation();

  ActLocation.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      locationId = jsonMap['location_id'] ?? 0;
      name = jsonMap['name'] ?? '';
      comment = jsonMap['comment'] ?? '';
      mapServiceType = jsonMap['map_service_type'] ?? 0;
      mapServiceEngine = jsonMap['map_service_engine'] ?? 0;
      address = jsonMap['address'] ?? '';
      addressNumber = jsonMap['address_number'] ?? '';
      addressZip = jsonMap['address_zip'] ?? '';
      addressCity = jsonMap['address_city'] ?? '';
      addressCountryValue = jsonMap['address_country_value'] ?? '';
      mapLat = (jsonMap['map_lat'] ?? 0.0).toDouble();
      mapLon = (jsonMap['map_lon'] ?? 0.0).toDouble();
      locationPermission = jsonMap['location_permission'] ?? 0;
      ownerFullName = jsonMap['owner_full_name'] ?? '';
    } catch (e) {
      debugPrint(CustomTrace(StackTrace.current, message: e.toString()).toString());
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['location_id'] = locationId;
    map['name'] = name;
    map['comment'] = comment;
    map['map_service_type'] = mapServiceType;
    map['map_service_engine'] = mapServiceEngine;
    map['address'] = address;
    map['address_number'] = addressNumber;
    map['address_zip'] = addressZip;
    map['address_city'] = addressCity;
    map['address_country_value'] = addressCountryValue;
    map['map_lat'] = mapLat;
    map['map_lon'] = mapLon;
    map['location_permission'] = locationPermission;
    map['owner_full_name'] = ownerFullName;
    return map;
  }

  String getAddress() {
    String result = '';
    if (address != null && address!.length != 0) {
      result = address!;
    }
    if (addressNumber != null && addressNumber!.length != 0) {
      if (result.length != 0) {
        result += " ";
      }
      result += addressNumber!;
    }
    if (addressZip != null && addressZip!.length != 0) {
      if (result.length != 0) {
        result += " ";
      }
      result += addressZip!;
    }
    if (addressCity != null && addressCity!.length != 0) {
      if (result.length != 0) {
        result += " ";
      }
      result += addressCity!;
    }
    if (addressCountryValue != null && addressCountryValue!.length != 0) {
      if (result.length != 0) {
        result += " ";
      }
      result += addressCountryValue!;
    }
    return result;
  }
  
  @override
  String toString() {
    var map = this.toMap();
    return map.toString();
  }
}
