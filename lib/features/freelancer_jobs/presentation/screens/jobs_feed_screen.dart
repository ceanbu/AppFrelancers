import 'package:flutter/material.dart';

class JobsFeedScreen extends StatelessWidget {
  const JobsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trabajos disponibles')),
      body: const Center(
        child: Text('Feed de vacantes (en construcción)'),
      ),
    );
  }
}
