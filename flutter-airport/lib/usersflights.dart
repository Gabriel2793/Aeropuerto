import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UsersFlights extends StatefulWidget {
  final String text;
  final List horarios;
  final flight;
  UsersFlights({
    Key key,
    @required this.text,
    @required this.horarios,
    @required this.flight,
  });

  @override
  State<UsersFlights> createState() {
    return UsersFlightsApp();
  }
}

class UsersFlightsApp extends State<UsersFlights> {
  GlobalKey actionKey;
  double height, width, xPosition, yPosition;
  bool isDropdownOpened = false;
  OverlayEntry floatingDropdown;
  static Function removeBars = () {};

  @override
  void initState() {
    actionKey = LabeledGlobalKey(widget.text);
    super.initState();
  }

  void findDropdownData() {
    RenderBox renderBox = actionKey.currentContext.findRenderObject();
    height = renderBox.size.height;
    width = renderBox.size.width;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    xPosition = offset.dx;
    yPosition = offset.dy;
  }

  void _getBoughtSeats(String horario) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id').toString();
    final flightId = widget.flight['id'].toString();

    print(widget.flight);

    http.Response response = await http.get(
      'http://192.168.0.19:3000/api/getBoughtSeats/' +
          userId +
          '/' +
          flightId +
          '/' +
          horario,
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Basic " + prefs.getString('token'),
      },
    );

    final cuerpo = json.decode(response.body);
    print(cuerpo);

    if (cuerpo['status'] == 'success') {
      final List seats = cuerpo['seats'].split(',');
      UsersFlightsApp.removeBars();
      UsersFlightsApp.removeBars = () {};
      showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: GridView.count(
              primary: false,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
              crossAxisCount: 4,
              children: List.generate(20, (index) {
                if (seats.contains(index.toString())) {
                  return Icon(
                    Icons.event_seat,
                    color: Colors.green[100],
                  );
                } else {
                  return Icon(
                    Icons.event_seat,
                    color: Colors.grey,
                  );
                }
              }),
            ),
          );
        },
      );
    }
  }

  OverlayEntry _createFloatingDropdown() {
    return OverlayEntry(builder: (context) {
      return Positioned(
        left: xPosition,
        width: width,
        top: (height + yPosition),
        child: Container(
          alignment: Alignment.center,
          height: height * widget.horarios.length,
          color: Colors.blueGrey,
          child: SingleChildScrollView(
            child: Column(
              children: widget.horarios.map(
                (horario) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: Text(
                          horario,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      RaisedButton(
                        onPressed: () => _getBoughtSeats(horario),
                        child: Text(
                          'Ver asientos',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ).toList(),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: actionKey,
      onTap: () {
        setState(
          () {
            if (isDropdownOpened) {
              floatingDropdown.remove();
              removeBars = () {};
            } else {
              UsersFlightsApp.removeBars();
              findDropdownData();
              floatingDropdown = _createFloatingDropdown();
              Overlay.of(context).insert(floatingDropdown);
              removeBars = () {
                floatingDropdown.remove();
                isDropdownOpened = !isDropdownOpened;
              };
            }
            isDropdownOpened = !isDropdownOpened;
          },
        );
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(0),
            ),
            padding: EdgeInsets.all(17),
            child: Row(
              children: [
                Text(widget.text),
                Spacer(),
                Icon(Icons.arrow_circle_down),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
