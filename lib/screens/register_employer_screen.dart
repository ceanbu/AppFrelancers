import 'package:flutter/material.dart';
import 'package:jobbit/models/estado.dart';
import 'package:jobbit/models/municipio.dart';
import 'package:jobbit/services/ibge_service.dart';

class RegisterEmployerScreen extends StatefulWidget {
  const RegisterEmployerScreen({super.key});

  @override
  State<RegisterEmployerScreen> createState() => _RegisterEmployerScreenState();
}

class _RegisterEmployerScreenState extends State<RegisterEmployerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ibgeService = IbgeService();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _representativeDocNumController = TextEditingController();
  final _representativeDobController = TextEditingController();
  final _representativePhoneController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _addressController = TextEditingController(); // Calle, Av etc.
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();

  final List<String> _businessTypes = ['Restaurante', 'Loja', 'Bar', 'Cafeteria', 'Hotel', 'Serviços', 'Outro'];
  String? _selectedBusinessType;

  List<Estado> _estados = [];
  List<Municipio> _municipios = [];
  Estado? _selectedEstado;
  Municipio? _selectedMunicipio;
  DateTime? _selectedRepresentativeDate;

  String? _selectedRepresentativeDocType;
  final List<String> _representativeDocumentTypes = ['CPF', 'CNPJ', 'RG', 'RNM', 'CRNM'];

  bool _loadingEstados = false;
  bool _loadingMunicipios = false;
  String? _errorEstados;
  String? _errorMunicipios;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadEstados();
  }

  Future<void> _loadEstados() async {
    setState(() => _loadingEstados = true);
    try {
      final estados = await _ibgeService.getEstados();
      setState(() {
        _estados = estados;
        _errorEstados = null;
      });
    } catch (e) {
      setState(() => _errorEstados = "Erro ao carregar estados: ${e.toString()}");
    } finally {
      setState(() => _loadingEstados = false);
    }
  }

  Future<void> _loadMunicipios(String estadoId) async {
    setState(() {
      _loadingMunicipios = true;
      _selectedMunicipio = null;
      _municipios = [];
    });
    try {
      final municipios = await _ibgeService.getMunicipiosPorEstado(estadoId);
      setState(() {
        _municipios = municipios;
        _errorMunicipios = null;
      });
    } catch (e) {
      setState(() => _errorMunicipios = "Erro ao carregar municípios: ${e.toString()}");
    } finally {
      setState(() => _loadingMunicipios = false);
    }
  }

  Future<void> _selectRepresentativeDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedRepresentativeDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'), // O 'es', 'ES'
    );
    if (picked != null && picked != _selectedRepresentativeDate) {
      setState(() {
        _selectedRepresentativeDate = picked;
        _representativeDobController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _registerEmployer() {
    if (_formKey.currentState!.validate()) {
      // Todas las validaciones individuales de campos ya se hicieron.
      // Aquí podrías añadir validaciones cruzadas si fueran necesarias.

      print('Registrando Negócio:');
      print('Email: ${_emailController.text}');
      // No imprimir contraseñas
      print('Nome do Negócio: ${_businessNameController.text}');
      print('Tipo de Documento do Representante: $_selectedRepresentativeDocType');
      print('Número do Documento do Representante: ${_representativeDocNumController.text}');
      print('Data de Nascimento do Representante: ${_representativeDobController.text}');
      print('Telefone do Representante: ${_representativePhoneController.text}');
      print('Tipo de Negócio: $_selectedBusinessType');
      print('Estado: ${_selectedEstado?.nome}');
      print('Município: ${_selectedMunicipio?.nome}');
      print('Bairro: ${_neighborhoodController.text}');
      print('Logradouro (Endereço): ${_addressController.text}');
      print('Número (Endereço): ${_numberController.text}');
      print('Complemento (Endereço): ${_complementController.text}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro de Negócio simulado com sucesso! (Verifique o console)')),
      );
      // TODO: Navegar para a próxima tela (ex: Dashboard do Empregador)
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNameController.dispose();
    _representativeDocNumController.dispose();
    _representativeDobController.dispose();
    _representativePhoneController.dispose();
    _neighborhoodController.dispose();
    _addressController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    super.dispose();
  }

  // Helper para construir TextFormFields con label externo
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration( // Estilo base viene del tema
            hintText: hint,
            suffixIcon: suffixIcon,
          ),
          keyboardType: keyboardType,
          validator: validator,
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
        ),
      ],
    );
  }

  // Helper para construir DropdownButtonFormFields con label externo
  Widget _buildDropdownField<T>({
    required String label,
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
    String? Function(T?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          decoration: InputDecoration( // Estilo base viene del tema
            hintText: hint,
          ),
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          isExpanded: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Negócio'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Cadastre seu Negócio',
                    textAlign: TextAlign.center,
                    style: textTheme.displayLarge?.copyWith(color: colorScheme.onBackground),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Informe os dados para criar a conta da sua empresa.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 30),

                  _buildTextField(
                    controller: _emailController,
                    label: 'Email do Negócio',
                    hint: 'contato@suaempresa.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor, insira o email do negócio';
                      if (!value.contains('@') || !value.contains('.')) return 'Email inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _passwordController,
                    label: 'Senha',
                    hint: 'Crie uma senha para a conta',
                    obscureText: !_passwordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(_passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor, insira a senha';
                      if (value.length < 6) return 'Senha deve ter no mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirmar Senha',
                    hint: 'Repita a senha',
                    obscureText: !_confirmPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(_confirmPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor, confirme a senha';
                      if (value != _passwordController.text) return 'As senhas não coincidem';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _businessNameController,
                    label: 'Nome do Negócio',
                    hint: 'Nome fantasia da sua empresa',
                    validator: (value) => value == null || value.isEmpty ? 'Insira o nome do negócio' : null,
                  ),
                  const SizedBox(height: 24),

                  Text('Dados do Representante Legal', style: textTheme.displayMedium?.copyWith(color: colorScheme.onBackground)),
                  const SizedBox(height: 12),

                  _buildDropdownField<String>(
                    label: 'Tipo de Documento do Representante',
                    hint: 'Selecione o tipo',
                    value: _selectedRepresentativeDocType,
                    items: _representativeDocumentTypes.map((String type) {
                      return DropdownMenuItem<String>(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() => _selectedRepresentativeDocType = newValue);
                    },
                    validator: (value) => value == null ? 'Selecione o tipo de documento' : null,
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _representativeDocNumController,
                    label: 'Número do Documento do Representante',
                    hint: 'Número do documento',
                    validator: (value) => value == null || value.isEmpty ? 'Insira o número do documento' : null,
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _representativeDobController,
                    label: 'Data de Nascimento do Representante',
                    hint: 'DD/MM/AAAA',
                    readOnly: true,
                    onTap: () => _selectRepresentativeDate(context),
                    suffixIcon: const Icon(Icons.calendar_today),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Selecione a data de nascimento';
                      if (_selectedRepresentativeDate != null) {
                        final today = DateTime.now();
                        final age = today.year - _selectedRepresentativeDate!.year -
                            (today.month < _selectedRepresentativeDate!.month ||
                                    (today.month == _selectedRepresentativeDate!.month && today.day < _selectedRepresentativeDate!.day)
                                ? 1 : 0);
                        if (age < 18) return 'O representante deve ter pelo menos 18 anos.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _representativePhoneController,
                    label: 'Telefone do Representante',
                    hint: '(XX) XXXXX-XXXX',
                    keyboardType: TextInputType.phone,
                    suffixIcon: Text('Para contato via WhatsApp', style: textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                    validator: (value) => value == null || value.isEmpty ? 'Insira o telefone do representante' : null,
                  ),
                  const SizedBox(height: 24),

                  Text('Dados do Negócio', style: textTheme.displayMedium?.copyWith(color: colorScheme.onBackground)),
                  const SizedBox(height: 12),

                  _buildDropdownField<String>(
                    label: 'Tipo de Negócio',
                    hint: 'Selecione o tipo',
                    value: _selectedBusinessType,
                    items: _businessTypes.map((String type) {
                      return DropdownMenuItem<String>(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() => _selectedBusinessType = newValue);
                    },
                    validator: (value) => value == null ? 'Selecione o tipo de negócio' : null,
                  ),
                  const SizedBox(height: 20),

                  _buildDropdownField<Estado>(
                    label: 'Estado (UF) do Negócio',
                    hint: 'Selecione o Estado',
                    value: _selectedEstado,
                    items: _estados.map((Estado estado) {
                      return DropdownMenuItem<Estado>(value: estado, child: Text(estado.nome));
                    }).toList(),
                    onChanged: (Estado? newValue) {
                      setState(() {
                        _selectedEstado = newValue;
                        _selectedMunicipio = null;
                        _municipios = [];
                        if (newValue != null) _loadMunicipios(newValue.id.toString());
                      });
                    },
                    validator: (value) => value == null ? 'Selecione um estado' : null,
                  ),
                  const SizedBox(height: 20),

                  if (_loadingMunicipios) const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())),
                  if (_errorMunicipios != null) Center(child: Text(_errorMunicipios!, style: TextStyle(color: colorScheme.error))),
                  if (!_loadingMunicipios && _errorMunicipios == null && _selectedEstado != null)
                    _buildDropdownField<Municipio>(
                      label: 'Município do Negócio',
                      hint: 'Selecione o Município',
                      value: _selectedMunicipio,
                      items: _municipios.map((Municipio municipio) {
                        return DropdownMenuItem<Municipio>(value: municipio, child: Text(municipio.nome));
                      }).toList(),
                      onChanged: (Municipio? newValue) {
                        setState(() => _selectedMunicipio = newValue);
                      },
                      validator: (value) => value == null ? 'Selecione um município' : null,
                    ),
                  if (_selectedEstado != null) const SizedBox(height: 20),

                  _buildTextField(
                    controller: _neighborhoodController,
                    label: 'Bairro do Negócio',
                    hint: 'Bairro da empresa',
                    validator: (value) => value == null || value.isEmpty ? 'Insira o bairro' : null,
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _addressController,
                    label: 'Logradouro do Negócio (Rua, Av, etc.)',
                    hint: 'Endereço da empresa',
                    validator: (value) => value == null || value.isEmpty ? 'Insira o logradouro' : null,
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _numberController,
                    label: 'Número do Endereço',
                    hint: 'Ex: 123',
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Insira o número' : null,
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _complementController,
                    label: 'Complemento do Endereço (Opcional)',
                    hint: 'Ex: Sala 10, Prédio B',
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _registerEmployer,
                    // El estilo se toma del tema, pero puedes sobrescribir el color si es necesario
                    // style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A78ED)),
                    child: const Text('Registrar Negócio'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

**Cambios Clave en este código:**

*   **Estructura y Espaciado:** Similar a `register_freelancer_screen.dart`, se ha añadido `Center`, `SingleChildScrollView`, `Padding`, y `ConstrainedBox`. Se ha mejorado el espaciado con `SizedBox`.
*   **Helpers `_buildTextField` y `_buildDropdownField`:** Se han copiado y adaptado estos métodos para mantener la consistencia de los labels externos y el estilo de los campos.
*   **Textos y Títulos:** Se usan estilos de `textTheme` para los títulos principales y de sección.
*   **Campos de Formulario:** La `InputDecoration` se simplifica para heredar del tema.
*   **Botón "Registrar Negócio":** Usará el estilo del `elevatedButtonTheme`. Si quieres el color azul específico `0xFF0A78ED` para este botón también, puedes añadir `style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A78ED))` como en la pantalla de freelancer. Por defecto, usará el `primaryColor` (`#4a90e2`) definido en el tema.

**Después de reemplazar y guardar `lib/screens/register_employer_screen.dart`:**

*   **Reinicia completamente tu aplicación.**
*   Navega a la pantalla de Registro de Empleador.

Debería tener una apariencia mucho más consistente con las otras pantallas que hemos estilizado.

Avísame cómo se ve y si hay algo que ajustar. Una vez que estés satisfecho, pasaremos a la última pantalla del plan de estilización: `freelancer_availability_screen.dart`.
