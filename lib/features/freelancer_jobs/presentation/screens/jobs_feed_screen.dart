import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:workflex/core/constants/app_colors.dart';
import 'package:workflex/core/constants/app_text_styles.dart';

class JobsFeedScreen extends StatefulWidget {
  const JobsFeedScreen({super.key});

  @override
  State<JobsFeedScreen> createState() => _JobsFeedScreenState();
}

class _JobsFeedScreenState extends State<JobsFeedScreen> {
  late Future<_FreelancerMatchProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadFreelancerProfile();
  }

  Future<_FreelancerMatchProfile> _loadFreelancerProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return _FreelancerMatchProfile(skills: [], state: '', municipality: '', availability: {});
    }
    final doc = await FirebaseFirestore.instance.collection('freelancers').doc(uid).get();
    final data = doc.data() ?? {};
    final address = (data['address'] as Map<String, dynamic>?) ?? {};
    return _FreelancerMatchProfile(
      skills: List<String>.from(data['skills'] ?? []),
      state: (address['state'] ?? '').toString(),
      municipality: (address['municipality'] ?? '').toString(),
      availability: (data['availability'] as Map<String, dynamic>?) ?? {},
    );
  }

  int _timeToMinutes(dynamic hhmm) {
    if (hhmm == null) return -1;
    final parts = hhmm.toString().split(':');
    if (parts.length != 2) return -1;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return h * 60 + m;
  }

  bool _hasScheduleOverlap(Map<String, dynamic> vacancySchedule, Map<String, dynamic> freelancerAvailability) {
    for (final day in vacancySchedule.keys) {
      if (!freelancerAvailability.containsKey(day)) continue;
      final vacancyRanges = (vacancySchedule[day] as List?) ?? [];
      final freelancerRanges = (freelancerAvailability[day] as List?) ?? [];
      for (final vr in vacancyRanges) {
        final vStart = _timeToMinutes(vr['startTime'] ?? vr['start']);
        final vEnd = _timeToMinutes(vr['endTime'] ?? vr['end']);
        if (vStart < 0 || vEnd < 0) continue;
        for (final fr in freelancerRanges) {
          final fStart = _timeToMinutes(fr['startTime'] ?? fr['start']);
          final fEnd = _timeToMinutes(fr['endTime'] ?? fr['end']);
          if (fStart < 0 || fEnd < 0) continue;
          if (vStart < fEnd && fStart < vEnd) return true;
        }
      }
    }
    return false;
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
      body: FutureBuilder<_FreelancerMatchProfile>(
        future: _profileFuture,
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = profileSnapshot.data ??
              _FreelancerMatchProfile(skills: [], state: '', municipality: '', availability: {});

          if (profile.state.isEmpty || profile.municipality.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Completa tu direccion en tu perfil para ver vacantes cerca tuyo.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            );
          }

          final vacanciesStream = FirebaseFirestore.instance
              .collection('vacancies')
              .where('status', isEqualTo: 'open')
              .where('workAddress.state', isEqualTo: profile.state)
              .where('workAddress.municipality', isEqualTo: profile.municipality)
              .snapshots();

          return StreamBuilder<QuerySnapshot>(
            stream: vacanciesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final docs = snapshot.data?.docs ?? [];

              final filteredDocs = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final requiredSkills = List<String>.from(data['requiredSkills'] ?? []);
                final hasSkillMatch = requiredSkills.any((s) => profile.skills.contains(s));
                if (!hasSkillMatch) return false;

                final vacancySchedule = (data['schedule'] as Map<String, dynamic>?) ?? {};
                return _hasScheduleOverlap(vacancySchedule, profile.availability);
              }).toList();

              if (filteredDocs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No hay vacantes cerca tuyo que coincidan con tus habilidades y disponibilidad.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: filteredDocs.length,
                itemBuilder: (context, index) {
                  final doc = filteredDocs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final remuneration = (data['remuneration'] ?? '').toString();
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(data['jobTitle'] ?? ''),
                      subtitle: Text(
                        remuneration.isNotEmpty
                            ? '$remuneration ${data['remunerationUnit'] ?? ''}'
                            : 'A convenir',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/freelancer/jobs/${doc.id}'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _FreelancerMatchProfile {
  final List<String> skills;
  final String state;
  final String municipality;
  final Map<String, dynamic> availability;
  _FreelancerMatchProfile({
    required this.skills,
    required this.state,
    required this.municipality,
    required this.availability,
  });
}