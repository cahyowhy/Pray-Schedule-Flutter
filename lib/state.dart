import 'package:flutter/material.dart';

class StateProvider with ChangeNotifier {
  DateTime _current = DateTime.now();
  bool _loading = false;
  String _placeShort = "Unknown Place";
  String _placeLong = "Unknown Place, Unknown City, Unknown Country";
  double _lat = 0.0;
  double _lng = 0.0;
  double _qibla = 0.0;
  Map<String, String> _pray = {};

  void setProperties(double lat, double lng, String placeshort,
      String placelong, double qibla, Map<String, String> pray, bool loading) {
    this._lat = lat;
    this._lng = lng;
    this._qibla = qibla;
    this._placeShort = placeshort;
    this._placeLong = placelong;
    this._pray = pray;
    this._loading = loading;

    notifyListeners();
  }

  getCurrent() => _current;

  setCurrent(DateTime current) => _current = current;

  getPlaceShort() => _placeShort;

  getLat() => _lat;

  void setLat(double lat) {
    _lat = lat;

    notifyListeners();
  }

  getQibla() => _qibla;

  void setQibla(double qibla) {
    _qibla = qibla;
  }

  getPrayer() => _pray;

  void setPray(Map<String, String> pray) {
    _pray = pray;
  }

  getLng() => _lng;

  void setLng(double lng) {
    _lng = lng;

    notifyListeners();
  }

  void setPlaceShort(String placeShort) {
    _placeShort = placeShort;
    notifyListeners();
  }

  getPlaceLong() => _placeLong;

  void setPlaceLong(String placeLong) {
    _placeLong = placeLong;

    notifyListeners();
  }

  getLoading() => _loading;

  void setLoading(bool loading) {
    _loading = loading;

    notifyListeners();
  }

  void onChangeMonth(month) {
    _current = DateTime(_current.year, month, _current.day);

    notifyListeners();
  }

  void onChangeDay(day) {
    _current = DateTime(_current.year, _current.month, day);

    notifyListeners();
  }
}
