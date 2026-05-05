import 'package:flutter/material.dart';

class ApplicantsListScreen extends StatelessWidget {
  final String vacancyId;
  const ApplicantsListScreen({super.key, required this.vacancyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Postulantes')),
      body: Center(
        child: Text('Postulantes para la vacante  - en construcción'),
      ),
    );
  }
}
