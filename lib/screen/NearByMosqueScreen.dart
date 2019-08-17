import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

class NearByMosqueScreen extends StatefulWidget {
  final PlacesSearchResponse placesSearchResponse;

  NearByMosqueScreen(this.placesSearchResponse, {Key key}) : super(key: key);

  @override
  _NearByMosqueScreenState createState() => _NearByMosqueScreenState();
}

class _NearByMosqueScreenState extends State<NearByMosqueScreen> {
  Completer<GoogleMapController> _controller = Completer();

  static LatLng _latLng = LatLng(0.0, 0.0);

  CameraPosition _cameraPosition = CameraPosition(
    target: _latLng,
    zoom: 14.4746,
  );

  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};

  Future<void> _updateMap() async {
    _markers.clear();

    if (widget.placesSearchResponse.results.length > 0) {
      // LatLngBounds latLngBounds = new LatLngBounds();
      // List<LatLng> latlngs = [];
      int i = 0;
      CameraPosition cameraPosition;
      widget.placesSearchResponse.results
          .forEach((PlacesSearchResult placeResult) {
        double lat = placeResult.geometry.location.lat;
        double lng = placeResult.geometry.location.lng;
        LatLng mapLatLng = LatLng(lat, lng);

        if (i == 0) {
          cameraPosition = CameraPosition(
            target: mapLatLng,
            zoom: 19,
          );
        }

        MarkerId mapMarkerId = MarkerId(placeResult.name);
        Marker mapMarker = Marker(
            markerId: mapMarkerId,
            draggable: false,
            position: mapLatLng,
            infoWindow: InfoWindow(title: placeResult.name));

        setState(() {
          _markers[mapMarkerId] = mapMarker;
        });
        
        i++;
      });

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }
  }

  @override
  void didUpdateWidget(NearByMosqueScreen oldWidget) {
    _updateMap();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
        mapType: MapType.normal,
        markers: Set<Marker>.of(_markers.values),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _updateMap();
        },
        initialCameraPosition: _cameraPosition);
  }
}
