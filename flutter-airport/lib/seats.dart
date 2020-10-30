import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './payForm.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class Seats extends StatefulWidget {
  final Map vuelo;
  final String horario;

  Seats({@required this.vuelo, @required this.horario});

  @override
  State<StatefulWidget> createState() {
    return SeatsApp();
  }
}

class SeatsApp extends State<Seats> {
  List seats = [];
  List selectedSeats = [];
  int dateflightId;
  int contador = 0;

  void updateSeats(context) {
    Navigator.of(context).pop();
    _getSeats();
  }

  void _getSeats() async {
    final prefs = await SharedPreferences.getInstance();

    http.Response response = await http.get(
      'http://192.168.0.19:3000/api/getSeats/' +
          widget.vuelo['id'].toString() +
          '/' +
          widget.horario.replaceAll(' ', '%20'),
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Basic " + prefs.getString('token'),
      },
    );

    Map data = json.decode(response.body)[0];
    dateflightId = data['id'];

    setState(() {
      seats = data['ocupado']
          .split(',')
          .map((String value) => int.parse(value))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _getSeats();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: size.height * 0.4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/imgs/seats.jpg',
                  fit: BoxFit.cover,
                ),
                AppBar(
                  title: Text('Selecciona tus acientos'),
                  toolbarHeight: size.height * 0.1,
                  backgroundColor: Colors.transparent,
                ),
                Positioned(
                  bottom: size.height * 0.1,
                  left: 40,
                  right: 40,
                  child: RaisedButton(
                    color: Colors.amber[100],
                    onPressed: () {
                      if (selectedSeats.length == 0) {
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => PayForm(
                              widget.vuelo,
                              widget.horario,
                              selectedSeats,
                              dateflightId,
                              updateSeats,
                            ),
                          ),
                        );
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payment),
                        Text('Pagar'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: size.height * 0.6,
            child: seats.length == 0
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: size.height * 0.2,
                        width: size.height * 0.2,
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.grey,
                        ),
                      ),
                    ],
                  )
                : GridView.count(
                    primary: false,
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 4,
                    children: List.generate(
                      seats.length,
                      (i) {
                        if (seats[i] == 0 || seats[i] == 2) {
                          return IconButton(
                            icon: Icon(Icons.event_seat),
                            color:
                                seats[i] == 0 ? Colors.grey[100] : Colors.blue,
                            iconSize: 40,
                            onPressed: () {
                              if (seats[i] == 0) {
                                if (!selectedSeats.contains(i)) {
                                  selectedSeats.add(i);
                                }
                                setState(() {
                                  seats[i] = 2;
                                  contador = 0;
                                });
                              } else {
                                if (selectedSeats.contains(i)) {
                                  selectedSeats.remove(i);
                                }
                                setState(() {
                                  seats[i] = 0;
                                  contador = 0;
                                });
                              }
                            },
                          );
                        } else {
                          return IconButton(
                            icon: Icon(Icons.event_seat),
                            color: Colors.black,
                            iconSize: 40,
                            onPressed: () {},
                          );
                        }
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
