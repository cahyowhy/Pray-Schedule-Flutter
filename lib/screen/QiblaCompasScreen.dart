import 'dart:async';
import 'dart:math';
import 'package:coba_flutter/util.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:simple_flutter_compass/simple_flutter_compass.dart';

class QiblaCompasScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double qibla;
  final String placeName;

  QiblaCompasScreen(
      {Key key, this.latitude, this.longitude, this.qibla, this.placeName})
      : super(key: key);

  @override
  _QiblaCompasScreenState createState() => _QiblaCompasScreenState();
}

class _QiblaCompasScreenState extends State<QiblaCompasScreen> {
  Completer<GoogleMapController> _controller = Completer();
  SimpleFlutterCompass _simpleFlutterCompass = SimpleFlutterCompass();
  double _compas = 0;
  bool _hasAccelerometer = false;
  AssetImage _compassPointer = AssetImage("assets/images/map_north.png");
  AssetImage _qiblaPointer = AssetImage("assets/images/map_marker_qiblaa.png");

  static LatLng latLng = LatLng(0.0, 0.0);
  static MarkerId markerId = MarkerId("1");
  static Marker marker =
      Marker(markerId: markerId, draggable: false, position: latLng);

  CameraPosition cameraPosition = CameraPosition(
    target: latLng,
    zoom: 14.4746,
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{markerId: marker};

  void _streamListener(double currentHeading) {
    int fac = pow(10, 0);
    double currentHeadFix = (currentHeading * fac).round() / fac;

    if (_compas != currentHeadFix) {
      setState(() {
        _compas = currentHeadFix;
      });
    }
  }

  @override
  void didUpdateWidget(QiblaCompasScreen oldWidget) {
    bool difLat = oldWidget.latitude != widget.longitude;
    bool difLng = oldWidget.longitude != widget.longitude;
    bool difPlace = oldWidget.placeName != widget.placeName;
    bool difQibla = oldWidget.qibla != widget.qibla;

    if (difLat && difLng && difPlace && difQibla) {
      _updateMap();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _simpleFlutterCompass.stopListen();

    super.dispose();
  }

  Future<void> _updateMap() async {
    markers.remove(markerId);

    LatLng latLng = LatLng(widget.latitude, widget.longitude);
    CameraPosition cameraPosition = CameraPosition(
      target: latLng,
      zoom: 14.4746,
    );

    Marker newMarker = Marker(
        markerId: markerId,
        draggable: false,
        position: latLng,
        infoWindow: InfoWindow(title: widget.placeName));

    markers[markerId] = newMarker;

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  @override
  Widget build(BuildContext context) {
    Widget gmap = GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: cameraPosition,
      markers: Set<Marker>.of(markers.values),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);

        _simpleFlutterCompass.check().then((result) {
          setState(() {
            _hasAccelerometer = result;
          });

          if (result) {
            _simpleFlutterCompass.setListener(_streamListener);
            _simpleFlutterCompass.listen();
          } else {
            Scaffold.of(context).showSnackBar(new SnackBar(
              content: new Text("Hardware not avalaible"),
            ));
          }

          _updateMap();
        });
      },
    );

    Widget compassWrapper = _hasAccelerometer
        ? Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(6.0))),
            padding: EdgeInsets.all(8.0),
            child: Stack(children: <Widget>[
              RotationTransition(
                  child: Image(image: _compassPointer, width: 64),
                  turns: AlwaysStoppedAnimation(_compas / 360)),
              widget.qibla != 0
                  ? RotationTransition(
                      child: Image(image: _qiblaPointer, width: 64),
                      turns: AlwaysStoppedAnimation(
                          (widget.qibla - _compas) / 360))
                  : Container()
            ]))
        : Container();

    return Container(
        padding: EdgeInsets.all(8.0),
        decoration: commonBoxDecoration,
        child: Stack(children: <Widget>[gmap, compassWrapper]));
  }
}
