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
              bottom:100.0,
              right:10.0,
              child:RouteButton()
          ),

          new Positioned(
              bottom:10.0,
              left:10.0,
              child:RouteButtonToInterconnectedScreen()
          ),

          new Positioned(
              bottom:80.0,
              right:30.0,
              child:new Text('Remaining Battery:')
          ),

          new Positioned(
              top: 30.0,
              left:30.0,
              child:new Text('Movement status:',style: TextStyle(fontSize: 20.0))//indicate the extent of movement of user(eg.highly active, medium active,not so active,still)
          ),

          new Positioned(
              top: 70.0,
              left:30.0,
              child:new Text('Your heart rate:',style: TextStyle(fontSize: 20.0))
          ),

          new Positioned(
              top: 110.0,
              left:30.0,
              child:new Text('Your body temperature(predicted):',style: TextStyle(fontSize: 20.0))
          ),

          new Positioned(
              top: 150.0,
              left:30.0,
              child:new Text('Your blood oxygen concentration:',style: TextStyle(fontSize: 20.0))
          ),

          new Positioned(
              bottom: 160.0,
              left:30.0,
              child:new Text('We have our chart from grafana to be placed above',style: TextStyle(fontSize: 15.0))
          ),

          new Center(
              child:Container(
                  height: 300.0,
                  child: new ListView(
                      scrollDirection:Axis.horizontal,
                      children:<Widget> [
                        new Container(
                          width:300.0,
                          color:Colors.lightBlue,
                        ),
                        new Container(
                          width:300.0,
                          color:Colors.deepOrangeAccent,
                        ),
                        new Container(
                          width:300.0,
                          color:Colors.redAccent,
                        ),
                        new Container(
                          width:300.0,
                          color:Colors.greenAccent,
                        ),
                        new Container(
                          width:300.0,
                          color:Colors.amber,
                        ),
                        new Container(
                          width:300.0,
                          color:Colors.green,
                        ),
                        new Container(
                          width:300.0,
                          color:Colors.purple,
                        ),
                        new Container(
                          width:300.0,
                          color:Colors.black,
                        ),
                      ]
                  )
              )
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

  _navigateToSecondScreen(BuildContext context) async{

    final result = await Navigator.push(
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



class InterconnectedScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){


    return Scaffold(
        appBar:AppBar(title:Text('choose the details you want...')),
        body:Center(
            child:
            Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: <Widget>[
                  Positioned(
                      bottom:200.0,
                      left:200.0,
                      child:RouteButtonToStressAnalysis()
                  ),
                  Positioned(
                      bottom:250.0,
                      left:200.0,
                      child:RouteButtonToHeartRateAnalysis()
                  ),

                  Positioned(
                      bottom:300.0,
                      left:200.0,
                      child:RouteButtonToOverallAnalysis()
                  ),
                ]
            )
        )
    );

  }
}




class RouteButtonToStressAnalysis extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:(){
        _navigateToStressAnalysis(context);
      },
      child: Text('Stress Analysis',style: TextStyle(fontSize: 20.0)),
    );
  }

  _navigateToStressAnalysis(BuildContext context) async{

    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context)=> StressScreen())
    );

  }
}


class RouteButtonToHeartRateAnalysis extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:(){
        _navigateToHeartRateAnalysis(context);
      },
      child: Text('Heart rate analysis',style: TextStyle(fontSize: 20.0)),
    );
  }

  _navigateToHeartRateAnalysis(BuildContext context) async{

    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context)=> HeartRateScreen())
    );

  }
}


class RouteButtonToOverallAnalysis extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:(){
        _navigateToOverallAnalysis(context);
      },
      child: Text('Overall analysis',style: TextStyle(fontSize: 20.0)),
    );
  }

  _navigateToOverallAnalysis(BuildContext context) async{

    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context)=> OverallScreen())
    );

  }
}


class StressScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){


    return Scaffold(
        appBar:AppBar(title:Text('Your Stress Analysis')),
        body:Center(
            child:
            Text('Chart of stress analysis is supposed to be placed here')
        )
    );

  }
}


class HeartRateScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){


    return Scaffold(
        appBar:AppBar(title:Text('Your Heart Rate Analysis')),
        body:Center(
            child:
            Text('Chart of heart rate analysis is supposed to be placed here')
        )
    );

  }
}



class OverallScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){


    return Scaffold(
        appBar:AppBar(title:Text('Your overall Analysis')),
        body:Center(
            child:
            Text('Chart of overall analysis is supposed to be placed here')
        )
    );

  }
}


class RouteButtonToInterconnectedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:(){
        _navigateToInterConnectedScreen(context);
      },
      child: Text('See more details'), //this allows the user to see enlarged pictures for more details
    );
  }

  _navigateToInterConnectedScreen(BuildContext context) async{

    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context)=> InterconnectedScreen())
    );

  }
}