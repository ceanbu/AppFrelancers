import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workflex/services/ibge_service.dart';

class WFAddressIBGE extends ConsumerStatefulWidget {
  final Function(Map<String, String>) onAddressChanged;

  /// Dirección existente para precargar el widget en modo edición.
  /// Claves esperadas: state, municipality, neighborhood, street, number, complement.
  /// Si es null (comportamiento original), el widget arranca vacío.
  final Map<String, String>? initialAddress;

  const WFAddressIBGE({
    super.key,
    required this.onAddressChanged,
    this.initialAddress,
  });

  @override
  ConsumerState<WFAddressIBGE> createState() => _WFAddressIBGEState();
}

class _WFAddressIBGEState extends ConsumerState<WFAddressIBGE> {
  final IbgeService _ibgeService = IbgeService();

  List<Map<String, dynamic>> _estados = [];
  String? _selectedEstadoId;
  String? _selectedEstadoNome;

  Future<List<Map<String, dynamic>>>? _municipiosFuture;
  String? _selectedMunicipioId;
  String? _selectedMunicipioNome;

  final _neighborhoodController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();

  bool _isLoadingEstados = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Precargar los campos de texto libre si venimos en modo edición.
    final initial = widget.initialAddress;
    if (initial != null) {
      _neighborhoodController.text = initial['neighborhood'] ?? '';
      _streetController.text = initial['street'] ?? '';
      _numberController.text = initial['number'] ?? '';
      _complementController.text = initial['complement'] ?? '';
    }
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

      // Modo edición: si nos pasaron un estado inicial, preseleccionarlo
      // y disparar la carga (y preselección) de municipios.
      final initialStateName = widget.initialAddress?['state'];
      if (initialStateName != null && initialStateName.isNotEmpty) {
        final match = _estados.firstWhere(
          (e) => e['nome'] == initialStateName,
          orElse: () => {},
        );
        if (match.isNotEmpty) {
          await _preselectEstado(match['id'].toString());
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar estados: $e';
        _isLoadingEstados = false;
      });
    }
  }

  /// Usado solo para la precarga en modo edición: selecciona el estado,
  /// espera los municipios, y si hay un municipio inicial que coincide
  /// por nombre, lo preselecciona también.
  Future<void> _preselectEstado(String estadoId) async {
    setState(() {
      _selectedEstadoId = estadoId;
      final selected = _estados.firstWhere(
        (e) => e['id'].toString() == estadoId,
        orElse: () => {},
      );
      _selectedEstadoNome = selected['nome'];
    });

    final idInt = int.tryParse(estadoId);
    if (idInt == null) return;

    final future = _ibgeService.getMunicipios(idInt);
    // OJO: setState(() => _municipiosFuture = future) rompía en runtime.
    // Una asignación como expresión de una función flecha evalúa al valor
    // asignado (acá, el propio Future), así que el closure "devolvía" un
    // Future y disparaba la aserción de setState(). Con bloque {} la
    // asignación es una sentencia, no una expresión, y no devuelve nada.
    setState(() {
      _municipiosFuture = future;
    });

    try {
      final municipios = await future;
      final initialMunicipalityName = widget.initialAddress?['municipality'];
      if (initialMunicipalityName != null && initialMunicipalityName.isNotEmpty) {
        final match = municipios.firstWhere(
          (m) => m['nome'] == initialMunicipalityName,
          orElse: () => {},
        );
        if (match.isNotEmpty && mounted) {
          setState(() {
            _selectedMunicipioId = match['id'].toString();
            _selectedMunicipioNome = match['nome'];
          });
          _notifyParent();
        }
      }
    } catch (_) {
      // Si falla la precarga de municipios, el usuario igual puede
      // seleccionar manualmente una vez que el dropdown cargue.
    }
  }

  void _onEstadoChanged(String? estadoId) {
    setState(() {
      _selectedEstadoId = estadoId;
      final selected = _estados.firstWhere(
        (e) => e['id'].toString() == estadoId,
        orElse: () => {},
      );
      if (selected.isEmpty) return;
      _selectedEstadoNome = selected['nome'];
      _selectedMunicipioId = null;
      _selectedMunicipioNome = null;
      if (estadoId != null) {
        final idInt = int.tryParse(estadoId);
        if (idInt != null) {
          _municipiosFuture = _ibgeService.getMunicipios(idInt);
        } else {
          _municipiosFuture = Future.error('ID inválido');
        }
      } else {
        _municipiosFuture = null;
      }
    });
    _notifyParent();
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
                onChanged: _onEstadoChanged,
                validator: (value) => value == null ? 'Seleccione un estado' : null,
              ),
        const SizedBox(height: 16),

        const Text('Municipio *', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        if (_selectedEstadoId == null)
          const Text('Primero seleccione un estado', style: TextStyle(color: Colors.grey))
        else if (_municipiosFuture == null)
          const CircularProgressIndicator()
        else
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _municipiosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No hay municipios disponibles', style: TextStyle(color: Colors.orange));
              }
              final municipios = snapshot.data!;
              return DropdownButtonFormField<String>(
                value: _selectedMunicipioId,
                hint: const Text('Seleccione un municipio'),
                isExpanded: true,
                items: municipios.map((municipio) {
                  return DropdownMenuItem<String>(
                    value: municipio['id'].toString(),
                    child: Text(municipio['nome']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMunicipioId = value;
                    final selected = municipios.firstWhere((e) => e['id'].toString() == value);
                    _selectedMunicipioNome = selected['nome'];
                  });
                  _notifyParent();
                },
                validator: (value) => value == null ? 'Seleccione un municipio' : null,
              );
            },
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
            child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
          ),
      ],
    );
  }
}
