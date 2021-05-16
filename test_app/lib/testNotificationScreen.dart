import 'package:flutter/material.dart';
import 'LocalNotificationManager.dart';


class testNotificationScreen extends StatefulWidget {

  const testNotificationScreen({Key key}) : super(key: key);

  @override
  _testNotificationScreenState createState() => _testNotificationScreenState();
}

class _testNotificationScreenState extends State<testNotificationScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    localNotificationManager.setOnNotificationReceive(onNotificationReceive);
    localNotificationManager.setOnNotificationClick(onNotificationClick);
  }

  onNotificationReceive(ReceiveNotification notification){
    print('Notification Received:${notification.id}');
  }

  onNotificationClick(String payload){
    print('Payload $payload ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("click botton to get notification"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          await localNotificationManager.showNotification();
        },
        child: Icon(Icons.notifications),
      ),

    );
  }
}

