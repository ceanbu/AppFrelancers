import 'package:flutter/material.dart';

// TODO: Implementar ApplicantsScreen
class ApplicantsScreen extends StatelessWidget {
  final String vacancyId;
  const ApplicantsScreen({super.key, required this.vacancyId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Postulantes')),
      body: Center(child: Text('vacancyId: $vacancyId')),
    );
  }
}
