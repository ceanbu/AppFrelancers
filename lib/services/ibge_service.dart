import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jobbit/models/estado.dart';
import 'package:jobbit/models/municipio.dart';

class IbgeService {
  final String _baseUrl = 'https://servicodados.ibge.gov.br/api/v1/localidades';

  Future<List<Estado>> getEstados() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/estados?orderBy=nome'));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        return jsonResponse.map((data) => Estado.fromJson(data)).toList();
      } else {
        print('Error fetching estados: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load estados. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught in getEstados: $e');
      throw Exception('Failed to load estados: $e');
    }
  }

  Future<List<Municipio>> getMunicipiosPorEstado(String ufId) async {
    // El ID del estado puede ser su sigla o su ID numérico.
    // La API espera el ID numérico o la sigla. Usaremos la sigla (UF) que es más común.
    try {
      final response = await http.get(Uri.parse('$_baseUrl/estados/$ufId/municipios?orderBy=nome'));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        return jsonResponse.map((data) => Municipio.fromJson(data)).toList();
      } else {
        print('Error fetching municipios for $ufId: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load municipios for $ufId. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught in getMunicipiosPorEstado for $ufId: $e');
      throw Exception('Failed to load municipios for $ufId: $e');
    }
  }
}
