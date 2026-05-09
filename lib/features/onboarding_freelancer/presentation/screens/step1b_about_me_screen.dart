import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutMeScreen extends StatelessWidget {
  const AboutMeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre mi')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, size: 64, color: Color(0xFF61758A)),
            const SizedBox(height: 16),
            const Text('Contanos algo de vos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('En construccion', style: TextStyle(color: Color(0xFF61758A))),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/freelancer/register/step2'),
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}