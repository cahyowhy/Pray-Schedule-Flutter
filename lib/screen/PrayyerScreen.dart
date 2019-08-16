import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state.dart';
import '../util.dart';

class PrayyerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stateProvider = Provider.of<StateProvider>(context);
    final DateTime currentDate = stateProvider.getCurrent();
    final Map<String, String> pray = stateProvider.getPrayer();

    List<Widget> _renderPrayTime() {
      List<Map<String, String>> prayTimes = [];

      if (pray.isNotEmpty) {
        pray.forEach((String key, String value) {
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

    return Container(
        decoration: commonBoxDecoration,
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
        margin: EdgeInsets.only(top: 12.0),
        child: Column(children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.chevron_left),
                    color: StyleRule.titleTextColor,
                    onPressed: () =>
                        stateProvider.onChangeDay(currentDate.day - 1)),
                Container(
                    height: 50,
                    width: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: StyleRule.colorPrimaryYoung,
                        border: Border.all(color: StyleRule.colorgreyMain)),
                    child: renderText(dateFormat(currentDate, f: 'E'),
                        fw: FontWeight.w900,
                        ta: TextAlign.center,
                        size: 18,
                        color: StyleRule.colorPrimaryDark)),
                IconButton(
                    icon: Icon(Icons.chevron_right),
                    color: StyleRule.titleTextColor,
                    onPressed: () =>
                        stateProvider.onChangeDay(currentDate.day + 1)),
              ]),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4.0),
              child: Column(children: _renderPrayTime()))
        ]));
  }
}
