// ignore_for_file: invalid_use_of_protected_member, prefer_typing_uninitialized_variables, prefer_const_declarations

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:maind_craft/Screen/Home.dart';

import '../main.dart';
import 'package:timezone/timezone.dart' as tz;

class MyAppController extends GetxController with WidgetsBindingObserver {
  bool isPaused = false;

  bool isLoaded = false;
  NativeAd? nativeAd;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    // appOpenAdManager.loadAd();
    Future.delayed(const Duration(seconds: 3), () async {
      maindcraft.value != {}
          ? Get.off(() =>  Home())
          : initConfig().whenComplete(() {
              maindcraft.value = json.decode(remoteConfig.getString('phonfind'));
            });
      await flutterLocalNotificationsPlugin.zonedSchedule(
        1,
        maindcraft.value['title'],
        maindcraft.value['body'],
        tz.TZDateTime.now(tz.local).add(Duration(
          hours: maindcraft.value['Time'],
        )),
        const NotificationDetails(
          // Android details
          android: AndroidNotificationDetails('', 'Main ',
              channelDescription: "ashwin",
              importance: Importance.max,
              priority: Priority.max),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
      );
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? andriod = message.notification?.android;
      if (notification != null && andriod != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
                android: AndroidNotificationDetails(channel.id, channel.name,
                    playSound: true,
                    color: Colors.blue,
                    icon: '@mipmap/ic_launcher')));
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? andriod = message.notification?.android;
      if (notification != null && andriod != null) {
        var context;
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title.toString()),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.body.toString()),
                    ],
                  ),
                ),
              );
            });
      }
    });
  }
}

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> initNotification() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
}
