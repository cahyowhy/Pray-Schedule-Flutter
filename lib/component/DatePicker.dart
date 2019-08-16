import 'package:flutter/material.dart';
import '../util.dart';
import 'package:provider/provider.dart';
import '../state.dart';

class DatePicker extends StatefulWidget {
  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  bool _showDatePicker = true;

  @override
  Widget build(BuildContext context) {
    final stateProvider = Provider.of<StateProvider>(context);
    var currentDate = stateProvider.getCurrent();

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

        Color colorButton = currentDate.day == i + 1
            ? StyleRule.colorPrimaryYoung
            : StyleRule.colorgreyMain;

        Color colorText = currentDate.day == i + 1
            ? StyleRule.colorPrimaryDark
            : StyleRule.titleTextColor;

        Text textbutton = renderText(dateFormat(current, f: 'dd'),
            color: colorText,
            fw: currentDate.day == i + 1 ? FontWeight.w900 : null);

        Widget dateButton = ButtonTheme(
            minWidth: 36,
            height: 36,
            child: RaisedButton(
                color: colorButton,
                onPressed: () => stateProvider.onChangeDay(i + 1),
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
            onChanged: stateProvider.onChangeMonth,
            items: renderDropdownMonth(),
            value: currentDate.month));

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
                    children: renderDateByMonth(currentDate.month),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
