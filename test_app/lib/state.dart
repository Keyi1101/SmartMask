import 'package:flutter/material.dart';
import 'package:test_app/model/product.dart';
import 'LocalNotificationManager.dart';
import 'model/create_item.dart';
import 'model/get_list.dart';

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

  onNotificationReceive(ReceiveNotification notification) {
    print('Notification Received:${notification.id}');
  }

  onNotificationClick(String payload) {
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
            'Data',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xff4B4B87),
            ),
          ),
          bottom: TabBar(
            indicatorColor: Colors.blue,
            labelColor: Colors.black,
            tabs: <Widget>[
              Tab(text: 'Real-Time'),
              Tab(
                text: 'Past-Data',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
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
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      children: [
                        //buildGridCard(
                        //  title: "Heart Rate",
                        //  color: Color(0xffff6968),
                        //  lable1: '120 ',//need to read from aws
                        //  lable2: 'bpm',
                        //),

                        Container(
                          child: Column(children: [
                            Text('                 ',
                                style:TextStyle(fontSize: 12.0)),
                            Text('Heartrate               ',
                                style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: Colors.white,),),
                            Text('          ',
                                style:TextStyle(fontSize: 25.0)),
                            FutureBuilder(
                              future: getProducts(),
                              builder: (BuildContext context, AsyncSnapshot snapshot) {
                                return Text("    "+
                                    snapshot.data[snapshot.data.length-1].heartrate + " bpm",
                                  style: TextStyle(fontSize: 30.0,fontWeight: FontWeight.bold,color: Colors.white,),); //update real heartrate
                              })
                            ]
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.pinkAccent,
                          ),
                        ),

                        //buildGridCard(
                        //  title: "Temperature",
                        //  color: Color(0xff7A54FF),
                        //  lable1: ' 37 ', //need to read from aws
                        //  lable2: 'degree',
                        //),

                        Container(
                          child: Column(children: [
                            Text('                 ',
                                style:TextStyle(fontSize: 12.0)),
                            Text('Temperature          ',
                                style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: Colors.white,),),
                            Text('          ',
                                style:TextStyle(fontSize: 25.0)),
                            FutureBuilder(
                              future: getProducts(),
                              builder: (BuildContext context,
                                AsyncSnapshot snapshot) {
                                return Text("  "+snapshot.data[snapshot.data.length-1].temperature + " degree",
                                  style: TextStyle(fontSize: 30.0,fontWeight: FontWeight.bold,color: Colors.white,),); //update real heartrate
                              })
                            ]
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Color(0xff7A54FF),
                          ),
                        ),

                        //buildGridCard(
                        //  title: "Movement status:",
                        //  color: Color(0xffFF8F61),
                        //  lable1: 'Run', // need to read from aws
                        //  lable2: '',
                        //),

                        Container(
                          child: Column(children: [
                            Text('                 ',
                                style:TextStyle(fontSize: 12.0)),
                            Text('Movement status ',
                                style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: Colors.white,),),
                            Text('          ',
                                style:TextStyle(fontSize: 25.0)),
                            FutureBuilder(
                              future: getProducts(),
                              builder: (BuildContext context,
                                AsyncSnapshot snapshot) {
                                return Text("  "+snapshot.data[snapshot.data.length-1].movement + "",
                                  style: TextStyle(fontSize: 40.0,fontWeight: FontWeight.bold,color: Colors.white,),); //update real heartrate
                              })
                            ]
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Color(0xffFF8F61),
                          ),
                        ),

                        //buildGridCard(
                        //  title: "Blood Oxygen",
                        //  color: Color(0xff2AC3FF),
                        //  lable1: '', //read from aws
                        //  lable2: '',
                        //),

                        Container(
                          child: Column(children: [
                            Text('                 ',
                                style:TextStyle(fontSize: 12.0)),
                            Text('Blood Oxygen Conc.',
                                style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: Colors.white,),),
                            Text('          ',
                                style:TextStyle(fontSize: 25.0)),
                            FutureBuilder(
                              future: getProducts(),
                              builder: (BuildContext context,
                                AsyncSnapshot snapshot) {
                                return Text("    "+snapshot.data[snapshot.data.length-1].oxygenconc + "",
                                  style: TextStyle(fontSize: 35.0,fontWeight: FontWeight.bold,color: Colors.white,),); //update real heartrate
                              })
                            ]
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Color(0xff2AC3FF),
                          ),
                        ),


                        buildGridCard(
                          title: "Battery",
                          color: Colors.greenAccent,
                          lable1: '100',
                          lable2: '%',
                        ),
                        Container(
                          child: RouteButton(),
                          //  child: FutureBuilder(
                          //    future: getProducts(),
                          //    builder: (BuildContext context, AsyncSnapshot snapshot){
                          //      return Text(snapshot.data[0].movement);
                          //    }
                          // ),
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
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      children: [
                        Container(
                          child: RouteButtonToHeartRateAnalysis(),
                        ),
                        Container(
                          child: RouteButtonToStressAnalysis(),
                        ),
                        Container(
                          child: RouteButtonToMovementHistory(),
                        ),
                        Container(
                          child: RouteButtonToBodyTemp(),
                        ),
                        buildGridCard(
                          title: "Battery",
                          color: Colors.greenAccent,
                          lable1: '100',
                          lable2: '%',
                        ),
                        Container(
                          child: RouteButton(),
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
          onPressed: () async {
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
      onPressed: () {
        _navigateToSecondScreen(context);
      },
      child: Text(
        'Mode Choose',
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
      ), //text to be read from aws
      style: ElevatedButton.styleFrom(
        primary: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  _navigateToSecondScreen(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => SecondScreen()));

    Scaffold.of(context).showSnackBar(SnackBar(content: Text('$result')));
  }
}

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('change strategy of detection')),
        body: Center(
            child: Row(children: <Widget>[
          Container(
            height: 810.0,
            width: 196.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Color(0xff4B4B87).withOpacity(.2),
            ),
            child: ElevatedButton(
              child: Text('Fast', style: TextStyle(fontSize: 20.0)),
              style: ElevatedButton.styleFrom(
                primary: Colors.deepOrangeAccent,
              ),
              onPressed: () {
                Navigator.pop(context, 'Mode set to: High update frequency');
              },
            ),
          ),
          Container(
            height: 810.0,
            width: 196.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Color(0xff4B4B87).withOpacity(.2),
            ),
            child: ElevatedButton(
              child: Text('Slow', style: TextStyle(fontSize: 20.0)),
              style: ElevatedButton.styleFrom(
                primary: Colors.lightBlueAccent,
              ),
              onPressed: () {
                Navigator.pop(context, 'Mode set to: Slow update frequency');
              },
            ),
          )
        ])));
  }
}

