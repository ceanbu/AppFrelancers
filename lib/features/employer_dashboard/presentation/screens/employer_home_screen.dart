import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:workflex/core/constants/app_colors.dart';
import 'package:workflex/core/constants/app_text_styles.dart';
import 'employer_profile_screen.dart';

class EmployerHomeScreen extends StatefulWidget {
  const EmployerHomeScreen({super.key});

  @override
  State<EmployerHomeScreen> createState() => _EmployerHomeScreenState();
}

class _EmployerHomeScreenState extends State<EmployerHomeScreen> {
  int _selectedIndex = 0;
  late Stream<QuerySnapshot> _vacanciesStream;
  String? _employerId;

  @override
  void initState() {
    super.initState();
    _employerId = FirebaseAuth.instance.currentUser?.uid;
    if (_employerId != null) {
      _vacanciesStream = FirebaseFirestore.instance
          .collection('vacancies')
          .where('employerId', isEqualTo: _employerId)
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_employerId == null) {
      return const Scaffold(body: Center(child: Text('No autenticado')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildVacanciesList(),
          const EmployerProfileScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/employer/vacancy/create/step1'),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: AppColors.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () => setState(() => _selectedIndex = 0),
              icon: Icon(Icons.home, color: _selectedIndex == 0 ? AppColors.primary : AppColors.textSecondary),
            ),
            const SizedBox(width: 48), // espacio para el FAB
            IconButton(
              onPressed: () => setState(() => _selectedIndex = 1),
              icon: Icon(Icons.person, color: _selectedIndex == 1 ? AppColors.primary : AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVacanciesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _vacanciesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No has publicado vacantes aún.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/employer/vacancy/create/step1'),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text('Crear primera vacante'),
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'open';
            Color statusColor;
            String statusText;
            switch (status) {
              case 'open':
                statusColor = Colors.green;
                statusText = 'Abierta';
                break;
              case 'paused':
                statusColor = Colors.orange;
                statusText = 'Pausada';
                break;
              case 'filled':
                statusColor = Colors.blue;
                statusText = 'Cubierta';
                break;
              default:
                statusColor = Colors.grey;
                statusText = 'Cerrada';
            }
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(data['jobTitle'] ?? 'Sin título'),
                subtitle: Text('Postulantes: ${data['applicantCount'] ?? 0}'),
                trailing: Chip(
                  label: Text(statusText),
                  backgroundColor: statusColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: statusColor),
                ),
                onTap: () => context.go('/employer/vacancy/${doc.id}'),
              ),
            );
          },
        );
      },
    );
  }
}

