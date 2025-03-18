import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
          apiKey: "AIzaSyCrZZTJ_33zKkue-xa80q37L74fnKmbT24",
          authDomain: "mamawallet-cee0b.firebaseapp.com",
          databaseURL: "https://mamawallet-cee0b-default-rtdb.firebaseio.com",
          projectId: "mamawallet-cee0b",
          storageBucket: "mamawallet-cee0b.firebasestorage.app",
          messagingSenderId: "869499843828",
          appId: "1:869499843828:web:e77dbbafa717522c8f9aa1",
          measurementId: "G-TBK9TG9N36");
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: "AIzaSyCrZZTJ_33zKkue-xa80q37L74fnKmbT24",
          projectId: "mamawallet-cee0b",
          storageBucket: "mamawallet-cee0b.firebasestorage.app",
          messagingSenderId: "869499843828",
          appId: "1:869499843828:android:e77dbbafa717522c8f9aa1",
        );
      case TargetPlatform.iOS:
        return const FirebaseOptions(
          apiKey: "AIzaSyCrZZTJ_33zKkue-xa80q37L74fnKmbT24",
          projectId: "mamawallet-cee0b",
          storageBucket: "mamawallet-cee0b.firebasestorage.app",
          messagingSenderId: "869499843828",
          appId: "1:869499843828:ios:e77dbbafa717522c8f9aa1",
        );
      case TargetPlatform.macOS:
        return const FirebaseOptions(
          apiKey: 'AIzaSyBt64FmRosQeyTMIjN1Ak17HphehY7CUxU',
          appId: '1:112772621264:macos:d4e8f9b8b8b8b8b8b8b8b8',
          messagingSenderId: '112772621264',
          projectId: 'appw-d3b63',
          storageBucket: 'appw-d3b63.appspot.com',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}
