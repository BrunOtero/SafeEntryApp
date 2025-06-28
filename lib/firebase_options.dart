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
        throw UnsupportedError(
          'iOS não está configurado. Configure no Firebase Console se necessário.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'SUA_CHAVE_WEB',
    appId: 'SEU_APP_ID_WEB',
    messagingSenderId: 'SENDER_ID',
    projectId: 'SEU_PROJETO_ID',
    authDomain: 'SEU_DOMINIO.firebaseapp.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'SUA_CHAVE_ANDROID',
    appId: 'SEU_APP_ID_ANDROID',
    messagingSenderId: 'SENDER_ID',
    projectId: 'SEU_PROJETO_ID',
    storageBucket: 'SEU_BUCKET.appspot.com',
  );
}
