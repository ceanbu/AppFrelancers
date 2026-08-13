import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workflex/core/constants/app_colors.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  final String? _freelancerId = FirebaseAuth.instance.currentUser?.uid;

  Stream<QuerySnapshot> _streamByStatus(String status) {
    return FirebaseFirestore.instance
        .collection('applications')
        .where('freelancerId', isEqualTo: _freelancerId)
        .where('status', isEqualTo: status)
        .orderBy('appliedAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Postulaciones'),
          backgroundColor: AppColors.surface,
          elevation: 0,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'En Revisión'),
              Tab(text: 'Contactado'),
              Tab(text: 'Descartado'),
              Tab(text: 'Cerrada'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ApplicationsList(stream: _streamByStatus('pending')),
            _ApplicationsList(stream: _streamByStatus('contacted')),
            _ApplicationsList(stream: _streamByStatus('discarded')),
            _ApplicationsList(stream: _streamByStatus('closed')),
          ],
        ),
      ),
    );
  }
}

class _ApplicationsList extends StatelessWidget {
  final Stream<QuerySnapshot> stream;
  const _ApplicationsList({required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: AppColors.textSecondary),
                SizedBox(height: 16),
                Text('No hay postulaciones aquí',
                    style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return _ApplicationCard(applicationData: data);
          },
        );
      },
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final Map<String, dynamic> applicationData;
  const _ApplicationCard({required this.applicationData});

  @override
  Widget build(BuildContext context) {
    final vacancyId = applicationData['vacancyId'] as String? ?? '';
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('vacancies').doc(vacancyId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (!snapshot.data!.exists) {
          return const SizedBox.shrink();
        }
        final vacancy = snapshot.data!.data() as Map<String, dynamic>;
        final appliedAt = applicationData['appliedAt'];
        String dateStr = '';
        if (appliedAt is Timestamp) {
          final dt = appliedAt.toDate();
          dateStr = '${dt.day}/${dt.month}/${dt.year}';
        }
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vacancy['jobTitle'] ?? 'Sin título',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                if ((vacancy['remuneration'] ?? '').toString().isNotEmpty)
                  Text('Remuneración: ${vacancy['remuneration']} ${vacancy['remunerationUnit'] ?? ''}',
                      style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                if (dateStr.isNotEmpty)
                  Text('Postulado el $dateStr',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }
}