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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAfwgDZyNuKlYvY3ojuV0DNdvsFw3-9SNI',
    appId: '1:824730752907:android:e07df52746d670c71b018e',
    messagingSenderId: '824730752907',
    projectId: 'workflex-app-9d2cc',
    storageBucket: 'workflex-app-9d2cc.firebasestorage.app',
  );

  // ⚠️ REEMPLAZAR con valores reales de FlutterFire CLI
}