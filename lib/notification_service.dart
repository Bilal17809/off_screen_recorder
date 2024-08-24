//
//
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:overlay_support/overlay_support.dart';
//
// class NotificationService {
//   static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   static Future<void> initialize() async {
//     final AndroidInitializationSettings androidInitializationSettings =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     final InitializationSettings initializationSettings =
//     InitializationSettings(android: androidInitializationSettings);
//
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }
//
//   static Future<void> showNotification() async {
//     print("Notification is being shown");
//
//     const AndroidNotificationDetails androidPlatformChannelSpecifics=
//     AndroidNotificationDetails(
//       '12345',
//       'khan ',
//       importance: Importance.max,
//       priority: Priority.high,
//       largeIcon: DrawableResourceAndroidBitmap('download'),
//     );
//
//     const NotificationDetails platformChannelSpecifics =
//     NotificationDetails(android: androidPlatformChannelSpecifics);
//
//     await flutterLocalNotificationsPlugin.show(
//       0, // notification id
//       'Offscreen Video Recorder',
//       'Start Video Recording',
//       platformChannelSpecifics,
//     );
//   }
// }
//
//
// class NotificationService2 {
//   static Future<void> showNotification() async {
//     print("Notification is being shown");
//
//     showSimpleNotification(
//       Text('Offscreen Video Recorder'),
//       background: Colors.green, // Customize background color if needed
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';
class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    final AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
    InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  // video notification....
  static Future<void> showNotification() async {
    print("Notification is being shown");

    const AndroidNotificationChannel androidNotificationChannel =
    AndroidNotificationChannel(
      '12345', // channel ID
      'Video Recording Channel',
      importance: Importance.high,
    );

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      '12345', // channel ID
      'khan',
      channelDescription: 'Video recording channel',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true, // Set this to true to make the notification persistent
      largeIcon: DrawableResourceAndroidBitmap('download'),
    );

    final NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);

    await flutterLocalNotificationsPlugin.show(
      0, // notification id
      'Offscreen Video Recorder',
      'Start Video Recording',
      platformChannelSpecifics,
    );
  }
  // audio notifications
  static Future<void> showAudioNotification() async {
    print("Notification is being shown");

    const AndroidNotificationChannel androidNotificationChannel =
    AndroidNotificationChannel(
      '12345', // channel ID
      'Video Recording Channel',
      importance: Importance.high,
    );

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      '12345', // channel ID
      'khan',
      channelDescription: 'Video recording channel',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true, // Set this to true to make the notification persistent
      largeIcon: DrawableResourceAndroidBitmap('download'),
    );

    final NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);

    await flutterLocalNotificationsPlugin.show(
      0, // notification id
      'Audio recording',
      'Audio Recording',
      platformChannelSpecifics,
    );
  }
  static Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }
}
