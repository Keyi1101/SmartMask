import 'package:flutter/material.dart';
import 'package:test_app/model/create_item_fast.dart';
import 'package:test_app/model/fastp.dart';
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
    //fastproduct fp = new fastproduct(tim:'1244345',mode:'fast',tskin: '25',tenv: '30',tresp: '32',accelx: '25',accely: '13',accelz: '18',ppgir: '35',ppgred: '45');
    //createItemfast(fp);
    //createItem(product);
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