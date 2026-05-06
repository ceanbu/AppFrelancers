import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workflex/core/constants/app_colors.dart';
import 'package:workflex/core/constants/app_text_styles.dart';
import 'package:workflex/features/profile/presentation/screens/freelancer_profile_screen.dart';

class JobsFeedScreen extends StatefulWidget {
  const JobsFeedScreen({super.key});

  @override
  State<JobsFeedScreen> createState() => _JobsFeedScreenState();
}

class _JobsFeedScreenState extends State<JobsFeedScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const JobsListScreen(),
    const Center(child: Text('Aplicaciones - Próximamente')),
    const FreelancerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Trabajos disponibles', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Aplicaciones'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
      ),
    );
  }
}

class JobsListScreen extends StatelessWidget {
  const JobsListScreen({super.key});

  final List<Map<String, String>> _jobs = const [
    {'title': 'Cocinero', 'company': 'Restaurante El Sazón', 'location': 'Centro'},
    {'title': 'Camarero', 'company': 'Café La Plazuela', 'location': 'Norte'},
    {'title': 'Bartender', 'company': 'Bar Mixology', 'location': 'Sur'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _jobs.length,
      itemBuilder: (context, index) {
        final job = _jobs[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(job['title']!),
            subtitle: Text('${job['company']} - ${job['location']}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/freelancer/jobs/$index'),
          ),
        );
      },
    );
  }
}
