import 'package:airport/success.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class PayForm extends StatefulWidget {
  final Map vuelo;
  final String horario;
  final List selectedSeats;
  final int dateflightId;
  String fecha;
  String hora;
  final Function updateSeats;

  PayForm(
    this.vuelo,
    this.horario,
    this.selectedSeats,
    this.dateflightId,
    this.updateSeats,
  ) {
    this.fecha = this.horario.split(' ')[0];
    this.hora = this.horario.split(' ')[1];
  }

  @override
  State<StatefulWidget> createState() {
    return PayFormApp();
  }
}

class PayFormApp extends State<PayForm> {
  TextEditingController selectedDate = TextEditingController();
  void setDateCard() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        selectedDate.text = DateFormat('y-M-d').format(pickedDate);
      });
    });
  }

  void buySeats(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    http.Response response = await http.post(
      'http://192.168.0.19:3000/api/buyPlaces',
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Basic " + prefs.getString('token'),
      },
      body: json.encode(
        {
          'dateflight_id': widget.dateflightId,
          'places': widget.selectedSeats,
          'user_id': prefs.getInt('user_id'),
        },
      ),
    );

    final cuerpo = json.decode(response.body);

    if (cuerpo['status'] == 'success') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Success(),
        ),
      );
    } else {
      widget.updateSeats(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: size.height * 0.3,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/imgs/payment.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              AppBar(
                title: Text('Paso final'),
                backgroundColor: Colors.transparent,
              ),
            ],
          ),
          Center(
            child: Container(
              alignment: Alignment.center,
              height: size.height * 0.7,
              width: size.width * 0.8,
              child: Card(
                color: Colors.grey[200],
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Datos de la compra'),
                      Text('A: ' + widget.vuelo['to']),
                      Text('Fecha: ' + widget.fecha),
                      Text('Hora: ' + widget.hora),
                      Text('Lugares: ' + widget.selectedSeats.toString()),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'No. de Tarjeta de credito:',
                        ),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Fecha de vencimiento:',
                        ),
                        controller: selectedDate,
                      ),
                      RaisedButton(
                        child: Text('Select a date'),
                        onPressed: setDateCard,
                      ),
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'CVV:',
                        ),
                      ),
                      RaisedButton(
                        child: Text('Enviar'),
                        onPressed: () => buySeats(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
