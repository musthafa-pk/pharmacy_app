// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC3AH2PTFWmeGkAosaz18omPWEhIgkKJ98',
    appId: '1:90363222372:web:b1601dca815c82beb80271',
    messagingSenderId: '90363222372',
    projectId: 'pharmacy-a8915',
    authDomain: 'pharmacy-a8915.firebaseapp.com',
    storageBucket: 'pharmacy-a8915.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBHiYorBtR7XQdW2Fv_Bx9q68idoSl39yk',
    appId: '1:90363222372:android:7e0385e43bd85195b80271',
    messagingSenderId: '90363222372',
    projectId: 'pharmacy-a8915',
    storageBucket: 'pharmacy-a8915.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAxg20EliFZ4kDk8FIeLS-aCQk9Hh1Uaww',
    appId: '1:90363222372:ios:a63851e219c92414b80271',
    messagingSenderId: '90363222372',
    projectId: 'pharmacy-a8915',
    storageBucket: 'pharmacy-a8915.firebasestorage.app',
    iosBundleId: 'com.example.pharmacy_app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAxg20EliFZ4kDk8FIeLS-aCQk9Hh1Uaww',
    appId: '1:90363222372:ios:a63851e219c92414b80271',
    messagingSenderId: '90363222372',
    projectId: 'pharmacy-a8915',
    storageBucket: 'pharmacy-a8915.firebasestorage.app',
    iosBundleId: 'com.example.pharmacy_app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC3AH2PTFWmeGkAosaz18omPWEhIgkKJ98',
    appId: '1:90363222372:web:c60a6e396636f078b80271',
    messagingSenderId: '90363222372',
    projectId: 'pharmacy-a8915',
    authDomain: 'pharmacy-a8915.firebaseapp.com',
    storageBucket: 'pharmacy-a8915.firebasestorage.app',
  );
}
