import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workflex/services/skills_service.dart';
import 'package:workflex/core/constants/app_colors.dart';

final skillsListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = SkillsService();
  return await service.getSkills();
});

class WFSkillsSelector extends ConsumerStatefulWidget {
  final String title;
  final List<String> initialSelected;
  final Function(List<String>) onSaved;

  const WFSkillsSelector({
    super.key,
    required this.title,
    this.initialSelected = const [],
    required this.onSaved,
  });

  @override
  ConsumerState<WFSkillsSelector> createState() => _WFSkillsSelectorState();
}

class _WFSkillsSelectorState extends ConsumerState<WFSkillsSelector> {
  late List<String> _selected;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.initialSelected);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skillsAsync = ref.watch(skillsListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Seleccionadas (${_selected.length}/6)',
                style: const TextStyle(fontWeight: FontWeight.w500)),
            if (_selected.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _selected.clear()),
                child: const Text('Limpiar todo'),
              ),
          ],
        ),
        if (_selected.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selected.map((skill) => Chip(
              label: Text(skill,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              backgroundColor: AppColors.primary,
              deleteIconColor: Colors.white,
              onDeleted: () => setState(() => _selected.remove(skill)),
            )).toList(),
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Buscar habilidad...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: skillsAsync.when(
            data: (skills) {
              final filtered = skills
                  .where((skill) =>
                      skill['name'].toString().toLowerCase().contains(_searchQuery))
                  .toList();
              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final skill = filtered[index];
                  final name = skill['name'] as String;
                  final isSelected = _selected.contains(name);
                  final atLimit = _selected.length >= 6 && !isSelected;
                  return CheckboxListTile(
                    title: Text(name,
                        style: TextStyle(
                            color: atLimit ? Colors.grey : null)),
                    value: isSelected,
                    activeColor: AppColors.primary,
                    onChanged: atLimit
                        ? null
                        : (value) {
                            setState(() {
                              if (value == true) {
                                _selected.add(name);
                              } else {
                                _selected.remove(name);
                              }
                            });
                          },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Center(child: Text('Error al cargar habilidades: $err')),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => widget.onSaved(_selected),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text('Guardar habilidades'),
        ),
      ],
    );
  }
}