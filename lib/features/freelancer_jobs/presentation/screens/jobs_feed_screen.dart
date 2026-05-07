import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:workflex/core/constants/app_colors.dart';
import 'package:workflex/core/constants/app_text_styles.dart';
import 'package:workflex/features/profile/presentation/screens/freelancer_profile_screen.dart';
import 'job_detail_screen.dart';
import 'my_applications_screen.dart';

class JobsFeedScreen extends StatefulWidget {
  const JobsFeedScreen({super.key});

  @override
  State<JobsFeedScreen> createState() => _JobsFeedScreenState();
}

class _JobsFeedScreenState extends State<JobsFeedScreen> {
  int _selectedIndex = 0;
  late Future<List<String>> _freelancerSkills;
  late Stream<QuerySnapshot> _vacanciesStream;

  @override
  void initState() {
    super.initState();
    _loadFreelancerSkills();
  }

  void _loadFreelancerSkills() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _freelancerSkills = Future.value([]);
      _vacanciesStream = Stream.empty();
      return;
    }
    _freelancerSkills = FirebaseFirestore.instance
        .collection('freelancers')
        .doc(uid)
        .get()
        .then((doc) => List<String>.from(doc.data()?['skills'] ?? []));

    _vacanciesStream = FirebaseFirestore.instance
        .collection('vacancies')
        .where('status', isEqualTo: 'open')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Trabajos disponibles', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: _selectedIndex == 0
          ? FutureBuilder<List<String>>(
              future: _freelancerSkills,
              builder: (context, skillsSnapshot) {
                if (skillsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final freelancerSkills = skillsSnapshot.data ?? [];
                return StreamBuilder<QuerySnapshot>(
                  stream: _vacanciesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: '));
                    }
                    final docs = snapshot.data?.docs ?? [];
                    final filteredDocs = docs.where((doc) {
                      final requiredSkills = List<String>.from(doc['requiredSkills'] ?? []);
                      return requiredSkills.any((skill) => freelancerSkills.contains(skill));
                    }).toList();

                    if (filteredDocs.isEmpty) {
                      return const Center(child: Text('No hay vacantes que coincidan con tus habilidades.'));
                    }
                    return ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final doc = filteredDocs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(data['jobTitle'] ?? ''),
                            subtitle: Text(', '),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JobDetailScreen(jobId: doc.id),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            )
          : (_selectedIndex == 1
              ? const MyApplicationsScreen()
              : const FreelancerProfileScreen()),
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
