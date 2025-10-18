

import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../res/app_url.dart';
import 'package:http/http.dart' as http;

// Define the background message handler as a top-level function
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}
class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;


  Future<String?> initNOtification()async{
    await _firebaseMessaging.requestPermission();
    final fCMToken = await  _firebaseMessaging.getToken();
    return fCMToken;
  }

  Future<void> storeToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userID = preferences.getString('userID');
    String? fcmToken = await FirebaseApi().initNOtification();
    final url = Uri.parse(AppUrl.storeToken);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "id": int.parse(userID.toString()),
          "token": fcmToken,
        }),
      );
  }

  final _androidChannel = const AndroidNotificationChannel(

    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications',
    importance: Importance.max,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();
  Future initLocalNotifications() async {
    const darwin = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
    const settings = InitializationSettings(android: android, iOS: darwin);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final Map<String, dynamic> messageData = jsonDecode(response.payload!);
          final message = RemoteMessage.fromMap(messageData);
        }
      },
    );

    final platform = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    // FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    // FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@drawable/ic_launcher',
            sound: RawResourceAndroidNotificationSound('msgsound'),
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
    });
  }

}