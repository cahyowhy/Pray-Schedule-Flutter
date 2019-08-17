import 'package:flutter/material.dart';
import '../util.dart';

class PrayyerScreen extends StatelessWidget {
  final Function(int) _onChangeDay;
  final DateTime _currentDate;
  final Map<String, String> _prays;

  PrayyerScreen(this._currentDate, this._prays, this._onChangeDay);

  @override
  Widget build(BuildContext context) {
    List<Widget> _renderPrayTime() {
      List<Map<String, String>> prayTimes = [];

      if (_prays.isNotEmpty) {
        _prays.forEach((String key, String value) {
          prayTimes.add({"name": key, "values": value});
        });
      }

      if (prayTimes.length == 0) {
        return [
          Container(
            padding: EdgeInsets.all(16.0),
            child: Icon(Icons.archive, size: 72, color: StyleRule.textColor),
            margin: EdgeInsets.only(bottom: 8.0),
          ),
          Text(
            "No Content To Load",
            style: TextStyle(
                fontSize: StyleRule.heavyFontSize,
                fontWeight: FontWeight.bold,
                color: StyleRule.textColor),
          )
        ];
      }

      List<Widget> widgets = [];

      for (int i = 0; i <= prayTimes.length - 1; i++) {
        widgets.add(Container(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  renderText(prayTimes[i]["name"],
                      color: StyleRule.titleTextColor,
                      size: StyleRule.midFontSize),
                  renderText(prayTimes[i]["values"],
                      fw: FontWeight.bold,
                      color: StyleRule.titleTextColor,
                      size: StyleRule.midFontSize),
                ])));
      }

      return widgets;
    }

    Widget _dayController = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.chevron_left),
              color: StyleRule.titleTextColor,
              onPressed: () => _onChangeDay(_currentDate.day - 1)),
          Container(
              height: 50,
              width: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: StyleRule.colorPrimaryYoung,
                  border: Border.all(color: StyleRule.colorgreyMain)),
              child: renderText(dateFormat(_currentDate, f: 'E'),
                  fw: FontWeight.w900,
                  ta: TextAlign.center,
                  size: 18,
                  color: StyleRule.colorPrimaryDark)),
          IconButton(
              icon: Icon(Icons.chevron_right),
              color: StyleRule.titleTextColor,
              onPressed: () => _onChangeDay(_currentDate.day + 1)),
        ]);

    return Container(
        decoration: commonBoxDecoration,
        padding: EdgeInsets.all(12),
        child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              _dayController,
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4.0),
                  child: ListView(
                      children: _renderPrayTime(),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true))
            ]));
  }
}
