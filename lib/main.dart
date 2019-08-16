import 'package:coba_flutter/component/BoxInfo.dart';
import 'package:coba_flutter/component/DatePicker.dart';
import 'package:coba_flutter/component/TabWrapper.dart';
import 'package:coba_flutter/component/TopBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';

import 'package:coba_flutter/screen/QiblaCompasScreen.dart';
import 'package:coba_flutter/screen/PrayyerScreen.dart';

import './state.dart';
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
      home: ChangeNotifierProvider<StateProvider>(
        builder: (_) => StateProvider(),
        child: MyHomePage(),
      ),
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

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then((value) {
      _context = context;
      _getLocationAndPlaces();
    });
  }

  _getLocationAndPlaces() {
    final stateProvider = Provider.of<StateProvider>(_context);

    if (!stateProvider.getLoading()) {
      stateProvider.setLoading(true);

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
    final stateProvider = Provider.of<StateProvider>(_context);

    Map<String, dynamic> data = await getPrayerTime(
        location, dateFormat(stateProvider.getCurrent(), f: "dd-MM-yyyy"));

    if (data["success"]) {
      stateProvider.setProperties(
          data["latitude"],
          data["longitude"],
          data["country"],
          data["address"],
          data["qibla_direction"],
          data["items"], false);
    }
  }

  void onError(PlacesAutocompleteResponse response) {
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  _handlePressButton() {
    PlacesAutocomplete.show(
      context: context,
      apiKey: gmapApiKey,
      onError: onError,
      mode: Mode.fullscreen,
      language: "en",
    ).then((p) {
      _findQiblaPrayer(p.description);
    }).catchError((e) => debugPrint(e.toString()));
  }

  @override
  Widget build(BuildContext context) {
    final stateProvider = Provider.of<StateProvider>(context);
    DateTime currentDate = stateProvider.getCurrent();
    String placeLong = stateProvider.getPlaceLong();
    bool loading = stateProvider.getLoading();
    String placeShort = stateProvider.getPlaceShort();
    double lat = stateProvider.getLat();
    double lng = stateProvider.getLng();
    double qibla = stateProvider.getQibla();

    return Scaffold(
      backgroundColor: StyleRule.colorBody,
      body: Container(
          padding: EdgeInsets.all(8.0),
          child: ListView(children: <Widget>[
            TopBar(
                loading: loading,
                title: placeShort,
                fnBtnGps: _getLocationAndPlaces,
                fnBtnSearch: _handlePressButton),
            DatePicker(),
            BoxInfo(currentDate, placeLong),
            TabsContent(childrens: <Widget>[
              PrayyerScreen(),
              QiblaCompasScreen(
                  latitude: lat,
                  longitude: lng,
                  placeName: placeShort,
                  qibla: qibla),
              Container(
                  child: Column(children: <Widget>[
                Text(placeShort),
                Icon(Icons.arrow_back)
              ])),
            ])
          ])),
    );
  }
}
