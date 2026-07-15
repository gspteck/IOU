// -----------------------------------------------------------------------------
// IMPORTANT: This is a placeholder file.
// Run `flutterfire configure` (after installing FlutterFire CLI) to generate
// the real firebase_options.dart for your Firebase project.
//
// 1. Install FlutterFire CLI if needed:
//    dart pub global activate flutterfire_cli
//
// 2. Run:
//    flutterfire configure
//
// 3. Replace this file with the generated one (it will contain your real
//    FirebaseOptions for Android/iOS/etc).
//
// Without the real configuration, Firebase will not initialize and Google
// Sign-In + Realtime Database will not work.
// -----------------------------------------------------------------------------

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  // These values are placeholders. Replace the entire file with the output of
  // `flutterfire configure`.

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCZnhJmin8qlHP6mRT2WHPt7kgt9P3tBow',
    appId: '1:1039241873041:android:9fcd1ddce1e09b26622130',
    messagingSenderId: '1039241873041',
    projectId: 'iou-app-10f17',
    storageBucket: 'iou-app-10f17.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCX2pTbpEtYyrdGX93jDzVlg-vc4wH3z4o',
    appId: '1:1039241873041:ios:969d3942e029a23f622130',
    messagingSenderId: '1039241873041',
    projectId: 'iou-app-10f17',
    storageBucket: 'iou-app-10f17.firebasestorage.app',
    iosBundleId: 'com.gspteck.iou',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCX2pTbpEtYyrdGX93jDzVlg-vc4wH3z4o',
    appId: '1:1039241873041:ios:969d3942e029a23f622130',
    messagingSenderId: '1039241873041',
    projectId: 'iou-app-10f17',
    storageBucket: 'iou-app-10f17.firebasestorage.app',
    iosBundleId: 'com.gspteck.iou',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDCChox7iK5eAPKKc1T6mxm6qszwraXnqg',
    appId: '1:1039241873041:web:a5d543bfe75d7c19622130',
    messagingSenderId: '1039241873041',
    projectId: 'iou-app-10f17',
    authDomain: 'iou-app-10f17.firebaseapp.com',
    storageBucket: 'iou-app-10f17.firebasestorage.app',
    measurementId: 'G-VH2G4GLEY4',
  );
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDCChox7iK5eAPKKc1T6mxm6qszwraXnqg',
    appId: '1:1039241873041:web:f30cdf7fcd45fae1622130',
    messagingSenderId: '1039241873041',
    projectId: 'iou-app-10f17',
    authDomain: 'iou-app-10f17.firebaseapp.com',
    storageBucket: 'iou-app-10f17.firebasestorage.app',
    measurementId: 'G-349EDTXNQZ',
  );
}
