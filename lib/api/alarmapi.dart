import 'dart:math';

import 'package:alarmproject/widgets/clock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import '../models/alarmmodels.dart';
import 'notificationapi.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class AlarmAPI{
  bool hidup;
  String kegiatan;
  AlarmAPI(this.kegiatan,this.hidup);
  static void alarmTest() async{
    tz.initializeTimeZones();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    String? activity = await prefs.getString("keyKegiatan");
    // final datacount = GetStorage();
    // String hasil = datacount.read('kegiatan');
    print(activity);
    await NotificationService().showNotification(1, "Alarm Menyala", activity!, 1);
    DateTime _dateTime = DateTime.now();
    await prefs.setStringList('notifikasiAktif', [_dateTime.hour.toString(),_dateTime.minute.toString(),_dateTime.second.toString()]);
    await prefs.setString('notifikasiKegiatan', activity);

  }
  static Future<void> callback(int i) async {
    alarmTest();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final String? musicsString = await prefs.getString('musics_key');
    List<Alarm> musics;
    if(musicsString == null){
      musics = [];
    }else{
      musics = Alarm.decode(musicsString);
    }
    musics..removeAt(i-1);


    String encodedData = Alarm.encode(musics);

    await prefs.setString('musics_key', encodedData);
    // tz.initializeTimeZones();
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String activitystring = prefs.getString("keyKegiatan")!;
    // print(activitystring);
    // await NotificationService().showNotification(1, "Alarm Menyala", activitystring, 1);
    // DateTime _dateTime = DateTime.now();
    // await prefs.setStringList('notifikasiAktif', [_dateTime.hour.toString(),_dateTime.minute.toString(),_dateTime.second.toString()]);
    // await prefs.setString('notifikasiKegiatan', activitystring);
    print("test");
  }
  void hidupAlarm(int helloAlarmID, int jam, int menit) async{
    await AndroidAlarmManager.initialize();
    await AndroidAlarmManager.oneShot(Duration(hours: jam, minutes: menit), helloAlarmID, callback, wakeup: true,exact: true).then((val) {
      print(val);
      //alarmTest();
    }).catchError((e)=>print(e));
  }
  void cancelAlarm(int helloAlarmID) async{
    await AndroidAlarmManager.initialize();
    await AndroidAlarmManager.cancel(helloAlarmID);
  }


}