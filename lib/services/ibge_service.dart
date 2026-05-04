import 'dart:convert';
import 'package:http/http.dart' as http;

class IbgeService {
  static const String _statesUrl = 'https://servicodados.ibge.gov.br/api/v1/localidades/estados';

  Future<List<Map<String, dynamic>>> getEstados() async {
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
        return estados;
      } else {
        throw Exception('Error al cargar estados: ');
      }
    } catch (e) {
      throw Exception('Error de red: ');
    }
  }

  Future<List<Map<String, dynamic>>> getMunicipios(int estadoId) async {
    try {
      final url = 'https://servicodados.ibge.gov.br/api/v1/localidades/estados//municipios';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> municipios = data.map((e) => {
          'id': e['id'],
          'nome': e['nome'],
        }).toList();
        municipios.sort((a, b) => a['nome'].compareTo(b['nome']));
        return municipios;
      } else {
        throw Exception('Error al cargar municipios: ');
      }
    } catch (e) {
      throw Exception('Error de red: ');
    }
  }
}
