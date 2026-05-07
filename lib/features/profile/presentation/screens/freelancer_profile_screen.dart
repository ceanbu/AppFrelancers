import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:workflex/core/constants/app_colors.dart';
import 'package:workflex/core/constants/app_text_styles.dart';
import 'package:workflex/core/models/time_range.dart';
import 'edit_availability_screen.dart';

class FreelancerProfileScreen extends StatefulWidget {
  const FreelancerProfileScreen({super.key});

  @override
  State<FreelancerProfileScreen> createState() => _FreelancerProfileScreenState();
}

class _FreelancerProfileScreenState extends State<FreelancerProfileScreen> {
  late Future<DocumentSnapshot> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _userDataFuture = Future.error('No autenticado');
    } else {
      _userDataFuture = FirebaseFirestore.instance.collection('freelancers').doc(uid).get();
    }
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return '';
    if (dateValue is Timestamp) {
      return DateFormat('dd/MM/yyyy').format(dateValue.toDate());
    }
    if (dateValue is String) {
      try {
        final DateTime parsedDate = DateTime.parse(dateValue);
        return DateFormat('dd/MM/yyyy').format(parsedDate);
      } catch (e) {
        return dateValue;
      }
    }
    return '';
  }

  Future<void> _editAvailability(Map<String, dynamic> currentAvailability) async {
    // Convertir el mapa de Firestore a Map<String, List<TimeRange>>
    Map<String, List<TimeRange>> availabilityMap = {};
    if (currentAvailability != null && currentAvailability.isNotEmpty) {
      for (var entry in currentAvailability.entries) {
        final ranges = (entry.value as List).map((r) => TimeRange.tryFromJson(r)).where((r) => r != null).cast<TimeRange>().toList();
        if (ranges.isNotEmpty) {
          availabilityMap[entry.key] = ranges;
        }
      }
    }
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditAvailabilityScreen(currentAvailability: availabilityMap),
      ),
    );
    if (changed == true) {
      // Recargar los datos del perfil
      setState(() {
        _loadUserData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Mi Perfil', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) context.go('/');
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No se encontraron datos del perfil.'));
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Información personal'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoRow('Nombre completo', data['fullName'] ?? ''),
                        _buildDivider(),
                        _buildInfoRow('Email', data['email'] ?? ''),
                        _buildDivider(),
                        _buildInfoRow('Teléfono', data['phone'] ?? ''),
                        _buildDivider(),
                        _buildInfoRow('Documento', '${data['documentType'] ?? ''}: ${data['documentNumber'] ?? ''}'),
                        _buildDivider(),
                        _buildInfoRow('Fecha nacimiento', _formatDate(data['birthDate'])),
                        _buildDivider(),
                        _buildInfoRow('Sobre mí', data['aboutMe'] ?? ''),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Dirección'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoRow('Estado/Municipio', '${data['address']['state'] ?? ''} / ${data['address']['municipality'] ?? ''}'),
                        _buildDivider(),
                        _buildInfoRow('Barrio', data['address']['neighborhood'] ?? ''),
                        _buildDivider(),
                        _buildInfoRow('Calle', data['address']['street'] ?? ''),
                        _buildDivider(),
                        _buildInfoRow('Número', data['address']['number'] ?? ''),
                        if (data['address']['complement'] != null && data['address']['complement'].isNotEmpty) ...[
                          _buildDivider(),
                          _buildInfoRow('Complemento', data['address']['complement']),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Habilidades'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (data['skills'] as List? ?? []).map<Widget>((skill) => Chip(
                        label: Text(skill),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                      )).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle('Disponibilidad'),
                    TextButton.icon(
                      onPressed: () => _editAvailability(data['availability']),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Editar'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    ),
                  ],
                ),
                _buildAvailabilityCard(data['availability']),
                const SizedBox(height: 24),
                _buildSectionTitle('Experiencia laboral'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: (data['experience'] as List? ?? []).map<Widget>((exp) {
                        try {
                          final start = exp['startDate'] ?? '';
                          final end = exp['isCurrent'] ? 'Actual' : (exp['endDate'] ?? '');
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(exp['position'] ?? '', style: AppTextStyles.titleMedium),
                                Text('${exp['company']} · $start - $end', style: AppTextStyles.bodySmall),
                                if (exp['description'] != null && exp['description'].isNotEmpty)
                                  Text(exp['description'], style: AppTextStyles.bodySmall),
                                const Divider(),
                              ],
                            ),
                          );
                        } catch (e) {
                          return const SizedBox.shrink();
                        }
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvailabilityCard(dynamic availability) {
    try {
      if (availability == null || availability.isEmpty) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('No has definido disponibilidad.', style: AppTextStyles.bodyMedium),
          ),
        );
      }
      final days = availability.keys.toList()..sort();
      final children = <Widget>[];
      for (var day in days) {
        final rangesData = availability[day] as List;
        final validRanges = <TimeRange>[];
        for (var rangeJson in rangesData) {
          final range = TimeRange.tryFromJson(rangeJson);
          if (range != null) validRanges.add(range);
        }
        if (validRanges.isEmpty) continue;
        final formattedRanges = validRanges.map((r) => r.format(context)).join(', ');
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(width: 100, child: Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(day)), style: AppTextStyles.labelMedium)),
                Expanded(child: Text(formattedRanges, style: AppTextStyles.bodySmall)),
              ],
            ),
          ),
        );
      }
      if (children.isEmpty) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('No hay horarios válidos', style: AppTextStyles.bodyMedium),
          ),
        );
      }
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: children),
        ),
      );
    } catch (e) {
      print('Error en disponibilidad: $e');
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error al cargar la disponibilidad.', style: AppTextStyles.bodySmall.copyWith(color: Colors.red)),
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: AppTextStyles.headlineMedium),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
      ],
    );
  }

  Widget _buildDivider() => const Divider(height: 16, thickness: 0.5);
}