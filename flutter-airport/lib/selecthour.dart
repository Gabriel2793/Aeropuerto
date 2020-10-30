import 'package:flutter/material.dart';

class SelectHour extends StatefulWidget {
  final Function selectHour;
  final Map vuelo;

  SelectHour({
    @required this.selectHour,
    @required this.vuelo,
  });

  @override
  State<SelectHour> createState() {
    return SelectHourApp();
  }
}

class SelectHourApp extends State<SelectHour> {
  double currentSliderValue = 0;
  List hourList;

  @override
  void initState() {
    super.initState();
    hourList = widget.vuelo['horarios'] as List;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: size.height * 0.3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: size.width * 0.8,
                  height: size.height * 0.3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: Image.asset(
                      'assets/imgs/sun.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                AppBar(
                  title: Text('Selecciona la hora'),
                  toolbarHeight: size.height * 0.1,
                  backgroundColor: Colors.transparent,
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            height: size.height * 0.7,
            width: size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    color: Colors.grey[200],
                  ),
                  alignment: Alignment.center,
                  width: size.width * 0.8,
                  height: size.height * 0.3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        child: Text(
                          hourList[currentSliderValue.toInt()].split(' ')[1],
                          style: TextStyle(
                            fontFamily: 'SkinerScort',
                            fontSize: 27,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        child: Slider(
                          value: currentSliderValue,
                          min: 0,
                          max: (hourList.length - 1).toDouble(),
                          divisions: (hourList.length - 1) == 0
                              ? 1
                              : hourList.length - 1,
                          onChanged: (double value) {
                            setState(() {
                              currentSliderValue = value;
                            });
                          },
                        ),
                      ),
                      FlatButton(
                        onPressed: () => widget.selectHour(
                          widget.vuelo,
                          hourList[currentSliderValue.toInt()],
                        ),
                        child: Text(
                          'OK',
                          style: TextStyle(color: Colors.purple),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
