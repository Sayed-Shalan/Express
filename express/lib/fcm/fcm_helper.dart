import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';
import 'deeplink_handler.dart';
import 'local_notifications_helper.dart';

class FCMHelper {
  ///Single-instance
  static final FCMHelper _singleton = FCMHelper._internal();

  factory FCMHelper() {
    return _singleton;
  }

  FCMHelper._internal();

  requestFCMIOSPermissions() async {
    ///IOS Permissions
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
        alert: true, // Required to display a heads up notification
        badge: true,
        sound: true);
    debugPrint('User granted permission: ${settings.authorizationStatus}');

    ///ANDROID
    ///Using flutter local screens.company_home.tabs.notifications to create a channel and assign fcm screens.company_home.tabs.notifications to this channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        channelName, // title
        description: channelDescription, // description
        importance: Importance.max);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<String?> getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    debugPrint("FCM TOKEN IS $token");
    return token;
  }

  void initRemoteMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null && initialMessage.notification != null) {
      debugPrint('Got a message from terminated state!');
      DeepLinkHandler.navigate(initialMessage.data);
    }
  }

  void onMessageReceived() {
    // Get any messages which caused the application to open from
    // a foreground state.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        // if (message.data.containsKey(Constants.type) &&
        //     message.data[Constants.type] == NotificationTypes.chat) {
        //   if (chatRoomOpened && message.data[Constants.itemUUID] == roomOtherPartUUID) return;
        // }

        String? body = notification.body;
        debugPrint('Message data Body: $body');

        debugPrint('Notification: ${notification.toMap()}');
        sendLocalNotifications(
            notification.title,
            body,
            json.encode(message.data));
      }

    });

    // Get any messages which caused the application to open from
    // a background state.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in user clicks a notification');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
            'Message also contained a notification: ${message.notification}');
        DeepLinkHandler.navigate(message.data);
      }
    });
  }

  onTokenChange() {
    FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) async {
    });
  }


}