class RouteButtonToStressAnalysis extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _navigateToStressAnalysis(context);
      },
      child: Text('Your Stress Analysis',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
          primary: Color(0xFF7CB0E5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          )),
    );
  }

  _navigateToStressAnalysis(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => StressScreen()));
  }
}

class RouteButtonToHeartRateAnalysis extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _navigateToHeartRateAnalysis(context);
      },
      child: Text('Your Heart Rate Analysis',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
          primary: Color(0xffff6968),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          )),
    );
  }

  _navigateToHeartRateAnalysis(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => HeartRateScreen()));
  }
}

class RouteButtonToMovementHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _navigateToMovementHistory(context);
      },
      child: Text('Your Movement History',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
          primary: Colors.indigoAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          )),
    );
  }

  _navigateToMovementHistory(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => MovementScreen()));
  }
}

class RouteButtonToBodyTemp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _navigateToBodyTemp(context);
      },
      child: Text('Your Body Temperature History',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
          primary: Color(0xffFF8F61),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          )),
    );
  }

  _navigateToBodyTemp(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => BodyTempScreen()));
  }
}

class StressScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Your Stress Analysis')),
        body: Center(
            child: Text(
                'Chart of stress analysis is supposed to be placed here')));
  }
}

class HeartRateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Your Heart Rate Analysis')),
        body: Center(child: Text('chart of heart rate analysis')));
  }
}

class MovementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Your Movement History')),
        body: Center(
            child: Text(
                'Chart of movement history is supposed to be placed here')));
  }
}

class BodyTempScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Your Body Temperature History')),
        body: Center(
          child:
              Text('Chart of body temp history is supposed to be placed here'),
        ));
  }
}
