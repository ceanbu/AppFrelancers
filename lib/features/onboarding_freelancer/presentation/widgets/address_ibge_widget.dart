import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/ibge_service.dart';

class AddressIbgeWidget extends ConsumerStatefulWidget {
  final Function(Map<String, String>) onAddressChanged;
  
  const AddressIbgeWidget({super.key, required this.onAddressChanged});

  @override
  ConsumerState<AddressIbgeWidget> createState() => _AddressIbgeWidgetState();
}

class _AddressIbgeWidgetState extends ConsumerState<AddressIbgeWidget> {
  final IbgeService _ibgeService = IbgeService();
  
  List<Map<String, dynamic>> _estados = [];
  List<Map<String, dynamic>> _municipios = [];
  
  String? _selectedEstadoId;
  String? _selectedEstadoNome;
  String? _selectedMunicipioId;
  String? _selectedMunicipioNome;
  
  final _neighborhoodController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  
  bool _isLoadingEstados = true;
  bool _isLoadingMunicipios = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEstados();
  }

  @override
  void dispose() {
    _neighborhoodController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    super.dispose();
  }

  Future<void> _loadEstados() async {
    setState(() {
      _isLoadingEstados = true;
      _errorMessage = null;
    });
    try {
      final estados = await _ibgeService.getEstados();
      setState(() {
        _estados = estados;
        _isLoadingEstados = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar estados: ';
        _isLoadingEstados = false;
      });
    }
  }

  Future<void> _loadMunicipios(String estadoId) async {
    setState(() {
      _isLoadingMunicipios = true;
      _municipios = [];
      _selectedMunicipioId = null;
      _selectedMunicipioNome = null;
      _errorMessage = null;
    });
    try {
      // Convertir el ID a entero (los IDs de IBGE son números)
      final idInt = int.tryParse(estadoId);
      if (idInt == null) {
        throw Exception('ID de estado inválido: ');
      }
      final municipios = await _ibgeService.getMunicipios(idInt);
      setState(() {
        _municipios = municipios;
        _isLoadingMunicipios = false;
      });
      if (municipios.isEmpty) {
        setState(() {
          _errorMessage = 'No se encontraron municipios para este estado';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar municipios: ';
        _isLoadingMunicipios = false;
      });
    }
  }

  void _notifyParent() {
    widget.onAddressChanged({
      'state': _selectedEstadoNome ?? '',
      'municipality': _selectedMunicipioNome ?? '',
      'neighborhood': _neighborhoodController.text,
      'street': _streetController.text,
      'number': _numberController.text,
      'complement': _complementController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Estado *', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        _isLoadingEstados
            ? const CircularProgressIndicator()
            : DropdownButtonFormField<String>(
                value: _selectedEstadoId,
                hint: const Text('Seleccione un estado'),
                isExpanded: true,
                items: _estados.map((estado) {
                  return DropdownMenuItem<String>(
                    value: estado['id'].toString(),
                    child: Text(estado['nome']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEstadoId = value;
                    final selected = _estados.firstWhere((e) => e['id'].toString() == value);
                    _selectedEstadoNome = selected['nome'];
                    _municipios = [];
                    _selectedMunicipioId = null;
                    _selectedMunicipioNome = null;
                    _errorMessage = null;
                  });
                  if (value != null) _loadMunicipios(value);
                  _notifyParent();
                },
                validator: (value) => value == null ? 'Seleccione un estado' : null,
              ),
        const SizedBox(height: 16),

        const Text('Municipio *', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        if (_selectedEstadoId == null)
          const Text('Primero seleccione un estado', style: TextStyle(color: Colors.grey))
        else if (_isLoadingMunicipios)
          const CircularProgressIndicator()
        else if (_municipios.isEmpty && _errorMessage == null)
          const Text('No hay municipios disponibles para este estado', style: TextStyle(color: Colors.orange))
        else
          DropdownButtonFormField<String>(
            value: _selectedMunicipioId,
            hint: const Text('Seleccione un municipio'),
            isExpanded: true,
            items: _municipios.map((municipio) {
              return DropdownMenuItem<String>(
                value: municipio['id'].toString(),
                child: Text(municipio['nome']),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedMunicipioId = value;
                final selected = _municipios.firstWhere((e) => e['id'].toString() == value);
                _selectedMunicipioNome = selected['nome'];
              });
              _notifyParent();
            },
            validator: (value) => value == null ? 'Seleccione un municipio' : null,
          ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _neighborhoodController,
          decoration: const InputDecoration(
            labelText: 'Barrio',
            hintText: 'Ej: Centro',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _notifyParent(),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _streetController,
          decoration: const InputDecoration(
            labelText: 'Calle/Avenida',
            hintText: 'Ej: Av. Paulista',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _notifyParent(),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _numberController,
          decoration: const InputDecoration(
            labelText: 'Número *',
            hintText: 'Ej: 123',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Ingrese el número' : null,
          onChanged: (_) => _notifyParent(),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _complementController,
          decoration: const InputDecoration(
            labelText: 'Complemento (opcional)',
            hintText: 'Ej: Apto 45, Bloque B',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _notifyParent(),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}
