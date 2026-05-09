import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:workflex/core/constants/app_colors.dart';
import 'package:workflex/core/constants/app_text_styles.dart';

class EmployerProfileScreen extends StatelessWidget {
  const EmployerProfileScreen({super.key});
  void _goToHome(BuildContext context) { if (context.mounted) { context.go('/employer/home'); } }
  @override Widget build(BuildContext context) { final user = FirebaseAuth.instance.currentUser; if (user == null) return const Center(child: Text('No autenticado')); return PopScope(canPop: false, onPopInvoked: (didPop) async { if (didPop) return; _goToHome(context); }, child: Scaffold( backgroundColor: AppColors.background, appBar: AppBar( title: const Text('Mi Perfil'), backgroundColor: AppColors.surface, elevation: 0, leading: IconButton( icon: const Icon(Icons.arrow_back), onPressed: () => _goToHome(context), ), ), body: FutureBuilder<DocumentSnapshot>( future: FirebaseFirestore.instance.collection('employers').doc(user.uid).get(), builder: (context, snapshot) { if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator()); if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}')); if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: Text('Perfil no encontrado')); final data = snapshot.data!.data() as Map<String, dynamic>; return SingleChildScrollView( padding: const EdgeInsets.all(16), child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [ Card( child: Padding( padding: const EdgeInsets.all(16), child: Column( children: [ _buildInfoRow('Nombre del negocio', data['businessName'] ?? ''), _buildDivider(), _buildInfoRow('Email', data['email'] ?? ''), _buildDivider(), _buildInfoRow('Tipo', data['businessType'] ?? ''), _buildDivider(), _buildInfoRow('Créditos', data['credits']?.toString() ?? '0'), ], ), ), ), const SizedBox(height: 24), Center( child: ElevatedButton.icon( onPressed: () async { await FirebaseAuth.instance.signOut(); if (context.mounted) context.go('/'); }, icon: const Icon(Icons.logout), label: const Text('Cerrar sesión'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), ), ), ], ), ); }, ), ), ); }
  Widget _buildInfoRow(String label, String value) { return Padding( padding: const EdgeInsets.symmetric(vertical: 4), child: Row( children: [ SizedBox(width: 120, child: Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary))), Expanded(child: Text(value, style: AppTextStyles.bodyMedium)), ], ), ); }
  Widget _buildDivider() => const Divider(height: 16);
}
