import 'package:flutter/material.dart';
import '../util.dart';

class DatePicker extends StatefulWidget {
  DateTime current;
  Function(int) fnChangeDay;
  void Function(dynamic) fnChangeMonth;

  DatePicker(this.current, this.fnChangeDay, this.fnChangeMonth, {Key key})
      : super(key: key);

  @override
  _DatePickerState createState() =>
      _DatePickerState(fnChangeDay, fnChangeMonth);
}

class _DatePickerState extends State<DatePicker> {
  bool _showDatePicker = true;
  Function(int) _fnChangeDay;
  void Function(dynamic) _fnChangeMonth;

  _DatePickerState(this._fnChangeDay, this._fnChangeMonth, {Key key});

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem> renderDropdownMonth() {
      List<DropdownMenuItem> dropdowns = [];

      for (int i = 1; i <= 12; i++) {
        DateTime current = DateTime(widget.current.year, i, 1);
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

        Color colorButton = widget.current.day == i + 1
            ? StyleRule.colorPrimaryYoung
            : StyleRule.colorgreyMain;

        Color colorText = widget.current.day == i + 1
            ? StyleRule.colorPrimaryDark
            : StyleRule.titleTextColor;

        Text textbutton = renderText(dateFormat(current, f: 'dd'),
            color: colorText,
            fw: widget.current.day == i + 1 ? FontWeight.w900 : null);

        Widget dateButton = ButtonTheme(
            minWidth: 36,
            height: 36,
            child: RaisedButton(
                color: colorButton,
                onPressed: () => _fnChangeDay((i + 1)),
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

    Widget dropdownMonth = DropdownButtonHideUnderline(
        child: DropdownButton(
            iconSize: StyleRule.iconSize,
            onChanged: _fnChangeMonth,
            items: renderDropdownMonth(),
            value: widget.current.month));

    return Container(
      decoration: commonBoxDecoration,
      margin: EdgeInsets.only(top: 12.0),
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                dropdownMonth,
                Material(
                    child: InkWell(
                  onTap: () {
                    setState(() {
                      _showDatePicker = !_showDatePicker;
                    });
                  },
                  child: Container(
                    child: Icon(
                      _showDatePicker
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      size: StyleRule.iconSize,
                    ),
                    height: 18,
                    width: 18,
                  ),
                ))
              ],
            ),
          ),
          _showDatePicker
              ? Container(
                  height: 95,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: renderDateByMonth(widget.current.month),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
