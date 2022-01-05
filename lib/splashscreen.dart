
import 'package:alarmproject/widgets/graph.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class Splash extends StatefulWidget {
  @override
  SplashState createState() => new SplashState();
}

class SplashState extends State<Splash>{
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //await prefs.setBool('seen', false);
    bool _seen = prefs.getBool('seen')!;
    print(_seen);
    await new Future.delayed(const Duration(seconds: 2));
    if (_seen == false) {
      Navigator.of(context).push(
          new MaterialPageRoute(builder: (context) => new Home(index: 0,)));
    } else {
      Navigator.of(context).push(
          new MaterialPageRoute(builder: (context) => new Graph(fromNotifikasi: false,)));
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkFirstSeen();

  }

  // @override
  // void afterFirstLayout(BuildContext context) => checkFirstSeen();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: new Text('Loading...'),
      ),

    );

  }
}