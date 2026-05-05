import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/skills_service.dart';

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
            Text('Seleccionadas (/6)'),
            if (_selected.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _selected.clear()),
                child: const Text('Limpiar todo'),
              ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: _selected.map((skill) => Chip(
            label: Text(skill),
            onDeleted: () => setState(() => _selected.remove(skill)),
          )).toList(),
        ),
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
              final filtered = skills.where((skill) =>
                  skill['name'].toLowerCase().contains(_searchQuery)).toList();
              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final skill = filtered[index];
                  final name = skill['name'];
                  final isSelected = _selected.contains(name);
                  return CheckboxListTile(
                    title: Text(name),
                    value: isSelected,
                    onChanged: (_selected.length < 6 || isSelected)
                        ? (value) {
                            setState(() {
                              if (value == true) {
                                _selected.add(name);
                              } else {
                                _selected.remove(name);
                              }
                            });
                          }
                        : null,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: ')),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => widget.onSaved(_selected),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text('Guardar habilidades'),
        ),
      ],
    );
  }
}
