import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  final Function signIn;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  SignIn({
    @required this.signIn,
    @required this.email,
    @required this.password,
  });

  @override
  State<StatefulWidget> createState() {
    return SignInApp();
  }
}

class SignInApp extends State<SignIn> {
  bool cargando = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Inicia sesión',
          style: TextStyle(
            fontFamily: 'Staatliches-Regular',
            fontSize: 27,
          ),
        ),
        Card(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Correo',
                  ),
                  controller: widget.email,
                ),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                  ),
                  obscureText: true,
                  controller: widget.password,
                ),
                RaisedButton(
                  onPressed: () {
                    setState(() {
                      cargando = true;
                    });
                    widget.signIn(context).then((value) {
                      setState(() {
                        cargando = value;
                      });
                    });
                  },
                  child: Text('Enviar'),
                ),
                cargando
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
                    : Column(),
              ],
            ),
          ),
        )
      ],
    );
  }
}
