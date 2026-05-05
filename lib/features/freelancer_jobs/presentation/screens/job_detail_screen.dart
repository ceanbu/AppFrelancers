import 'package:flutter/material.dart';

class JobDetailScreen extends StatelessWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de vacante')),
      body: Center(
        child: Text('Detalle del trabajo  - en construcción'),
      ),
    );
  }
}
