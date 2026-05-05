import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../data/brazil_data.dart';

class IbgeService {
  static const String _statesUrl = 'https://servicodados.ibge.gov.br/api/v1/localidades/estados';

  Future<List<Map<String, dynamic>>> getEstados() async {
    // Primero intentar API
    try {
      final response = await http.get(Uri.parse(_statesUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> estados = data.map((e) => {
          'id': e['id'],
          'nome': e['nome'],
          'sigla': e['sigla'],
        }).toList();
        estados.sort((a, b) => a['nome'].compareTo(b['nome']));
        if (kDebugMode) print('✅ Estados cargados desde API: ${estados.length}');
        return estados;
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ API falló, usando datos locales. Error: $e');
      // Fallback a datos locales
      return BrazilData.getEstados();
    }
  }

  Future<List<Map<String, dynamic>>> getMunicipios(int estadoId) async {
    // Primero intentar API
    try {
      final url = 'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$estadoId/municipios';
      if (kDebugMode) print('🌐 API municipios: $url');
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> municipios = data.map((e) => {
          'id': e['id'],
          'nome': e['nome'],
        }).toList();
        municipios.sort((a, b) => a['nome'].compareTo(b['nome']));
        if (kDebugMode) print('✅ Municipios desde API: ${municipios.length}');
        return municipios;
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ API municipios falló, usando datos locales. Error: $e');
      // Fallback a datos locales
      final municipiosPorEstado = BrazilData.getMunicipiosPorEstado();
      final listaNomes = municipiosPorEstado[estadoId] ?? [];
      // Convertir a formato Map con id y nome (usamos índice como id)
      return listaNomes.asMap().entries.map((entry) {
        return {
          'id': entry.key,
          'nome': entry.value,
        };
      }).toList();
    }
  }
}