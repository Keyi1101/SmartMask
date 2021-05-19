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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Data",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xff4B4B87),
            ),
          ),
        ),
        body:
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Color(0xff4B4B87).withOpacity(.2),
                ),
                child: TabBar(
                  unselectedLabelColor: Color(0xff4B4B87),
                  indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Color(0xff4B4B87)),
                  tabs: [
                    Tab(text: "Day",),
                    Tab(text: "Weak",),
                    Tab(text: "Month"),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child:
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    buildGridCard(
                      title: "Heart Rate",
                      color: Color(0xffff6968),
                      lable1: '120 ',//need to read from aws
                      lable2: 'bpm',
                    ),

                    buildGridCard(
                      title: "Temperature",
                      color: Color(0xff7A54FF),
                      lable1: ' 37 ',//need to read from aws
                      lable2: 'degree',
                    ),
                    buildGridCard(
                      title: "Movement status:",
                      color: Color(0xffFF8F61),
                      lable1: 'Run',// need to read from aws
                      lable2: '',
                    ),
                    buildGridCard(
                      title: "Blood Oxygen",
                      color: Color(0xff2AC3FF),
                      lable1: '',//read from aws
                      lable2: '',
                    ),
                    buildGridCard(
                      title: "Battery",
                      color: Color(0xff8AC3FF),
                      lable1: '100',
                      lable2: '%',
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async{
            await localNotificationManager.showNotification();
          },
          child: Icon(Icons.notifications),
        ),
      ),
    );

  }

  Widget buildGridCard({
    String title,
    String lable1,
    String lable2,
    Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white60,
                  ),
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    Text(
                      lable1,
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      lable2,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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