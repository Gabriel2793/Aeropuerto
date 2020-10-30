import 'dart:io';

import 'package:airport/payForm.dart';
import 'package:airport/seats.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import './selecthour.dart';
import 'package:mime/mime.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

class FlightDayScreen extends StatefulWidget {
  static const routerName = '/fligt-day-screen';
  final String fecha;

  FlightDayScreen({@required this.fecha});

  @override
  State<StatefulWidget> createState() {
    return FligthDayScreenApp();
  }
}

class FligthDayScreenApp extends State<FlightDayScreen> {
  int clickedSearch = 0;
  TimeOfDay _time = TimeOfDay.now();

  List flights = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    getFlights();
  }

  void getFlights() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      http.Response resp = await http.post(
        'http://192.168.0.19:3000/api/getFlights/',
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Basic " + prefs.getString('token'),
        },
        body: json.encode({
          'fecha': widget.fecha,
        }),
      );

      final jsonResp = json.decode(resp.body);

      setState(() {
        cargando = false;
        flights = jsonResp;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  Future<Map<String, dynamic>> selectHour(Map vuelo, String horario) async {
    return {'vuelo': vuelo, 'horario': horario};
  }

  void _chooseHour(BuildContext context, Size size, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => SelectHour(
          vuelo: flights[index],
          selectHour: (Map vuelo, String horario) {
            selectHour(vuelo, horario).then(
              (value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => Seats(
                      vuelo: value['vuelo'],
                      horario: value['horario'],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void onTimeChanged(TimeOfDay newTime) {
    setState(() {
      _time = newTime;
    });
  }

  void _googleMaps() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Size size = MediaQuery.of(context).size;

        return SimpleDialog(
          title: const Text('Aeropuerto en el que se desciende.'),
          children: <Widget>[
            Container(
              height: size.height * 0.4,
              color: Colors.purple[100],
              // child: GoogleMap(
              //   mapType: MapType.hybrid,
              //   initialCameraPosition: _kGooglePlex,
              //   onMapCreated: (GoogleMapController controller) {
              //     _controller.complete(controller);
              //   },
              // ),
            ),
            RaisedButton(
              onPressed: _goToTheLake,
              child: Row(
                children: [
                  Text('To the lake!'),
                  Icon(Icons.directions_boat),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    // final routerArgs =
    //     ModalRoute.of(context).settings.arguments as Map<String, Text>;
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: size.height * 0.3,
                child: Image.asset('assets/imgs/vuelos.jpg'),
              ),
              AppBar(
                title: Text(widget.fecha),
                toolbarHeight: size.height * 0.1,
                backgroundColor: Colors.transparent,
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.search,
                    ),
                    onPressed: () {
                      setState(
                        () {
                          if (clickedSearch == 0) {
                            clickedSearch = 1;
                          } else {
                            clickedSearch = 0;
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
              Positioned(
                bottom: size.height * 0.1,
                left: 40,
                right: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: clickedSearch == 1
                      ? TextField(
                          autofocus: true,
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            contentPadding: EdgeInsets.only(
                              left: 5,
                            ),
                            hintText: 'Buscar',
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
          cargando == true
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
              : Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(0),
                    itemBuilder: (ctx, index) {
                      return Card(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: size.width * 0.5,
                                  height: size.height * 0.2,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      topLeft: Radius.circular(10),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8),
                                    ),
                                    child: Image.memory(
                                      Uint8List.fromList(
                                        base64.decode(flights[index]['image']),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(17),
                                    height: size.height * 0.2,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                                    ),
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          child: Text(
                                            flights[index]['to'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          child: Text(
                                            flights[index]['cost'].toString(),
                                          ),
                                        ),
                                        Container(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: IconButton(
                                                  icon: Icon(Icons.map),
                                                  onPressed: _googleMaps,
                                                  iconSize: size.width * 0.07,
                                                  padding: EdgeInsets.all(0),
                                                ),
                                              ),
                                              Expanded(
                                                child: IconButton(
                                                  icon: Icon(Icons
                                                      .calendar_today_sharp),
                                                  onPressed: () => _chooseHour(
                                                    context,
                                                    size,
                                                    index,
                                                  ),
                                                  iconSize: size.width * 0.07,
                                                  padding: EdgeInsets.all(0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    itemCount: flights.length,
                  ),
                ),
        ],
      ),
    );
  }
}
