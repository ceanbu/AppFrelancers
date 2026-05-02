import 'package:flutter/material.dart';

// TODO: Implementar JobDetailScreen
class JobDetailScreen extends StatelessWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Trabajo')),
      body: Center(child: Text('jobId: $jobId')),
    );
  }
}
