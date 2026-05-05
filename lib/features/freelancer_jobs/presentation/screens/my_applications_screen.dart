import 'package:flutter/material.dart';

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis postulaciones')),
      body: const Center(
        child: Text('Historial de postulaciones (en construcción)'),
      ),
    );
  }
}
