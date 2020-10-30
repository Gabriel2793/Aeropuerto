import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import './FlightsDayScreen.dart';
import 'package:intl/intl.dart';

class Body extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BodyApp();
  }
}

class BodyApp extends State<Body> {
  var _calendarController;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(
    DateTime day,
    List events,
    List holidays,
    BuildContext context,
  ) {
    final format = DateFormat('y-M-d');
    final myday = format.format(day);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FlightDayScreen(
          fecha: myday,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: ClipRect(
        child: TableCalendar(
          calendarController: _calendarController,
          onDaySelected: (
            DateTime day,
            List events,
            List holidays,
          ) {
            _onDaySelected(
              day,
              events,
              holidays,
              context,
            );
          },
        ),
      ),
    );
  }
}
