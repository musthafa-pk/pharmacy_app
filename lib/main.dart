import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmacy_app/Constants/appColors.dart';
import 'package:pharmacy_app/api/firebase_api.dart';
import 'package:pharmacy_app/api/localNotificationService.dart';
import 'package:pharmacy_app/views/medOne/editRoutine.dart';
import 'package:pharmacy_app/views/splash1.dart';

import 'firebase_options.dart';

// Background message handler (runs when the app is terminated or in the background)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler); // Register background handler
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
  await FirebaseApi().initNOtification();
  await FirebaseApi().initLocalNotifications();
  await FirebaseApi().initPushNotifications();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  void _toggleTheme(bool isDarkMode) {
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pharmacy App',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'AeonikTRIAL',
        scaffoldBackgroundColor: TextColorWhite,
      ),
      // home: EditDailyRoutine(),
      home: Splash1(),
    );
  }
}
