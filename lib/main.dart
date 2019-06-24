import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class StyleRule {
  static const Color colorPrimary = Color(0XFF9EFF8A);

  static const Color colorPrimaryDark = Color(0XFF68be56);

  static const Color colorPrimaryYoung = Color(0XFFe7ffe1);

  static const Color colorgreyMain = Color(0xfff6f7fa);

  static const Color colorgreyMain10 = Color(0xffe5eced);

  static const Color colorBody = Color(0xfff9f9f9);

  static const Color titleTextColor = Colors.black87;

  static const Color textColor = Colors.black54;

  static const double titleFontSize = 20;

  static const double midFontSize = 14;

  static const double fontSize = 12;

  static const double iconSize = 16;

  static const double borderRadius = 3;
}

BoxDecoration commonBoxDecoration = BoxDecoration(
  borderRadius: BorderRadius.all(Radius.circular(StyleRule.borderRadius)),
  color: Colors.white,
  border: Border.all(
      color: StyleRule.colorgreyMain10, width: 1.5, style: BorderStyle.solid),
);

String dateFormat(DateTime date, {String f = 'MMMM'}) {
  return new DateFormat(f).format(date);
}

Text renderText(String s,
    {double size = StyleRule.fontSize,
    TextAlign ta = TextAlign.left,
    Color color = StyleRule.textColor,
    FontWeight fw = FontWeight.normal,
    TextOverflow tOv = TextOverflow.clip}) {
  return Text(s,
      style: TextStyle(color: color, fontSize: size, fontWeight: fw),
      overflow: tOv,
      textAlign: ta);
}

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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class TabViewTime extends StatefulWidget {
  DateTime current;

  TabViewTime(this.current);

  @override
  State<StatefulWidget> createState() => new TabViewTimeState(current);
}

class TabViewTimeState extends State<TabViewTime> {
  DateTime current;

  TabViewTimeState(this.current);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: commonBoxDecoration,
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.only(top: 12.0),
        child: Column(children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.chevron_left),
                    color: StyleRule.titleTextColor,
                    onPressed: () {}),
                Container(
                    height: 50,
                    width: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: StyleRule.colorgreyMain)),
                    child: renderText(dateFormat(current, f: 'E'),
                        fw: FontWeight.w900,
                        ta: TextAlign.center,
                        size: 18,
                        color: StyleRule.colorPrimary)),
                IconButton(
                    icon: Icon(Icons.chevron_right),
                    color: StyleRule.titleTextColor,
                    onPressed: () {}),
              ])
        ]));
  }
}

class TabsContent extends StatefulWidget {
  DateTime current;

  TabsContent(this.current);

  @override
  TabsContentState createState() => new TabsContentState(current);
}

