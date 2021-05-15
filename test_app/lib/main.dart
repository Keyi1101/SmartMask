import 'package:flutter/material.dart';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';

void main(){
  runApp(MaterialApp(
    title:'SmartMaskUI',
    home:FirstScreen()
  ));
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    var stack=new Stack(
      children:<Widget> [
        new Positioned(
          bottom:20.0,
          right:10.0,
          child:RouteButton()
          ),
        new Positioned(
          bottom:0.0,
          left:240.0,
          child:new Text('Remaining Battery:')
        ),
      ]
    );

    return Scaffold(
      appBar:AppBar(title:Text("Your data")),
      body:Center(
        child: stack,
      )
    );
  }
}

//跳转的Button
class RouteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
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
        RaisedButton(
          child:Text('High update frequency',style: TextStyle(fontSize: 20.0)),
          onPressed: (){
            Navigator.pop(context,'Mode set to: High update frequency');
          },
        ), 
        RaisedButton(
          child:Text('Medium update frequency',style: TextStyle(fontSize: 20.0)),
          onPressed: (){
            Navigator.pop(context,'Mode set to: Medium update frequency');
          },
        ),
        RaisedButton(
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
