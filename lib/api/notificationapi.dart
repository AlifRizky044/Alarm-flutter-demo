import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;



class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  static final onNotifications = BehaviorSubject<String?>();
  static int count = 0;
  GlobalKey<NavigatorState>? navigatorKey;
  factory NotificationService() {
    return _notificationService;
  }


  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> initNotification() async {
    final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS
    );

    final details = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if(details != null && details.didNotificationLaunchApp){
      onNotifications.add(details.payload);
    }

    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (payload) async{
      onNotifications.add(payload);
    });
  }

  Future<dynamic> onSelectNotification(payload) async {
// navigate to booking screen if the payload equal BOOKING
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen', true);
    // if(payload == "BOOKING"){
    //
    //   // await Future.delayed(const Duration(seconds: 2));
    //   await navigatorKey!.currentState!.pushAndRemoveUntil(
    //     MaterialPageRoute(builder: (context) => MyApp()),
    //         (Route<dynamic> route) => false,
    //   );
    // }
  }
  Future<void> showNotification(int id, String title, String body, int seconds) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
            'main_channel7',
            'Main Channel7',
            channelDescription: 'Main channel notifications',
            playSound: true,
            sound: RawResourceAndroidNotificationSound('notif'),
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher'
        ),
        iOS: IOSNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      payload: "BOOKING"
    );
  }


  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}