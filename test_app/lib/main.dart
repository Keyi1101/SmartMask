import 'package:flutter/material.dart';
import 'state.dart';
import 'model/create_item.dart';
import 'package:test_app/model/product.dart';
//import 'FirstPage.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override

  Widget build(BuildContext context) {
    Product product = new Product(heartrate:"80", temperature:"37",movement: "run", oxygenconc:"90",);
    createItem(product);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: testNotificationScreen(),
    );
  }
}