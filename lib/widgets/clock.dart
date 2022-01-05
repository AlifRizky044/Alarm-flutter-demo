import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:alarmproject/configuration/config.dart';
import 'package:alarmproject/models/alarmmodels.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/alarmapi.dart';
import '../api/notificationapi.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class Clock extends StatefulWidget{
  Clock({Key? key}) : super(key: key);
  State<Clock> createState() => _clockState();

}

class _clockState extends State<Clock> {
  TextEditingController controller = TextEditingController();
  DateTime _dateTime = DateTime.now();
  var arrWaktuAlarm;
  bool _time = true;
  Timer? _clock;
  bool _aturJam = false;
  List<List<double>> jamXY = [];
  int _jam = 0;
  int _menit = 0;
  bool _ubahJam = true;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();

    _clock!.cancel();
  }
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _clock = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _dateTime = DateTime.now();
        if(_aturJam == false){
          _jam = _dateTime.hour;
          _menit = _dateTime.minute;
        }
      });
    });
    setState(() {
      _dateTime = DateTime.now();
      _time = _dateTime.hour > 12;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(25)),
            child: AspectRatio(
              aspectRatio: 1,
              child: Transform.rotate(
                angle: -pi/2,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return GestureDetector(
                      onPanUpdate: (details){
                        if(_ubahJam){
                          setState(() {
                            jamXY =_calculateOffset(constraints.maxHeight, constraints.maxWidth);
                          });
                          _panHandler(details, jamXY);
                        }else{
                          setState(() {
                            jamXY =_calculateOffsetMinute(constraints.maxHeight, constraints.maxWidth);
                          });
                          _panHandlerMinute(details, jamXY);
                        }
                      },
                      onPanEnd: (details){
                        setState(() {
                          if(_ubahJam){
                            _ubahJam = false;
                          }else{
                            _ubahJam=true;
                          }
                        });
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.lightBlue,
                            shape: BoxShape.circle,

                          ),
                          child:CustomPaint(
                              painter: ClockRender(context,_dateTime,_aturJam,_jam,_menit),
                            ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("AM",style: TextStyle(fontSize: 30),),
                Switch(
                  value: _time,
                  onChanged: (value) {
                    setState(() {
                      _time = value;
                    });
                  },
                  inactiveTrackColor: Colors.deepOrangeAccent,
                  activeTrackColor: Colors.blueAccent,
                  activeColor: Colors.white54,
                ),
                Text("PM",style: TextStyle(fontSize: 30),),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                  onHorizontalDragUpdate: (details){
                    int sensitivity = 1;
                    if (details.delta.dx > sensitivity) {
                      setState(() {
                        _aturJam = true;
                        if(_menit > 0){
                          _menit = _menit - 1;
                          if(_menit <= -1) _menit = 0;
                        }
                        else {
                          _menit = 59;
                        }
                      });
                      print("kiri");
                    } else if(details.delta.dx < -sensitivity){
                      setState(() {
                        _aturJam = true;
                        if(_menit < 60){
                          _menit = _menit + 1;
                          if(_menit == 60) _menit = 0;
                        }
                        else {
                          _menit = 0;
                        }
                      });
                      print("kanan");
                    }
                  },
                  onVerticalDragUpdate: (details){
                    int sensitivity = 1;
                    if (details.delta.dy > sensitivity) {
                      setState(() {
                        _aturJam = true;
                        if(_jam > 0){
                          _jam = _jam - 1;
                        }
                        else {
                          _jam = 23;
                        }
                      });
                      print("bawah");
                    } else if(details.delta.dy < -sensitivity){
                      setState(() {

                        _aturJam = true;
                        if(_jam < 24){
                          _jam = _jam + 1;
                          if(_jam == 24) _jam = 0;
                        }
                        else {
                          _jam = 0;
                        }
                      });
                      print("atas");
                    }
                  },
                  child: Text(_jam.toString().padLeft(2, '0')+":"+_menit.toString().padLeft(2, '0'),style: TextStyle(fontSize: 50),)),

              FloatingActionButton.extended(
                onPressed: () {
                  openDialog(context, controller);
                },
                label: const Text('Tambah Alarm'),
                icon: const Icon(Icons.add),
                backgroundColor: Colors.pink,
              ),
            ],
          ),
          TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            ),
            onPressed: () async{
              _aturJam = false;
            },
            child: Text('Reset Jam'),
          ),
          //await prefs.setBool('seen', false);
        ],
      ),
    );

  }


  List<List<double>> _calculateOffset(double height, double width){
    double centerX=width/2;
    double centerY=height/2;
    List<double> hourX = [];
    List<double> hourY = [];
    for(int i=1;i<=12;i++){
      hourX.add(centerX + width * 0.45 * cos((i * 30) * pi / 180));
      hourY.add(centerY + height * 0.45 * sin((i * 30) * pi / 180));
    }
    return [hourX,hourY];
  }
  void _panHandler(DragUpdateDetails details,List<List<double>> jamXY) {
    for(int i=0;i<12;i++){
      if(Jam(details,jamXY[0][i],jamXY[1][i],i+1).checkKolisi() == true){
        setState(() {
          _aturJam = true;
          if(_time == true){
            _jam = i+1+12;
            if(_jam == 24) _jam = 0;
          }else{
            _jam = i+1;
          }
        });
        break;
      }
    }
  }

  List<List<double>> _calculateOffsetMinute(double height, double width){
    double centerX=width/2;
    double centerY=height/2;
    List<double> minuteX = [];
    List<double> minuteY = [];

    for(int i=1;i<=60;i++){
      minuteX.add(centerX + width * 0.45 * cos((i * 6) * pi / 180));
      minuteY.add(centerY + width * 0.45 * sin((i * 6) * pi / 180));
    }
    return [minuteX,minuteY];
  }

  Future openDialog(BuildContext context, TextEditingController controller){
    String jamAlarm = (_jam == 0?24:_jam).toString().padLeft(2, '0')+":"+_menit.toString().padLeft(2, '0');
    String jamAlarmETC = _jam.toString().padLeft(2, '0')+":"+_menit.toString().padLeft(2, '0');
    return showDialog(
      context:context,
      builder:(buildercontext){
        return AlertDialog(
          title: Text("Alarm pada jam "+jamAlarmETC+" :"),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: "Masukkan Kegiatan Anda"),
          ),
          actions: [
            TextButton(
                onPressed: (){
                  controller.text = "";
                  Navigator.of(context).pop();
                }, child: Text("Keluar")),
            TextButton(
                onPressed: () async{
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String? musicsString = await prefs.getString('musics_key');
                  List<Alarm> musics = [];
                  if(musicsString != null){
                    musics = Alarm.decode(musicsString);
                  }
                  // Encode and store data in SharedPreferences
                  int helloAlarmID = musics.length+1;
                  musics.add(Alarm(waktu: jamAlarmETC, status: "true",kegiatan: controller.text,alarmID: helloAlarmID));

                  String encodedData = Alarm.encode(musics);
                  print("ini"+controller.text);
                  await prefs.setString('musics_key', encodedData);
                  await prefs.setString("keyKegiatan", controller.text);
                  await prefs.reload();
                  var format = DateFormat("HH:mm");
                  var one = format.parse((_dateTime.hour==0?24:_dateTime.hour).toString()+":"+_dateTime.minute.toString());
                  var two = format.parse(jamAlarm);

                  setState(() {
                    if(one.compareTo(two) == 1){
                      var a = two.difference(one).toString().split(':');
                      var perbedaan = format.parse("24:00").subtract(Duration(hours:  int.parse(a[0]).abs(),minutes: int.parse(a[1]).abs()));
                      arrWaktuAlarm = format.parse(perbedaan.hour.toString()+":"+perbedaan.minute.toString()).toString().split(':');
                    }else if(one.toString() == two.toString() && one.compareTo(two) == 0){
                      arrWaktuAlarm = ["24","0"];
                    }else if(one.compareTo(two) == -1){
                      arrWaktuAlarm = two.difference(one).toString().split(':');
                    }
                    //two.add(Duration(hours: 0,minutes: 0))
                  });

                  AlarmAPI(controller.text,true).hidupAlarm(helloAlarmID,int.parse(arrWaktuAlarm[0]),int.parse(arrWaktuAlarm[1]));

                  controller.text = "";

                  SnackBar snackBar = SnackBar(
                    content: Text('Alarm Terpasang untuk '+arrWaktuAlarm[0].toString()+" jam dan "+arrWaktuAlarm[1].toString()+" menit kedepan."),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  Navigator.of(context).pop();
                }, child: Text("Pasang Alarm")),
          ],
        );
      }
    );
  }
  void _panHandlerMinute(DragUpdateDetails details,List<List<double>> menitXY){
    for(int i=0;i<60;i++){
      if(Menit(details,menitXY[0][i],menitXY[1][i],i+1).checkKolisi() == true){
        setState(() {
          _aturJam = true;
          _menit = i+1;
          if(_menit == 60) _menit = 0;
        });
        break;
      }
    }
  }
}

