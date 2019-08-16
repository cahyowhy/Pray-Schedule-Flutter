import 'package:flutter/material.dart';

import '../util.dart';

class TabsContent extends StatefulWidget {
  final List<Widget> childrens;

  TabsContent({@required this.childrens, Key key}) : super(key: key);

  @override
  TabsContentState createState() => new TabsContentState();
}

class TabsContentState extends State<TabsContent>
    with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = new TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [
      Tab(text: "Waktu"),
      Tab(text: "Kiblat"),
      Tab(text: "Masjid")
    ];

    Widget tabBar = Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: TabBar(
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: TextStyle(
              fontSize: StyleRule.midFontSize, fontWeight: FontWeight.w600),
          unselectedLabelColor: Colors.black38,
          unselectedLabelStyle: TextStyle(
              fontSize: StyleRule.fontSize, fontWeight: FontWeight.normal),
          labelColor: StyleRule.titleTextColor,
          indicatorColor: StyleRule.colorPrimary,
          controller: controller,
          tabs: tabs,
        ));

    Widget tabContent = Container(
        height: 300,
        child: TabBarView(controller: controller, children: widget.childrens));

    return Container(
      margin: EdgeInsets.only(top: 12),
      child: Column(
        children: <Widget>[tabBar, tabContent],
      ),
    );
  }
}
