import 'package:coba_flutter/component/BoxInfo.dart';
import 'package:coba_flutter/component/DatePicker.dart';
import 'package:coba_flutter/component/TabWrapper.dart';
import 'package:coba_flutter/component/TopBar.dart';
import 'package:coba_flutter/screen/NearByMosqueScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';

import 'package:coba_flutter/screen/QiblaCompasScreen.dart';
import 'package:coba_flutter/screen/PrayyerScreen.dart';

import './util.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Prayer time',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(),
    );
  }
}

final homeScaffoldKey = GlobalKey<ScaffoldState>();
final searchScaffoldKey = GlobalKey<ScaffoldState>();

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _currentDate = DateTime.now();
  Map<String, String> _prays = {};
  String _placeLong = "Unknown Location";
  String _placeShort = "Unknown Location";
  String _searchLocation = "";
  bool _loading = false;
  double _lat = 0.0;
  double _lng = 0.0;
  double _qibla = 0.0;
  PlacesSearchResponse _placesSearchResponse;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then((value) {
      _getLocationAndPlaces();
    });
  }

  _getLocationAndPlaces() {
    if (!_loading) {
      setState(() {
        _loading = true;
      });

      getLocation().then((LocationData locationData) {
        double latitude = locationData.latitude;
        double longitude = locationData.longitude;

        Future.wait([
          getPlaceByLatLng(latitude, longitude),
          getNearByMosqueLatLng(latitude, longitude)
        ]).then((List<dynamic> responses) {
          Map<String, dynamic> data = (responses[0] as Map<String, dynamic>);
          PlacesSearchResponse placesSearchResponse =
              (responses[1] as PlacesSearchResponse);

          setState(() {
            _lat = latitude;
            _lng = longitude;
            _placesSearchResponse = placesSearchResponse;
          });

          if (data["succes"]) {
            _findPrayAndQibla(data["placeName"], skipLatLng: true);
          }
        });
      });
    }
  }

  Future<void> _findPrayAndQibla(String location,
      {bool skipLatLng = false}) async {
    Map<String, dynamic> data = await getPrayerTime(
        location, dateFormat(_currentDate, f: "dd-MM-yyyy"));
    _searchLocation = location;

    if (data["success"]) {
      setState(() {
        if (!skipLatLng) {
          _lat = data["latitude"];
          _lng = data["longitude"];
        }

        _placeShort = data["country"];
        _placeLong = data["address"];
        _qibla = data["qibla_direction"];
        _prays = data["items"];
        _loading = false;
      });
    }
  }

  void onError(PlacesAutocompleteResponse response) {
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  void _onChangeDay(day) {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month, day);
      _findPrayAndQibla(_searchLocation);
    });
  }

  void _onChangeMonth(month) {
    setState(() {
      _currentDate = DateTime(_currentDate.year, month, _currentDate.day);
      _findPrayAndQibla(_searchLocation);
    });
  }

  void _handlePressButton() {
    PlacesAutocomplete.show(
      context: context,
      apiKey: gmapApiKey,
      onError: onError,
      mode: Mode.fullscreen,
      types: ["geocode"],
      language: "en",
    ).then((p) {
      _findPrayAndQibla(p.terms?.first?.value).then((response) {
        getNearByMosqueLatLng(_lat, _lng).then((PlacesSearchResponse pl) {
          setState(() {
            _placesSearchResponse = pl;
          });
        });
      });
    }).catchError((e) => debugPrint(e.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StyleRule.colorBody,
      body: Container(
          padding: EdgeInsets.all(8.0),
          child: ListView(children: <Widget>[
            TopBar(
                loading: _loading,
                title: _placeShort,
                fnBtnGps: _getLocationAndPlaces,
                fnBtnSearch: _handlePressButton),
            DatePicker(_currentDate, _onChangeDay, _onChangeMonth),
            BoxInfo(_currentDate, _placeLong),
            TabsContent(childrens: <Widget>[
              PrayyerScreen(_currentDate, _prays, _onChangeDay),
              QiblaCompasScreen(_lat, _lng, _qibla, _placeShort),
              NearByMosqueScreen(_placesSearchResponse)
            ])
          ])),
    );
  }
}
