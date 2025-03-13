import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final player = AudioPlayer();

  Future<void> init() async {
    // ✅ Request permissions for Android 13+
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/app_icon');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);

    // ✅ Create Notification Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'timer_channel', // ✅ Must match the ID in the manifest
      'Timer Notifications',
      description: 'Channel for timer notifications',
      importance: Importance.high,
    );

    final androidPlatform =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidPlatform?.createNotificationChannel(channel);
  }

  Future<void> showNotification(String title, String body) async {
    print("Showing notification: $title - $body");

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'timer_channel', // ✅ Matches channel ID
          'Timer Notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          icon: '@drawable/app_icon', // ✅ Correct icon reference
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(0, title, body, platformChannelSpecifics);
    print("Notification shown successfully!");
  }

  void playAlarm() {
    player.play(AssetSource('alarm.wav'));
  }
}
