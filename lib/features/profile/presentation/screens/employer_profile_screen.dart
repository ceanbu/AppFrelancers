import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmployerProfileScreen extends StatelessWidget {
  const EmployerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil Empleador')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.business, size: 64, color: Color(0xFF61758A)),
            const SizedBox(height: 16),
            const Text('Perfil del Empleador', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('En construccion', style: TextStyle(color: Color(0xFF61758A))),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesion'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}