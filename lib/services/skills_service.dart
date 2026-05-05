import 'package:cloud_firestore/cloud_firestore.dart';

class SkillsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getSkills() async {
    try {
      final snapshot = await _firestore.collection('skills').get();
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        'name': doc['name'] as String,
        'category': doc['category'] as String,
      }).toList();
    } catch (e) {
      print('Error al cargar habilidades: $e');
      return [];
    }
  }
}