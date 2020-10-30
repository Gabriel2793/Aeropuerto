import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './body.dart';
import './usersflights.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class Header extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HeaderApp();
  }
}

class HeaderApp extends State<Header> {
  int _selectedIndex = 0;
  List usersFlights = [];
  List<Widget> listWidgets = <Widget>[
    Body(),
  ];

  void _getUsersFlights() async {
    final prefs = await SharedPreferences.getInstance();

    http.Response response = await http.post(
      'http://192.168.0.19:3000/api/getUsersFlights',
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Basic " + prefs.getString('token'),
      },
      body: json.encode(
        {
          'user_id': prefs.getInt('user_id'),
        },
      ),
    );

    final cuerpo = json.decode(response.body);

    if (cuerpo['status'] == 'success') {
      setState(
        () {
          usersFlights = cuerpo['vuelos'];
          listWidgets.add(
            Column(
              children: cuerpo['vuelos'].length > 0
                  ? usersFlights.map(
                      (flight) {
                        return UsersFlights(
                          text: flight['to'],
                          horarios: flight['horarios'].split(','),
                          flight: flight,
                        );
                      },
                    ).toList()
                  : Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Perdon, pero no has comprado ningun asiento. Gracias',
                        style: TextStyle(
                          fontFamily: 'SkinerScort',
                          fontSize: 20,
                        ),
                      ),
                    ),
            ),
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getUsersFlights();
  }

  void _onItemTapped(int index) {
    UsersFlightsApp.removeBars();
    UsersFlightsApp.removeBars = () {};
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flight_sharp),
            label: 'Vuelos',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: size.height * 0.4,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/imgs/airplane.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  left: 40,
                  right: 40,
                  bottom: size.height * 0.4 / 2,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Bienvenido',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 37,
                        fontFamily: 'KindOfRock',
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            listWidgets[_selectedIndex],
          ],
        ),
      ),
    );
  }
}