class TabsContentState extends State<TabsContent>
    with SingleTickerProviderStateMixin {
  TabController controller;
  DateTime current;

  TabsContentState(this.current);

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

    Widget TabBarWrapper = Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: TabBar(
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: TextStyle(
              fontSize: StyleRule.fontSize, fontWeight: FontWeight.bold),
          unselectedLabelColor: Colors.black38,
          unselectedLabelStyle: TextStyle(
              fontSize: StyleRule.fontSize, fontWeight: FontWeight.normal),
          labelColor: StyleRule.titleTextColor,
          indicatorColor: StyleRule.colorPrimary,
          controller: controller,
          tabs: tabs,
        ));

    Widget TabContentWrapper = Expanded(
        child: TabBarView(controller: controller, children: <Widget>[
      TabViewTime(current),
      Container(child: renderText(dateFormat(current, f: 'EEE'))),
      Container(child: Icon(Icons.arrow_back)),
    ]));

    return Container(
      margin: EdgeInsets.only(top: 12),
      child: Column(
        children: <Widget>[TabBarWrapper, TabContentWrapper],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _current;

  @override
  void initState() {
    _current = DateTime.now();

    super.initState();
  }

  void onChangeMonth(month) {
    setState(() {
      _current = DateTime(_current.year, month, _current.day);
    });
  }

  void onChangeDay(day) {
    setState(() {
      _current = DateTime(_current.year, _current.month, day);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    List<DropdownMenuItem> renderDropdownMonth() {
      List<DropdownMenuItem> dropdowns = [];

      for (int i = 1; i <= 12; i++) {
        DateTime current = DateTime(DateTime.now().year, i, 1);
        Text month =
            renderText(dateFormat(current), color: StyleRule.titleTextColor);

        dropdowns.add(DropdownMenuItem(child: month, value: current.month));
      }

      return dropdowns;
    }

    List<Widget> renderDateByMonth(int month) {
      List<Widget> monthLoops = [];
      DateTime now = DateTime.now();
      DateTime first = new DateTime(now.year, month, 1);
      DateTime last = new DateTime(now.year, month + 1, 0);

      int count = last.difference(first).inDays;

      for (int i = 0; i <= count; i++) {
        DateTime current = new DateTime(now.year, month, i + 1);

        Color colorButton = _current.day == i + 1
            ? StyleRule.colorPrimary
            : StyleRule.colorgreyMain;

        Color colorText =
            _current.day == i + 1 ? Colors.white : StyleRule.titleTextColor;

        Text textbutton =
            renderText(dateFormat(current, f: 'dd'), color: colorText);

        Widget dateButton = ButtonTheme(
            minWidth: 36,
            height: 36,
            child: RaisedButton(
                color: colorButton,
                onPressed: () => onChangeDay(i + 1),
                child: textbutton,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25)))));

        monthLoops.add(Column(
          children: <Widget>[
            renderText(dateFormat(current, f: 'EE')),
            dateButton
          ],
        ));
      }

      return monthLoops;
    }

    Widget renderDatePicker = Container(
      decoration: commonBoxDecoration,
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                DropdownButtonHideUnderline(
                    child: DropdownButton(
                        iconSize: StyleRule.iconSize,
                        onChanged: onChangeMonth,
                        items: renderDropdownMonth(),
                        value: _current.month)),
                Material(
                    child: InkWell(
                  onTap: () => print("cek"),
                  child: Container(
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: StyleRule.iconSize,
                    ),
                    height: 18,
                    width: 18,
                  ),
                ))
              ],
            ),
          ),
          Container(
            height: 86,
            padding: EdgeInsets.symmetric(vertical: 12),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: renderDateByMonth(_current.month),
            ),
          )
        ],
      ),
    );

    Widget renderCurrentInfo = Container(
      decoration: commonBoxDecoration,
      margin: EdgeInsets.only(top: 12.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
                height: 60,
                decoration: BoxDecoration(
                    color: StyleRule.colorPrimaryYoung,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(StyleRule.borderRadius),
                        topLeft: Radius.circular(StyleRule.borderRadius))),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      renderText(dateFormat(_current, f: 'dd'),
                          color: StyleRule.colorPrimaryDark),
                      renderText(
                          _current.difference(DateTime.now()).inDays == 0
                              ? 'Hari ini'
                              : dateFormat(_current, f: 'EE'),
                          color: StyleRule.colorPrimaryDark)
                    ])),
          ),
          Expanded(
              flex: 4,
              child: Container(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        renderText("28 Menit Menuju Maghrib",
                            tOv: TextOverflow.ellipsis,
                            size: StyleRule.midFontSize,
                            color: StyleRule.titleTextColor),
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          child: renderText(
                            "Jalan Rasuna Said no 8, Penjaringan, Jakarta Utara",
                            tOv: TextOverflow.ellipsis,
                          ),
                        )
                      ])))
        ],
      ),
    );

    return Scaffold(
      backgroundColor: StyleRule.colorBody,
      body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(children: <Widget>[
            renderDatePicker,
            renderCurrentInfo,
            Expanded(child: TabsContent(_current))
          ])),
    );
  }
}
