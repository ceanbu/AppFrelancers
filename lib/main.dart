import 'package:flutter/material.dart';
import 'package:jobbit/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkFlex', // As per DRS RF1.1 (App Name)
      theme: ThemeData(
        primarySwatch: Colors.blue, // Standard Flutter blue
        // You can customize the theme further here based on WorkFlex branding
        // For example, using colors from the HTML mockup:
        // primaryColor: const Color(0xFF359DFF), // Button color from mockup
        // scaffoldBackgroundColor: const Color(0xFFF8FAFC), // bg-slate-50
        // textTheme: TextTheme(
        //   displayLarge: TextStyle(fontFamily: 'Inter'), // or Noto Sans
        // ),
        // inputDecorationTheme: const InputDecorationTheme(
        //   border: OutlineInputBorder(),
        // ),
      ),
      home: const LoginScreen(), // Set LoginScreen as the initial screen
      // TODO: Define routes for navigation if not using direct Navigator.push
      // routes: {
      //   '/login': (context) => const LoginScreen(),
      //   '/role_selection': (context) => const RoleSelectionScreen(),
      //   // ... other routes
      // },
    );
  }
}
