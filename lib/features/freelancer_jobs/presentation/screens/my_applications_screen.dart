import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workflex/core/constants/app_colors.dart';
import 'package:workflex/core/constants/app_text_styles.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String uid;
  late Stream<QuerySnapshot> _pendingStream;
  late Stream<QuerySnapshot> _contactedStream;
  late Stream<QuerySnapshot> _discardedStream;
  late Stream<QuerySnapshot> _closedStream;

  final List<String> _statusTabs = ['pending', 'contacted', 'discarded', 'closed'];
  final Map<String, String> _tabLabels = {
    'pending': 'En revisión',
    'contacted': 'Contactado',
    'discarded': 'Descartado',
    'closed': 'Cerrada',
  };

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    _tabController = TabController(length: _statusTabs.length, vsync: this);

    _pendingStream = FirebaseFirestore.instance
        .collection('applications')
        .where('freelancerId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('appliedAt', descending: true)
        .snapshots();

    _contactedStream = FirebaseFirestore.instance
        .collection('applications')
        .where('freelancerId', isEqualTo: uid)
        .where('status', isEqualTo: 'contacted')
        .orderBy('appliedAt', descending: true)
        .snapshots();

    _discardedStream = FirebaseFirestore.instance
        .collection('applications')
        .where('freelancerId', isEqualTo: uid)
        .where('status', isEqualTo: 'discarded')
        .orderBy('appliedAt', descending: true)
        .snapshots();

    _closedStream = FirebaseFirestore.instance
        .collection('applications')
        .where('freelancerId', isEqualTo: uid)
        .where('status', isEqualTo: 'closed')
        .orderBy('appliedAt', descending: true)
        .snapshots();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (uid.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No autenticado')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Mis postulaciones', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: _statusTabs
              .map((status) => Tab(text: _tabLabels[status]))
              .toList(),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApplicationsList(_pendingStream, 'pending'),
          _buildApplicationsList(_contactedStream, 'contacted'),
          _buildApplicationsList(_discardedStream, 'discarded'),
          _buildApplicationsList(_closedStream, 'closed'),
        ],
      ),
    );
  }

  Widget _buildApplicationsList(Stream<QuerySnapshot> stream, String status) {
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
          return Center(
            child: Text(
              'No hay postulaciones en "${_tabLabels[status]}"',
              style: AppTextStyles.bodyMedium,
            ),
          );
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final appliedAt = (data['appliedAt'] as Timestamp).toDate();
            final vacancyId = data['vacantId'] as String;
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('vacancies')
                  .doc(vacancyId)
                  .get(),
              builder: (context, vacancySnap) {
                String jobTitle = 'Cargando...';
                if (vacancySnap.hasData && vacancySnap.data!.exists) {
                  jobTitle = vacancySnap.data!['jobTitle'] ?? 'Sin título';
                }
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(jobTitle, style: AppTextStyles.titleMedium),
                    subtitle: Text(
                      'Postulado: ${_formatDate(appliedAt)}',
                      style: AppTextStyles.bodySmall,
                    ),
                    trailing: _buildStatusIcon(status),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return const Icon(Icons.hourglass_empty, color: Colors.orange);
      case 'contacted':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'discarded':
        return const Icon(Icons.cancel, color: Colors.red);
      case 'closed':
        return const Icon(Icons.lock, color: Colors.grey);
      default:
        return const Icon(Icons.help);
    }
  }
}