class Menit{
  DragUpdateDetails details;
  double MenitX;
  double MenitY;
  int nomor;
  Menit(this.details, this.MenitX, this.MenitY,this.nomor);
  bool checkKolisi(){
    if((details.localPosition.dx <= MenitX + 30 && details.localPosition.dx >= MenitX - 30) && (details.localPosition.dy <= MenitY + 5 && details.localPosition.dy >= MenitY - 5)){
      return true;
    }
    return false;
  }
}
class Jam{
  DragUpdateDetails details;
  double JamX;
  double JamY;
  int nomor;
  Jam(this.details, this.JamX, this.JamY,this.nomor);
  bool checkKolisi(){
    if((details.localPosition.dx <= JamX + 30 && details.localPosition.dx >= JamX - 30) && (details.localPosition.dy <= JamY + 5 && details.localPosition.dy >= JamY - 5)){
      return true;
    }
    return false;
  }
}


class ClockRender extends CustomPainter{
  final BuildContext context;
  final DateTime _dateTime;
  final bool _aturJam;
  int _jam;
  int _menit;

  ClockRender(this.context, this._dateTime, this._aturJam, this._jam, this._menit);
  @override
  void paint(Canvas canvas, Size size) {
    double centerX=size.width/2;
    double centerY=size.height/2;
    Offset center = Offset(centerX,centerY);
    int menit = 0;
    int _detik = 0;

    if(_aturJam == false){
      menit = _dateTime.minute;
      _jam = _dateTime.hour;
      _menit = _dateTime.minute;
      _detik = _dateTime.second;
    }

    //menit
    double minX = centerX + size.width * 0.35 * cos((_menit * 6) * pi / 180);
    double minY = centerY + size.width * 0.35 * sin((_menit * 6) * pi / 180);

    canvas.drawLine(center,Offset(minX,minY), Paint()..color=Colors.red..style=PaintingStyle.stroke..strokeWidth=8);

    //jam
    double hourX = centerX + size.width * 0.3 * cos((_jam * 30 + menit * 0.5) * pi / 180);
    double hourY = centerY + size.width * 0.3 * sin((_jam * 30 + menit * 0.5) * pi / 180);

    canvas.drawLine(center,Offset(hourX,hourY), Paint()..color=Colors.green..style=PaintingStyle.stroke..strokeWidth=10);

    //detik
    double secondX = centerX + size.width * 0.4 * cos((_detik * 6) * pi / 180);
    double secondY = centerY + size.width * 0.4 * sin((_detik * 6) * pi / 180);

    canvas.drawLine(center,Offset(secondX,secondY), Paint()..color=Theme.of(context).primaryColor..style=PaintingStyle.stroke..strokeWidth=3);

    Paint dotPointer = Paint()..color=Theme.of(context).primaryIconTheme.color!;

    for(int i = 1;i<13;i++){
      double hourXLine = centerX + size.width * 0.45 * cos((i * 30) * pi / 180);
      double hourYLine = centerY + size.width * 0.45 * sin((i * 30) * pi / 180);
      double hourXLine2 = centerX + size.width * 0.5 * cos((i * 30) * pi / 180);
      double hourYLine2 = centerY + size.width * 0.5 * sin((i * 30) * pi / 180);
      canvas.drawLine(Offset(hourXLine,hourYLine),Offset(hourXLine2,hourYLine2), Paint()..color=Theme.of(context).colorScheme.secondary..style=PaintingStyle.stroke..strokeWidth=5);
    }
    //
    // double hourXLine2 = centerX + size.width * 0.3 * cos((2 * 30) * pi / 180);
    // double hourYLine2 = centerY + size.width * 0.3 * sin((2 * 30) * pi / 180);
    // canvas.drawCircle(Offset(hourXLine2,hourYLine2), 24, dotPointer);
    canvas.drawCircle(center, 24, dotPointer);
    canvas.drawCircle(center, 22, Paint()..color=Theme.of(context).backgroundColor);
    canvas.drawCircle(center, 10, dotPointer);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}
