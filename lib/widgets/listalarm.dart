import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/alarmapi.dart';
import '../models/alarmmodels.dart';

class ListAlarm extends StatefulWidget{
  State<ListAlarm> createState() => _listAlarm();
}

class _listAlarm extends State<ListAlarm>{
  List<Alarm>? user;
  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    getData();
  }
  Future<Null> getData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? musicsString = await prefs.getString('musics_key');
    List<Alarm> musics;
    if(musicsString == null){
      musics = [];
    }else{
      musics = Alarm.decode(musicsString);
    }

    setState(() {
      user = musics;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(user != null){
      return ListView.builder(
          itemCount: user!.length,
          itemBuilder: (context,index){
            return Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user![index].waktu!,style: TextStyle(fontSize: 30),),
                            Text(user![index].kegiatan!,style: TextStyle(fontSize: 15),),
                          ],
                        ),
                      ),

                      // Switch(
                      //   value: user![index].status! == "true",
                      //   onChanged: (value) async{
                      //     setState(() {
                      //
                      //       user![index].status = value.toString();
                      //       // print(user![index].status);
                      //     });
                      //     SharedPreferences prefs = await SharedPreferences.getInstance();
                      //     await prefs.setString("keyKegiatan", user![index].kegiatan!);
                      //     if(value == true){
                      //       DateTime _dateTime = DateTime.now();
                      //       var format = DateFormat("HH:mm");
                      //       var one = format.parse((_dateTime.hour==0?24:_dateTime.hour).toString()+":"+_dateTime.minute.toString());
                      //       var two = format.parse(user![index].waktu!);
                      //       var arrWaktuAlarm;
                      //       setState(() {
                      //         if(one.compareTo(two) == 1){
                      //           var a = two.difference(one).toString().split(':');
                      //           var perbedaan = format.parse("24:00").subtract(Duration(hours:  int.parse(a[0]).abs(),minutes: int.parse(a[1]).abs()));
                      //           arrWaktuAlarm = format.parse(perbedaan.hour.toString()+":"+perbedaan.minute.toString()).toString().split(':');
                      //         }else if(one.toString() == two.toString() && one.compareTo(two) == 0){
                      //           arrWaktuAlarm = ["24","0"];
                      //         }else if(one.compareTo(two) == -1){
                      //           arrWaktuAlarm = two.difference(one).toString().split(':');
                      //         }
                      //         //two.add(Duration(hours: 0,minutes: 0))
                      //       });
                      //       AlarmAPI(user![index].kegiatan!,true).hidupAlarm(user![index].alarmID!,int.parse(arrWaktuAlarm[0]),int.parse(arrWaktuAlarm[1]));
                      //       print("alarm terpasang");
                      //     }
                      //     else{
                      //       AlarmAPI(user![index].kegiatan!,false).cancelAlarm(user![index].alarmID!);
                      //       print("Alarm Mati");
                      //     }
                      //   },
                      //   activeTrackColor: Colors.lightGreenAccent,
                      //   activeColor: Colors.green,
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(left:10.0),
                        child: IconButton(
                          onPressed: () async{
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            AlarmAPI(user![index].kegiatan!,false).cancelAlarm(user![index].alarmID!);
                            print("Alarm Mati");
                            setState(() {
                              user!..removeAt(index);
                            });


                            final String encodedData = Alarm.encode(user!);

                            await prefs.setString('musics_key', encodedData);
                          },
                          icon: Icon(Icons. clear),
                        ),
                      ),
                    ],
                  ),
                )
            );
          }
      );
    }else{
      return Text("");
    }

  }

}