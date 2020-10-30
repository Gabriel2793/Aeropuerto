import 'package:airport/home.dart';
import 'package:flutter/material.dart';
import './FlightsDayScreen.dart';

void main() => runApp(MainScreen());

class MainScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
      routes: {
        FlightDayScreen.routerName: (_) => FlightDayScreen(),
      },
    );
  }
}
