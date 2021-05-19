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
      length: 2,
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
            bottom:
              TabBar(
                indicatorColor: Colors.blue,
                labelColor: Colors.black,
                tabs:<Widget> 
                [
                  Tab(text: 'Real-Time'),
                  Tab(text: 'Past-Data',),
                ],
            ),
        ),
        body:
        TabBarView(
          children:[
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
                      color: Colors.greenAccent,
                      lable1: '100',
                      lable2: '%',
                    ),
                    Container(
                      
                      child:RouteButton(),
                      
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

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
              ),
              SizedBox(height: 20),
              Expanded(
                child:
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    Container(
                      child:RouteButtonToHeartRateAnalysis(),
                    ),

                    Container(
                      child:RouteButtonToStressAnalysis(),
                    ),
                    
                    Container(
                      child:RouteButtonToMovementHistory(),
                    ),

                    Container(
                      child:RouteButtonToBodyTemp(),
                    ),
                    
                    buildGridCard(
                      title: "Battery",
                      color: Colors.greenAccent,
                      lable1: '100',
                      lable2: '%',
                    ),
                    Container(
                      
                      child:RouteButton(),
                      
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        ],
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

class RouteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:(){
        _navigateToSecondScreen(context);
      },
      child: Text('Fast Update',style: TextStyle(fontSize: 25),),//text to be read from aws
      style: ElevatedButton.styleFrom(
            primary:Colors.black, 
          ),
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






class RouteButtonToStressAnalysis extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:(){
        _navigateToStressAnalysis(context);
      },
      child: Text('Your Stress Analysis',style: TextStyle(fontSize: 20.0)),
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
      child: Text('Your Heart Rate Analysis',style: TextStyle(fontSize: 20.0)),
      style: ElevatedButton.styleFrom(
            primary:Colors.pinkAccent, 
          ),
    );
  }

  _navigateToHeartRateAnalysis(BuildContext context) async{

    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context)=> HeartRateScreen())
    );

  }
}





class RouteButtonToMovementHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:(){
        _navigateToMovementHistory(context);
      },
      child: Text('Your Movement History',style: TextStyle(fontSize: 20.0)),
      style: ElevatedButton.styleFrom(
            primary:Colors.indigoAccent, 
          ),
    );
  }

  _navigateToMovementHistory(BuildContext context) async{

    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context)=> MovementScreen())
    );

  }
}


class RouteButtonToBodyTemp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:(){
        _navigateToBodyTemp(context);
      },
      child: Text('Your Body Temperature History',style: TextStyle(fontSize: 20.0)),
      style: ElevatedButton.styleFrom(
            primary:Colors.deepOrange, 
          ),
    );
  }

  _navigateToBodyTemp(BuildContext context) async{

    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context)=> BodyTempScreen())
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



class MovementScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){


    return Scaffold(
        appBar:AppBar(title:Text('Your Movement History')),
        body:Center(
            child:
            Text('Chart of movement history is supposed to be placed here')
        )
    );
  }
}


class BodyTempScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){


    return Scaffold(
        appBar:AppBar(title:Text('Your Body Temperature History')),
        body:Center(
            child:
            Text('Chart of body temp history is supposed to be placed here'),
        )
    );
  }
}
