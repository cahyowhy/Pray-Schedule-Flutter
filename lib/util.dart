import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as GPSLocation;
import 'package:google_maps_webservice/geocoding.dart';
import 'package:google_maps_webservice/src/core.dart' as GWCore;
import 'package:http/http.dart' as http;

final String gmapApiKey = "AIzaSyBMkHdPTFNaTuBQeqiIeNk0bCj3W7t-J_Q";
final String rapidApiKey = "758df00852mshb6859b5d6b4c64fp11ef49jsnda6f4556fce7";

class StyleRule {
  static const Color colorPrimary = Color(0XFF9EFF8A);

  static const Color colorPrimaryDark = Color(0XFF68be56);

  static const Color colorPrimaryYoung = Color(0XFFe7ffe1);

  static const Color colorgreyMain = Color(0xfff6f7fa);

  static const Color colorgreyMain10 = Color(0xffe5eced);

  static const Color colorBody = Color(0xfff9f9f9);

  static const Color titleTextColor = Colors.black87;

  static const Color textColor = Colors.black54;

  static const double titleFontSize = 24;

  static const double heavyFontSize = 20;

  static const double midFontSize = 18;

  static const double fontSize = 16;

  static const double iconSize = 18;

  static const double borderRadius = 3;
}

BoxDecoration commonBoxDecoration = BoxDecoration(
  borderRadius: BorderRadius.all(Radius.circular(StyleRule.borderRadius)),
  color: Colors.white,
  border: Border.all(
      color: StyleRule.colorgreyMain10, width: 1.5, style: BorderStyle.solid),
);

String dateFormat(DateTime date, {String f = 'MMMM'}) {
  return new DateFormat(f).format(date);
}

Text renderText(String s,
    {double size = StyleRule.fontSize,
    TextAlign ta = TextAlign.left,
    Color color = StyleRule.textColor,
    FontWeight fw = FontWeight.normal,
    TextOverflow tOv = TextOverflow.clip}) {
  return Text(s,
      style: TextStyle(color: color, fontSize: size, fontWeight: fw),
      overflow: tOv,
      textAlign: ta);
}

Future<GPSLocation.LocationData> getLocation() async {
  GPSLocation.LocationData currentLocation;
  var location = new GPSLocation.Location();

  try {
    currentLocation = await location.getLocation();
  } on PlatformException catch (e) {
    debugPrint(e.toString());

    if (e.code == 'PERMISSION_DENIED') {
      debugPrint("permission denied");
    }

    currentLocation = null;
  }

  return currentLocation;
}

String _extractAddressComponents(List<GWCore.AddressComponent> addresses,
    {bool findOnlyAdministrativeArea = false}) {
  String formatedShortAddress = "";
  String administrativeAddress = "";

  for (int i = addresses.length - 1; i > 0; i--) {
    addresses[i].types.forEach((type) {
      if (type == "country") {
        formatedShortAddress += addresses[i].longName + ", ";
      }

      if (type == "administrative_area_level_1") {
        formatedShortAddress += addresses[i].longName + ", ";
      }

      if (type == "administrative_area_level_2") {
        if (findOnlyAdministrativeArea) {
          administrativeAddress = addresses[i].longName;
        }

        formatedShortAddress += addresses[i].longName + ", ";
      }
    });
  }

  return findOnlyAdministrativeArea
      ? administrativeAddress
      : formatedShortAddress;
}

Future<Map<String, dynamic>> getPlaceByLatLng(double lat, double lng) async {
  GeocodingResponse response;
  final places = new GoogleMapsGeocoding(apiKey: gmapApiKey);
  GWCore.Location location = GWCore.Location(lat, lng);
  Map<String, dynamic> datas = {
    "shortAddress": "Unknown Places",
    "longAddress": "Unknown Places",
    "placeName": "Unknown Places",
    "success": false,
  };

  try {
    response = await places.searchByLocation(location);
    if (response.results.isNotEmpty) {
      var address = response.results?.first?.addressComponents;
      datas["longAddress"] = response.results?.first?.formattedAddress;
      datas["shortAddress"] = _extractAddressComponents(address);
      datas["succes"] = true;
      datas["placeName"] =
          _extractAddressComponents(address, findOnlyAdministrativeArea: true);
    } else {
      debugPrint("notfound");
    }
  } catch (e) {
    debugPrint(e.toString());
  }

  return datas;
}

Future<Map<String, dynamic>> getPrayerTime(String location, String date) async {
  Map<String, dynamic> datas = {
    "latitude": 0.0,
    "longitude": 0.0,
    "items": new Map<String, String>.from({}),
    "address": "Unknown Location",
    "state": "Unknown Location",
    "country": "Unknown Location",
    "qibla_direction": 0.0,
    "success": false
  };

  Map<String, String> headers = {
    "X-RapidAPI-Host": "muslimsalat.p.rapidapi.com",
    "X-RapidAPI-Key": rapidApiKey
  };

  var response = await http.get(
      Uri.parse(
          "https://muslimsalat.p.rapidapi.com/$location/daily/$date/false/5.json"),
      headers: headers);

  debugPrint(response.request.url.toString());

  if (response.statusCode == 200) {
    Map<String, dynamic> responseBody = json.decode(response.body);

    if (responseBody.containsKey("status_code") &&
        responseBody["status_code"] == 1) {
      List items = (responseBody["items"] as List);

      items.forEach((item) {
        Map<String, dynamic> param = (item as Map<String, dynamic>);

        if (param.isNotEmpty) {
          datas["items"] = new Map<String, String>.from({
            "Fajr": param["fajr"],
            "Shurooq": param["shurooq"],
            "Dhuhr": param["dhuhr"],
            "Ashr": param["asr"],
            "Maghrib": param["maghrib"],
            "Isha": param["isha"],
          });

          debugPrint(param.toString());
        }
      });

      datas["success"] = true;
      datas["address"] = responseBody["address"];
      datas["state"] = responseBody["state"];
      datas["latitude"] = double.parse(responseBody["latitude"]);
      datas["longitude"] = double.parse(responseBody["longitude"]);
      datas["country"] = responseBody["country"];
      datas["qibla_direction"] = double.parse(responseBody["qibla_direction"]);
    }
  }

  return datas;
}

Future<Map<String, dynamic>> getPlaceByPlaceId(String placeId) async {
  GeocodingResponse response;
  final places = new GoogleMapsGeocoding(apiKey: gmapApiKey);
  Map<String, dynamic> datas = {
    "shortAddress": "Unknown Places",
    "longAddress": "Unknown Places",
    "latitude": 0.0,
    "longitude": 0.0,
  };

  try {
    response = await places.searchByPlaceId(placeId);
    if (response.results.isNotEmpty) {
      datas["longAddress"] = response.results?.first?.formattedAddress;
      datas["shortAddress"] =
          _extractAddressComponents(response.results?.first?.addressComponents);
      datas["latitude"] = response.results?.first?.geometry?.location?.lat;
      datas["longitude"] = response.results?.first?.geometry?.location?.lng;
    } else {
      debugPrint("notfound");
    }
  } catch (e) {
    debugPrint(e.toString());
  }

  return datas;
}
