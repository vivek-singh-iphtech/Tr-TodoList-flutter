import 'dart:async';
import 'dart:developer';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCM {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void requestNotificartionPermissions() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true, //app indicator
      carPlay: true,
      criticalAlert: true,
      provisional: true, //to choose turn off or on notification
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('user granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('user granted provisional permission');
    } else {
      print("permission denied");
    }
  }

  void initLocalNotification(RemoteMessage message) async {
    var androidIntialization =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var intializationSettings = InitializationSettings(
      android: androidIntialization,
    );

    await _flutterLocalNotificationsPlugin.initialize(intializationSettings,
        onDidReceiveNotificationResponse: (payload) {});
  }

//show notification when app is active
  void FirebaseInit() {
    FirebaseMessaging.onMessage.listen((message) {
      print(message.notification!.title.toString());
      print(message.notification!.body.toString());
      initLocalNotification(message);
      showNotification(message);
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationDetails channel = AndroidNotificationDetails(
        Random.secure().nextInt(1000000).toString(),
        'High Importance Notifications',
        importance: Importance.max);

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.channelId.toString(),
      channel.channelName.toString(),
      channelDescription: "Your channel description",
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    Future.delayed(
        Duration.zero,(){
        _flutterLocalNotificationsPlugin.show(
            0,
            message.notification!.title.toString(),
            message.notification!.body.toString(),
            notificationDetails);});
  }

//generate device token
  Future<String> getDeviceToken() async {
    String? Token = await messaging.getToken();
    return Token!;
  }

//check if token expire
  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }
}
