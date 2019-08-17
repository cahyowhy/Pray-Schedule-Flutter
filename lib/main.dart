import 'package:coba_flutter/component/BoxInfo.dart';
import 'package:coba_flutter/component/DatePicker.dart';
import 'package:coba_flutter/component/TabWrapper.dart';
import 'package:coba_flutter/component/TopBar.dart';
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
  BuildContext _context;

  DateTime _currentDate = DateTime.now();
  String _placeLong = "Unknown Location";
  bool _loading = false;
  String _placeShort = "Unknown Location";
  double _lat = 0.0;
  double _lng = 0.0;
  double _qibla = 0.0;
  Map<String, String> _prays = {};

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then((value) {
      _context = context;
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

        getPlaceByLatLng(latitude, longitude).then((data) {
          if (data["succes"]) {
            _findQiblaPrayer(data["placeName"]);
          }
        });
      });
    }
  }

  Future<void> _findQiblaPrayer(String location) async {
    Map<String, dynamic> data = await getPrayerTime(
        location, dateFormat(_currentDate, f: "dd-MM-yyyy"));

    if (data["success"]) {
      setState(() {
        _lat = data["latitude"];
        _lng = data["longitude"];
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
    });
  }

  void _onChangeMonth(month) {
    setState(() {
      _currentDate = DateTime(_currentDate.year, month, _currentDate.day);
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
      debugPrint(p.terms?.first?.value);
      _findQiblaPrayer(p.terms?.first?.value);
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
              QiblaCompasScreen(
                  latitude: _lat,
                  longitude: _lng,
                  placeName: _placeShort,
                  qibla: _qibla),
              Container(
                  child: Column(children: <Widget>[
                Text(_placeShort),
                Icon(Icons.arrow_back)
              ])),
            ])
          ])),
    );
  }
}
