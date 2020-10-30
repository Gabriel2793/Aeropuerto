import 'package:shared_preferences/shared_preferences.dart';

import './signIn.dart';
import './signUp.dart';
import 'package:flutter/material.dart';
import './header.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeApp();
  }
}

class HomeApp extends State<Home> {
  bool signs = false;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Future<bool> _signIn(BuildContext context) async {
    http.Response response = await http.post(
      'http://192.168.0.19:3000/api/signIn',
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      },
      body: json.encode(
        {
          'email': email.text,
          'password': password.text,
        },
      ),
    );

    Map cuerpo = json.decode(response.body);

    if (cuerpo['status'] == 'success') {
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('user_id', cuerpo['id']);
      prefs.setString('token', cuerpo['token']);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Header(),
        ),
      );
      return false;
    } else {
      return false;
    }
  }

  Future<bool> _signUp(BuildContext context) async {
    print(email.text);
    print(password.text);
    http.Response response = await http.post(
      'http://192.168.0.19:3000/api/signUp',
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      },
      body: json.encode(
        {
          'email': email.text,
          'password': password.text,
        },
      ),
    );
    Map cuerpo = json.decode(response.body);

    if (cuerpo['status'] == 'success') {
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(cuerpo['status']),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(cuerpo['message']),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  email.text = '';
                  password.text = '';
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/imgs/bienvenido.jpg'),
                ),
              ),
              height: size.height * 0.4,
              child: Text(
                'Bienvenido',
                style: TextStyle(
                  fontFamily: 'Staatliches-Regular',
                  fontSize: 27,
                  color: Colors.white,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      signs = false;
                    });
                    Navigator.of(context).pop();
                  },
                  child: ListTile(
                    leading: Icon(Icons.message),
                    title: Text('Iniciar sesión'),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      signs = true;
                    });
                    Navigator.of(context).pop();
                  },
                  child: ListTile(
                    leading: Icon(Icons.account_circle),
                    title: Text('Regístrate'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: size.height * 0.4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/imgs/airport.jpg',
                      fit: BoxFit.fill,
                    ),
                    AppBar(
                      title: Text('Aeropuerto de Quetzalcóatl'),
                      backgroundColor: Colors.transparent,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: signs == false
                    ? SignIn(
                        signIn: _signIn,
                        email: email,
                        password: password,
                      )
                    : SignUp(
                        signUp: _signUp,
                        email: email,
                        password: password,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
