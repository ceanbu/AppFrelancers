import 'package:flutter/material.dart';

class EmployerProfileScreen extends StatelessWidget {
  const EmployerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil (Empleador)')),
      body: const Center(
        child: Text('Perfil del empleador - en construcción'),
      ),
    );
  }
}
