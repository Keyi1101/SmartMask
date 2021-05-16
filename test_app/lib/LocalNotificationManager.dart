import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:rxdart/subjects.dart';

class LocalNotificationManager{
  FlutterLocalNotificationsPlugin localNotificationPlugin;
  var initializationSettings;
  BehaviorSubject<ReceiveNotification> get didReceiveLocalNotificationSubject =>
                                BehaviorSubject<ReceiveNotification>();

  LocalNotificationManager.init(){
    localNotificationPlugin = FlutterLocalNotificationsPlugin();
    if(Platform.isIOS){
      requestIOSpermission();
    }
    initializePlatform();
  }
  requestIOSpermission(){
    localNotificationPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        .requestPermissions(
      alert: true,
      badge: true,
      sound: true
    );
  }

  initializePlatform(){
    var androidInitialize = new AndroidInitializationSettings(
        '@mipmap/ic_launcher');
    var iOSinitialize = new IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id,title,body,payload) async{
        ReceiveNotification notification = ReceiveNotification(id:id, title:title, body:body, payload:payload);
        didReceiveLocalNotificationSubject.add(notification);
      }
    );
    initializationSettings = new InitializationSettings(
        android: androidInitialize, iOS: iOSinitialize);
    localNotificationPlugin.initialize(initializationSettings);
  }

  setOnNotificationReceive(Function onNotificationReceive){
    didReceiveLocalNotificationSubject.listen((notification) {
      onNotificationReceive(notification);

    });

  }
  //IOS turn on notification click
  setOnNotificationClick(Function onNotificationClick) async {
    await  localNotificationPlugin.initialize( initializationSettings,
        onSelectNotification: (String payload) async{
          onNotificationClick(payload);
    });
  }

// show  notification function
  Future<void> showNotification () async{
    var androidDetails = new AndroidNotificationDetails(
      'ChannelID',
      'Local notification',
      'description can edit',
      importance: Importance.max,
      priority: Priority.high,
      enableLights: true
    );
    var iosDetails = new IOSNotificationDetails(
    );
    var generalNotificationDetails = new NotificationDetails(android:androidDetails,iOS: iosDetails);
    await localNotificationPlugin.show(
        0,
        'MF technology',
        'smart mask',
        generalNotificationDetails,
        payload: 'New Payload',
    );
  }
}


LocalNotificationManager localNotificationManager = LocalNotificationManager.init();

class ReceiveNotification{
  int id;
  String title;
  String body;
  String payload;
  ReceiveNotification({@required this.id, @required this.title,@required this.body, @required this.payload});
}