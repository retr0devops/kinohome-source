// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyB6btHdaMAG9exUCOvIsCOIvIl45zg_nlI',
    appId: '1:505279409519:web:7b86beaea7a4a18de8cc9a',
    messagingSenderId: '505279409519',
    projectId: 'kinohomef',
    authDomain: 'kinohomef.firebaseapp.com',
    storageBucket: 'kinohomef.appspot.com',
    measurementId: 'G-BZLLBWJLHT',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAl5EL6aCnFpTLRocEsjNY9D33w7zlr43g',
    appId: '1:505279409519:android:5ae5f29be1e2f1c9e8cc9a',
    messagingSenderId: '505279409519',
    projectId: 'kinohomef',
    storageBucket: 'kinohomef.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCG01D7b1cb5-fxTV5M2rd6p0g_y0vGLpc',
    appId: '1:505279409519:ios:93cf046267050b1de8cc9a',
    messagingSenderId: '505279409519',
    projectId: 'kinohomef',
    storageBucket: 'kinohomef.appspot.com',
    iosClientId: '505279409519-u5aq9vvk0gtlqh3dqo4moc06fpvfj8ik.apps.googleusercontent.com',
    iosBundleId: 'eu.ctwoon.kinohome',
  );
}
