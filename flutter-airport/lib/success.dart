import 'package:flutter/material.dart';

class Success extends StatelessWidget {
  int cuenta = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Card(
            child: Column(
              children: [
                Text('Gracias por tu compra.'),
                RaisedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) {
                      return cuenta++ == 5;
                    });
                  },
                  child: Text('OK'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
