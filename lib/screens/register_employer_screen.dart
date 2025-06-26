import 'package:flutter/material.dart';
import 'package:jobbit/models/estado.dart';
import 'package:jobbit/models/municipio.dart'; // Importación faltante
import 'package:jobbit/services/ibge_service.dart';

class RegisterEmployerScreen extends StatefulWidget {
  const RegisterEmployerScreen({super.key});

  @override
  State<RegisterEmployerScreen> createState() => _RegisterEmployerScreenState();
}

class _RegisterEmployerScreenState extends State<RegisterEmployerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ibgeService = IbgeService();

  List<Estado> _estados = [];
  Estado? _selectedEstado;
  bool _isLoadingEstados = true;
  String? _estadosError;

  List<Municipio> _municipios = [];
  Municipio? _selectedMunicipio;
  bool _isLoadingMunicipios = false;
  String? _municipiosError;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _representativeDocTypeController = TextEditingController(); // Podría ser Dropdown
  final _representativeDocNumController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _addressStreetController = TextEditingController();

  String? _selectedBusinessType; // Para el Dropdown de Tipo de Local
  final List<String> _businessTypes = ['Restaurante', 'Bar', 'Tienda', 'Cafetería', 'Otro']; // Placeholder list


  @override
  void initState() {
    super.initState();
    _loadEstados();
  }

  Future<void> _loadEstados() async {
    setState(() {
      _isLoadingEstados = true;
      _estadosError = null;
      _selectedEstado = null; // Reset estado
      _municipios = []; // Clear municipios
      _selectedMunicipio = null; // Reset municipio
    });
    try {
      final estados = await _ibgeService.getEstados();
      if (!mounted) return;
      setState(() {
        _estados = estados;
        _isLoadingEstados = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _estadosError = "Erro ao carregar estados: ${e.toString()}";
        _isLoadingEstados = false;
      });
      print(_estadosError);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_estadosError!)),
        );
      }
    }
  }

  Future<void> _loadMunicipios(String ufId) async {
    setState(() {
      _isLoadingMunicipios = true;
      _municipiosError = null;
      _municipios = []; // Clear previous municipios
      _selectedMunicipio = null; // Reset selected municipio
    });
    try {
      final municipios = await _ibgeService.getMunicipiosPorEstado(ufId);
      if (!mounted) return;
      setState(() {
        _municipios = municipios;
        _isLoadingMunicipios = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _municipiosError = "Erro ao carregar municípios: ${e.toString()}";
        _isLoadingMunicipios = false;
      });
      print(_municipiosError);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_municipiosError!)),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNameController.dispose();
    _representativeDocTypeController.dispose();
    _representativeDocNumController.dispose();
    _neighborhoodController.dispose();
    _addressStreetController.dispose();
    super.dispose();
  }

  void _onEstadoChanged(Estado? newState) {
    setState(() {
      _selectedEstado = newState;
      _selectedMunicipio = null;
      _municipios = [];
      _municipiosError = null;
      if (newState != null) {
        _loadMunicipios(newState.id.toString()); // API usa ID o sigla, ID es más robusto si disponible así
      }
    });
    print("Estado selecionado: ${newState?.nome}, ID: ${newState?.id}");
  }

  void _onMunicipioChanged(Municipio? newMunicipio) {
    setState(() {
      _selectedMunicipio = newMunicipio;
    });
    print("Município selecionado: ${newMunicipio?.nome}");
  }

  void _registerEmployer() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with registration logic
      print('Formulario de Registro de Empleador Válido');
      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}'); // Consider not printing passwords in real apps
      print('Nombre del Negocio: ${_businessNameController.text}');
      print('Tipo de Local: $_selectedBusinessType');
      print('Tipo de Documento: ${_representativeDocTypeController.text}');
      print('Número de Documento: ${_representativeDocNumController.text}');
      print('Estado: ${_selectedEstado?.nome} (ID: ${_selectedEstado?.id}, Sigla: ${_selectedEstado?.sigla})');
      print('Município: ${_selectedMunicipio?.nome} (ID: ${_selectedMunicipio?.id})');
      print('Barrio: ${_neighborhoodController.text}');
      print('Dirección: ${_addressStreetController.text}');

      // TODO: Implement actual registration call to Firebase or your backend
      // For example:
      // try {
      //   setState(() { _isRegistering = true; }); // Para mostrar un indicador de carga
      //   await AuthService().registerEmployer(...data...);
      //   Navigator.of(context).pushReplacementNamed('/employer_dashboard'); // o similar
      // } catch (e) {
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error en el registro: $e")));
      // } finally {
      //   setState(() { _isRegistering = false; });
      // }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro enviado (simulado). Ver consola para datos.')),
      );
    } else {
      print('Formulario de Registro de Empleador Inválido');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor corrija los errores en el formulario.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro Empleador'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Información de la Cuenta',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Por favor ingrese su email';
                    if (!value.contains('@') || !value.contains('.')) return 'Email inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Por favor ingrese su contraseña';
                    if (value.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(labelText: 'Confirmar Contraseña', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Por favor confirme su contraseña';
                    if (value != _passwordController.text) return 'Las contraseñas no coinciden';
                    return null;
                  },
                ),

                const SizedBox(height: 24),
                const Text(
                  'Información del Negocio',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _businessNameController,
                  decoration: const InputDecoration(labelText: 'Nombre del Negocio', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'Ingrese el nombre del negocio' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedBusinessType,
                  hint: const Text('Tipo de Local'),
                  isExpanded: true,
                  items: _businessTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedBusinessType = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Seleccione el tipo de local' : null,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Local',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  'Documentación',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // TODO: Considerar un Dropdown para Tipo de Documento si hay una lista predefinida
                TextFormField(
                  controller: _representativeDocTypeController,
                  decoration: const InputDecoration(labelText: 'Tipo de Documento del Representante', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'Ingrese el tipo de documento' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _representativeDocNumController,
                  decoration: const InputDecoration(labelText: 'Número de Documento del Representante', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'Ingrese el número de documento' : null,
                ),


                const SizedBox(height: 24),
                const Text(
                  'Dirección del Negocio',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Estado Dropdown
                if (_isLoadingEstados)
                  const Center(child: CircularProgressIndicator())
                else if (_estadosError != null)
                  Text(_estadosError!, style: const TextStyle(color: Colors.red))
                else if (_estados.isEmpty)
                  const Text('No hay estados para seleccionar.')
                else
                  DropdownButtonFormField<Estado>(
                    value: _selectedEstado,
                    hint: const Text('Seleccione un Estado'),
                    isExpanded: true,
                    items: _estados.map((Estado estado) {
                      return DropdownMenuItem<Estado>(
                        value: estado,
                        child: Text(estado.nome),
                      );
                    }).toList(),
                    onChanged: _onEstadoChanged,
                    validator: (value) => value == null ? 'Por favor seleccione un estado' : null,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                    ),
                  ),
                const SizedBox(height: 20),

                // Municipio Dropdown
                if (_selectedEstado == null)
                  // No mostrar nada o un placeholder si no hay estado seleccionado
                  Container()
                else if (_isLoadingMunicipios)
                  const Center(child: CircularProgressIndicator())
                else if (_municipiosError != null)
                  Text(_municipiosError!, style: const TextStyle(color: Colors.red))
                else if (_municipios.isEmpty && !_isLoadingMunicipios) // Solo mostrar si no está cargando y está vacío
                  const Text('No hay municípios para este estado o seleccione un estado.')
                else
                  DropdownButtonFormField<Municipio>(
                    value: _selectedMunicipio,
                    hint: const Text('Seleccione un Município'),
                    isExpanded: true,
                    items: _municipios.map((Municipio municipio) {
                      return DropdownMenuItem<Municipio>(
                        value: municipio,
                        child: Text(municipio.nome),
                      );
                    }).toList(),
                    onChanged: _onMunicipioChanged,
                    validator: (value) => value == null ? 'Por favor seleccione un município' : null,
                     decoration: const InputDecoration(
                      labelText: 'Município',
                      border: OutlineInputBorder(),
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _neighborhoodController,
                  decoration: const InputDecoration(labelText: 'Barrio', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'Ingrese el barrio' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressStreetController,
                  decoration: const InputDecoration(labelText: 'Dirección (Calle, Número, etc.)', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'Ingrese la dirección' : null,
                ),

                const SizedBox(height: 30),
                // Register Button will go here in Part 3
                ElevatedButton(
                  onPressed: _registerEmployer,
                  child: const Text('Registrar Negocio'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
