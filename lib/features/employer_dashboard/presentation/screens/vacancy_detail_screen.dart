import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VacancyDetailScreen extends StatelessWidget {
  final String vacancyId;
  const VacancyDetailScreen({super.key, required this.vacancyId});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/employer/home');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de vacante'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/employer/home'),
          ),
        ),
        body: Center(
          child: Text('Vacante ID: $vacancyId - Detalle (en construcción)'),
        ),
      ),
    );
  }
}
