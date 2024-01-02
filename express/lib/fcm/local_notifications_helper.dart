import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'deeplink_handler.dart';

//Data
const channelName = "Express Notifications";
const channelDescription = "This channel is used for application";

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
late NotificationAppLaunchDetails? notificationAppLaunchDetails;

Future<void> initLocalNotifications(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');

  var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentSound: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        handleIncomingPayload(payload);
      });
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    onDidReceiveBackgroundNotificationResponse: myBackgroundNotificationHandler,
    onDidReceiveNotificationResponse: myBackgroundNotificationHandler
  );
}

  myBackgroundNotificationHandler(NotificationResponse notificationResponse){
    //TODO replace onSelectNotification look for changelog in pub.dev
    if (notificationResponse.payload != null) {
      debugPrint('local notification payload: ${notificationResponse.payload}');
      handleIncomingPayload(notificationResponse.payload);
    }
  }

void handleIncomingPayload(String? payload) {
  if(payload == null) return;
  Map? map = json.decode(payload);

  DeepLinkHandler.navigate(map!);
}

void sendLocalNotifications(String? title, String? body, String? payload) async {
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      "high_importance_channel", channelName, channelDescription: channelDescription,
      icon: "@mipmap/ic_launcher",
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      ticker: 'ticker');
  var iOSPlatformChannelSpecifics = const DarwinNotificationDetails(
    presentAlert: true,
    presentSound: true,
    presentBadge: true,
  );
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      Random().nextInt(1000), title, body, platformChannelSpecifics,
      payload: payload);
}

