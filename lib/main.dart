import 'package:flutter/material.dart';
import 'package:jobbit/screens/login_screen.dart'; // Asegúrate que 'jobbit' sea el nombre de tu proyecto

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkFlex', // Como en el DRS RF1.1 (Nombre de la App)
      theme: ThemeData(
        primarySwatch: Colors.blue, // Azul estándar de Flutter
        // Puedes personalizar más el tema aquí basado en la marca WorkFlex
        // Por ejemplo, usando colores del mockup HTML:
        // primaryColor: const Color(0xFF359DFF), // Color de botón del mockup
        // scaffoldBackgroundColor: const Color(0xFFF8FAFC), // bg-slate-50
        fontFamily: 'Inter', // Opcional: si quieres usar Inter consistentemente
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF359DFF), // Color de acento para TextButton
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF359DFF),
            foregroundColor: Colors.white, // Texto blanco para mejor contraste
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
          ),
        ),
      ),
      home: const LoginScreen(), // Establece LoginScreen como la pantalla inicial
      debugShowCheckedModeBanner: false, // Opcional: para quitar el banner de debug
    );
  }
}