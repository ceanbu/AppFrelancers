// IMPORTANTE: Este archivo es generado automáticamente por FlutterFire CLI
// Ejecutá: flutterfire configure
// Este es un placeholder — reemplazalo con el archivo generado real

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web no soportado en V1.7');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Plataforma no soportada: $defaultTargetPlatform',
        );
    }
  }

  // ⚠️ REEMPLAZAR con valores reales de FlutterFire CLI
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'TU_API_KEY',
    appId: 'TU_APP_ID',
    messagingSenderId: 'TU_SENDER_ID',
    projectId: 'TU_PROJECT_ID',
    storageBucket: 'TU_STORAGE_BUCKET',
  );
}
