import 'package:flutter/material.dart';
import '../util.dart';

class BoxInfo extends StatelessWidget {
  final DateTime dateTime;
  static const String title = "28 Menit Ke Maghrib";
  final String description;

  const BoxInfo(this.dateTime, this.description, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: commonBoxDecoration,
      margin: EdgeInsets.only(top: 12.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
                height: 72,
                decoration: BoxDecoration(
                    color: StyleRule.colorPrimaryYoung,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(StyleRule.borderRadius),
                        topLeft: Radius.circular(StyleRule.borderRadius))),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      renderText(dateFormat(dateTime, f: 'dd'),
                          color: StyleRule.colorPrimaryDark),
                      renderText(
                          dateTime.difference(DateTime.now()).inDays == 0
                              ? 'Hari ini'
                              : dateFormat(dateTime, f: 'EE'),
                          color: StyleRule.colorPrimaryDark)
                    ])),
          ),
          Expanded(
              flex: 3,
              child: Container(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        renderText(title,
                            tOv: TextOverflow.ellipsis,
                            size: StyleRule.midFontSize,
                            color: StyleRule.titleTextColor),
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          child: renderText(
                            description,
                            tOv: TextOverflow.ellipsis,
                          ),
                        )
                      ])))
        ],
      ),
    );
  }
}
