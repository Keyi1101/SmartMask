import 'package:flutter/material.dart';
import 'LocalNotificationManager.dart';

class testNotificationScreen extends StatefulWidget {

  const testNotificationScreen({Key key}) : super(key: key);

  @override
  _FirstScreen createState() => _FirstScreen();
}


class _FirstScreen extends State<testNotificationScreen> {

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

    var stack=new Stack(
        children:<Widget> [
          new Positioned(
              top:100.0,
              right:80.0,
              child:RouteButton()
          ),
          new Positioned(
              top:180.0,
              right:80.0,
              child:new Text('Remaining Battery:')
          ),
        ]
    );

    return Scaffold(
      appBar:AppBar(title:Text("Your data")),
      body:Center(
        child: stack,
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

//跳转的Button
class RouteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:(){
        _navigateToSecondScreen(context);
      },
      child: Text('change your preference'),
    );
  }

  _navigateToSecondScreen(BuildContext context) async{ //async是启用异步方法

    final result = await Navigator.push(//等待
        context,
        MaterialPageRoute(builder: (context)=> SecondScreen())
    );

    Scaffold.of(context).showSnackBar(SnackBar(content:Text('$result')));
  }
}

class SecondScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){


    return Scaffold(
        appBar:AppBar(title:Text('change strategy of detection')),
        body:Center(
            child:
            Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: <Widget>[
                  ElevatedButton(
                    child:Text('High update frequency',style: TextStyle(fontSize: 20.0)),
                    onPressed: (){
                      Navigator.pop(context,'Mode set to: High update frequency');
                    },
                  ),
                  ElevatedButton(
                    child:Text('Medium update frequency',style: TextStyle(fontSize: 20.0)),
                    onPressed: (){
                      Navigator.pop(context,'Mode set to: Medium update frequency');
                    },
                  ),
                  ElevatedButton(
                    child:Text('Low update frequency',style: TextStyle(fontSize: 20.0)),
                    onPressed: (){
                      Navigator.pop(context,'Mode set to: Low update frequency');
                    },
                  )
                ]
            )
        )
    );

  }
}