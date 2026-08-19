import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:workflex/core/constants/app_colors.dart';
import 'package:workflex/core/constants/app_text_styles.dart';
import 'package:workflex/core/models/time_range.dart';
import 'package:go_router/go_router.dart';

class FreelancerPreviewScreen extends StatefulWidget {
  final String freelancerId;
  const FreelancerPreviewScreen({super.key, required this.freelancerId});

  @override
  State<FreelancerPreviewScreen> createState() => _FreelancerPreviewScreenState();
}

class _FreelancerPreviewScreenState extends State<FreelancerPreviewScreen> {
  late Future<DocumentSnapshot> _freelancerFuture;

  @override
  void initState() {
    super.initState();
    _freelancerFuture = FirebaseFirestore.instance
        .collection('freelancers')
        .doc(widget.freelancerId)
        .get();
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return '';
    if (dateValue is Timestamp) {
      return DateFormat('dd/MM/yyyy').format(dateValue.toDate());
    }
    if (dateValue is String) {
      try {
        return DateFormat('dd/MM/yyyy').format(DateTime.parse(dateValue));
      } catch (e) {
        return dateValue;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Perfil del freelancer'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _freelancerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Freelancer no encontrado'));
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
                        _buildInfoRow('Nombre', data['fullName'] ?? ''),
                        _buildDivider(),
                        _buildInfoRow('Email', data['email'] ?? ''),
                        _buildDivider(),
                        _buildInfoRow('Teléfono', data['phone'] ?? ''),
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
                _buildSectionTitle('Disponibilidad'),
                _buildAvailabilityCard(data['availability']),
                const SizedBox(height: 24),
                _buildSectionTitle('Experiencia laboral'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: (data['experience'] as List? ?? []).map<Widget>((exp) {
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
          width: 100,
          child: Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
      ],
    );
  }

  Widget _buildDivider() => const Divider(height: 16, thickness: 0.5);

  Widget _buildAvailabilityCard(dynamic availability) {
    try {
      if (availability == null || availability.isEmpty) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('No ha definido disponibilidad.', style: AppTextStyles.bodyMedium),
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
                SizedBox(width: 100, child: Text(day, style: AppTextStyles.labelMedium)),
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
            child: Text('No hay horarios válidos.', style: AppTextStyles.bodyMedium),
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
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error al cargar disponibilidad.', style: AppTextStyles.bodySmall.copyWith(color: Colors.red)),
        ),
      );
    }
  }
}
