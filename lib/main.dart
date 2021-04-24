import 'package:flutter/material.dart';
import 'package:cuentos/reader/index.dart';

void main() => runApp(MaterialApp(
      routes: <String, WidgetBuilder>{
        '/reader': (BuildContext context) => new ReaderPage(),
      },
      home: MyApp(),
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 250,
                // padding: EdgeInsets.all(20.0),
                child: DropdownButton(
                  onChanged: (selectedVal) => print(selectedVal),
                  value: 1,
                  items: [
                    DropdownMenuItem(
                      value: 1,
                      child: Text('La creación'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Center(
              child: IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () {
                  // print(Navigator.of(context));
                  Navigator.of(context).pushNamed('/reader');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
