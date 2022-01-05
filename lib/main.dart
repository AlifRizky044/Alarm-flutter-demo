import 'dart:isolate';

import 'package:alarmproject/configuration/theme.dart';
import 'package:alarmproject/widgets/clock.dart';
import 'package:flutter/material.dart';
import 'package:alarmproject/widgets/changetheme.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'configuration/config.dart';
import 'widgets/graph.dart';
import 'widgets/listalarm.dart';
import 'models/graphmodels.dart';
import 'api/notificationapi.dart';
import 'package:timezone/data/latest.dart' as tz;


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().cancelAllNotifications();
  runApp(MyApp());
}

final navKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator");


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
  NotificationService().navigatorKey = navigatorKey;
    return ChangeNotifierProvider(
        create: (context) => MyThemeModel(),
        child: Consumer<MyThemeModel>(
          builder: (context, theme, child) => MaterialApp(
            navigatorKey: navKey,
            debugShowCheckedModeBanner: false,
            title: 'Analog Clock',
            theme: themeData(context),
            darkTheme: darkThemeData(context),
            themeMode: theme.isLightTheme ? ThemeMode.light : ThemeMode.dark,
            //home: Splash(),
            home: Home(index: 0,),
          ),
        )
    );
  }
}

class Home extends StatefulWidget {
  Home({Key? key, required this.index}) : super(key: key);
  int index;
  String tes = "nothing";

  State<Home> createState() => _homeState();

}
class _homeState extends State<Home> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {

    // TODO: implement initState
    super.initState();
    listenNotifications();
    NotificationService().initNotification();

  }
  void listenNotifications(){
    NotificationService.onNotifications.stream.listen((event) {onClickNotification(event);});
  }
  void onClickNotification(String? payload) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    // await prefs.setBool('seen', true);
    List<String> timeNotifList = await prefs.getStringList('notifikasiAktif')!;
    String kegiatanNotif = await prefs.getString('notifikasiKegiatan')!;
    DateTime _dateTime = DateTime.now();
    int timeNotif = int.parse(timeNotifList[0]) == 0?24:int.parse(timeNotifList[0]) * 3600 + int.parse(timeNotifList[1]) * 60 + int.parse(timeNotifList[2]);
    int timeClickNotif = _dateTime.hour == 0?24:_dateTime.hour * 3600 + _dateTime.minute * 60 + _dateTime.second;
    int diff;
    if(timeNotif > timeClickNotif){
      diff = (timeClickNotif+86400)-timeNotif-4;
    }else{
      diff =  timeClickNotif - timeNotif-4;
    }
    print(diff);
    print("jalan ini");
    String? graphData = await prefs.getString('graphdata');
    List<graphModel> listGraph;
    if(graphData == null){
      listGraph = [];
    }else{
      listGraph = graphModel.decode(graphData);
      if(listGraph.length > 8){
        listGraph = [];
      }
    }
    // Encode and store data in SharedPreferences
    listGraph.add(graphModel(delay: diff,namaAlarm: kegiatanNotif));

    String encodedData = graphModel.encode(listGraph);

    await prefs.setString('graphdata', encodedData);

    await navKey.currentState!.push(MaterialPageRoute(builder: (context) => Graph(fromNotifikasi: true,)));
    //Navigator.push(context, MaterialPageRoute(builder: (context) => Graph()),);
  }
  @override
  Widget build(BuildContext context) {
    final screens = [
      Clock(),
      Graph(fromNotifikasi: false),
      ListAlarm()
    ];
    print(widget.index);
    if(widget.index == 2){

    }
    SizeConfig().init(context);
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Flutter Alarm" ,style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.amber[800],
      ),
        body: SafeArea(
        child: screens[widget.index],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Tambah Alarm',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Grafik Alarm',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'List Alarm',
            ),
          ],
          currentIndex: widget.index,
          selectedItemColor: Colors.amber[800],
          onTap: (i){
            setState(() {
              widget.index = i;
            });
          },
        )
    );
  }

}
