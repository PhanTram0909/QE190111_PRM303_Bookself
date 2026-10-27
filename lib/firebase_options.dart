// File generated / configured for PRM393 BookShelf project.
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDVUB4JaId7Q2B5F9xxQOz3KA5n2cSGcJk',
    appId: '1:592154773482:web:e95a61b5bce35d9bde1493',
    messagingSenderId: '592154773482',
    projectId: 'bookshelf-prm393-4f26c',
    authDomain: 'bookshelf-prm393-4f26c.firebaseapp.com',
    storageBucket: 'bookshelf-prm393-4f26c.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDVUB4JaId7Q2B5F9xxQOz3KA5n2cSGcJk',
    appId: '1:592154773482:android:e95a61b5bce35d9bde1493',
    messagingSenderId: '592154773482',
    projectId: 'bookshelf-prm393-4f26c',
    storageBucket: 'bookshelf-prm393-4f26c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDVUB4JaId7Q2B5F9xxQOz3KA5n2cSGcJk',
    appId: '1:592154773482:ios:e95a61b5bce35d9bde1493',
    messagingSenderId: '592154773482',
    projectId: 'bookshelf-prm393-4f26c',
    storageBucket: 'bookshelf-prm393-4f26c.firebasestorage.app',
    iosBundleId: 'com.example.bookshelf',
  );
}
