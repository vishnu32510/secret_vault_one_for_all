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
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB6DIFOFX-kaIv-h1yNeFOzlHroVS55hlE',
    appId: '1:561878597833:web:caf55909cdb4b957638d18',
    messagingSenderId: '561878597833',
    projectId: 'secret-vault-one-for-all',
    authDomain: 'secret-vault-one-for-all.firebaseapp.com',
    storageBucket: 'secret-vault-one-for-all.firebasestorage.app',
    measurementId: 'G-07R7FMVRCS',
  );

  // TODO: Replace with values from `flutterfire configure`.

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAbr_6nfl2N2YKxcB3J-GbYxA8VagbCy0I',
    appId: '1:561878597833:android:d1139e8b83222985638d18',
    messagingSenderId: '561878597833',
    projectId: 'secret-vault-one-for-all',
    storageBucket: 'secret-vault-one-for-all.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBGKvq43142aUyby5RO9c78GN8ZSMhidq8',
    appId: '1:561878597833:ios:a63804eba5871aeb638d18',
    messagingSenderId: '561878597833',
    projectId: 'secret-vault-one-for-all',
    storageBucket: 'secret-vault-one-for-all.firebasestorage.app',
    iosBundleId: 'com.nungu.secretvaultoneforall',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBGKvq43142aUyby5RO9c78GN8ZSMhidq8',
    appId: '1:561878597833:ios:a63804eba5871aeb638d18',
    messagingSenderId: '561878597833',
    projectId: 'secret-vault-one-for-all',
    storageBucket: 'secret-vault-one-for-all.firebasestorage.app',
    iosBundleId: 'com.nungu.secretvaultoneforall',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB6DIFOFX-kaIv-h1yNeFOzlHroVS55hlE',
    appId: '1:561878597833:web:bef37d3881845b22638d18',
    messagingSenderId: '561878597833',
    projectId: 'secret-vault-one-for-all',
    authDomain: 'secret-vault-one-for-all.firebaseapp.com',
    storageBucket: 'secret-vault-one-for-all.firebasestorage.app',
    measurementId: 'G-4FZKEBZEYF',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    authDomain: 'REPLACE_ME.firebaseapp.com',
    storageBucket: 'REPLACE_ME.firebasestorage.app',
  );
}