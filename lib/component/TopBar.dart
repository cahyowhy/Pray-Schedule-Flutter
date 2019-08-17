import 'package:flutter/material.dart';
import '../util.dart';

class TopBar extends StatelessWidget {
  final String title;
  final Function fnBtnGps;
  final Function fnBtnSearch;
  final bool loading;

  TopBar({Key key, this.title, this.fnBtnGps, this.fnBtnSearch, this.loading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8.0),
        decoration: commonBoxDecoration,
        child: Row(children: <Widget>[
          Expanded(child: renderText(title, tOv: TextOverflow.ellipsis)),
          Container(
              margin: EdgeInsets.only(right: 8.0),
              child: Material(
                  child: InkWell(
                onTap: fnBtnGps,
                child: Container(
                  child: Icon(
                    loading ? Icons.timelapse : Icons.gps_fixed,
                    size: StyleRule.iconSize,
                  ),
                  height: 26,
                  width: 26,
                ),
              ))),
          Material(
              child: InkWell(
            onTap: fnBtnSearch,
            child: Container(
              child: Icon(
                Icons.search,
                size: StyleRule.iconSize,
              ),
              height: 26,
              width: 26,
            ),
          ))
        ]));
  }
}
