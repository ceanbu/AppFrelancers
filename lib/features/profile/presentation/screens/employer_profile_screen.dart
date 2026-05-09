import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmployerProfileScreen extends StatelessWidget {
  const EmployerProfileScreen({super.key});

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
          title: const Text('Mi perfil (Empleador)'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/employer/home'),
          ),
        ),
        body: const Center(
          child: Text('Perfil del empleador - en construcción'),
        ),
      ),
    );
  }
}
