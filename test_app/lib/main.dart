import 'package:flutter/material.dart';
import 'state.dart';
import 'model/create_item.dart';
import 'package:test_app/model/product.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override

  Widget build(BuildContext context) {
    //Product product = new Product(heartrate:"120", temperature:"37.2",movement: "walk", oxygenconc:"95%",);
    
    //create_the_stuff('"createdAt":3266,"heartrate":85,"movement":active,"oxygenconc.":98,"temperature":37');
    return MaterialApp(
      title: 'Smart Mask',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: testNotificationScreen(),
    );
  }
}
