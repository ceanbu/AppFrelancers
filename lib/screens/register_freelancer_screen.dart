import 'package:flutter/material.dart';
import 'package:jobbit/models/estado.dart';
import 'package:jobbit/models/municipio.dart';
import 'package:jobbit/services/ibge_service.dart';
import 'package:jobbit/screens/freelancer_availability_screen.dart';

class RegisterFreelancerScreen extends StatefulWidget {
  const RegisterFreelancerScreen({super.key});

  @override
  State<RegisterFreelancerScreen> createState() => _RegisterFreelancerScreenState();
}

class _RegisterFreelancerScreenState extends State<RegisterFreelancerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ibgeService = IbgeService();

  final _fullNameController = TextEditingController();
  final _documentNumberController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();

  List<Estado> _estados = [];
  List<Municipio> _municipios = [];
  Estado? _selectedEstado;
  Municipio? _selectedMunicipio;
  DateTime? _selectedDate;
  String? _selectedDocumentType;
  final List<String> _documentTypes = ['CPF', 'RG', 'RNM', 'CRNM'];

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
    setState(() {
      _loadingEstados = true;
      _errorEstados = null;
      _selectedEstado = null;
      _municipios = [];
      _selectedMunicipio = null;
    });
    try {
      final estados = await _ibgeService.getEstados();
      setState(() {
        _estados = estados;
        _loadingEstados = false;
      });
    } catch (e) {
      setState(() {
        _errorEstados = "Erro ao carregar estados: ${e.toString()}";
        _loadingEstados = false;
      });
    }
  }

  Future<void> _loadMunicipios(String estadoId) async {
    setState(() {
      _loadingMunicipios = true;
      _errorMunicipios = null;
      _municipios = [];
      _selectedMunicipio = null;
    });
    try {
      final municipios = await _ibgeService.getMunicipiosPorEstado(estadoId);
      setState(() {
        _municipios = municipios;
        _loadingMunicipios = false;
      });
    } catch (e) {
      setState(() {
        _errorMunicipios = "Erro ao carregar municípios: ${e.toString()}";
        _loadingMunicipios = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'), // O 'es', 'ES' según tu preferencia
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _registerFreelancerAndContinue() {
    if (_formKey.currentState!.validate()) {
      if (_selectedEstado == null || _selectedMunicipio == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione estado e município.')),
        );
        return;
      }

      print('Dados do Freelancer (para simulação):');
      print('Nome Completo: ${_fullNameController.text}');
      print('Tipo de Documento: $_selectedDocumentType');
      print('Número do Documento: ${_documentNumberController.text}');
      print('Data de Nascimento: ${_dateOfBirthController.text}');
      print('Telefone: ${_phoneController.text}');
      print('Email: ${_emailController.text}');
      print('Estado: ${_selectedEstado?.nome}');
      print('Município: ${_selectedMunicipio?.nome}');
      print('Bairro: ${_neighborhoodController.text}');
      print('Logradouro: ${_streetController.text}');
      print('Número: ${_numberController.text}');
      print('Complemento: ${_complementController.text}');

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FreelancerAvailabilityScreen()),
      );
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _documentNumberController.dispose();
    _dateOfBirthController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _neighborhoodController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    super.dispose();
  }

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
          decoration: InputDecoration(
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
          decoration: InputDecoration(
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
        title: const Text('Cadastro de Freelancer'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450), // Ancho máximo
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Crie sua conta de Freelancer', // Título h1-like
                    textAlign: TextAlign.center,
                    style: textTheme.displayLarge?.copyWith(color: colorScheme.onBackground),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Preencha seus dados para começar.', // Subtítulo
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 30),

                  _buildTextField(
                    controller: _fullNameController,
                    label: 'Nome Completo',
                    hint: 'Seu nome completo',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome completo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildDropdownField<String>(
                    label: 'Tipo de Documento',
                    hint: 'Selecione o tipo',
                    value: _selectedDocumentType,
                    items: _documentTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDocumentType = newValue;
                      });
                    },
                    validator: (value) => value == null ? 'Selecione o tipo de documento' : null,
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _documentNumberController,
                    label: 'Número do Documento',
                    hint: 'Número do seu documento',
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o número do documento';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _dateOfBirthController,
                    label: 'Data de Nascimento',
                    hint: 'DD/MM/AAAA',
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    suffixIcon: const Icon(Icons.calendar_today),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, selecione a data de nascimento';
                      }
                      if (_selectedDate != null) {
                        final today = DateTime.now();
                        final age = today.year - _selectedDate!.year -
                            (today.month < _selectedDate!.month ||
                                    (today.month == _selectedDate!.month && today.day < _selectedDate!.day)
                                ? 1
                                : 0);
                        if (age < 18) {
                          return 'Você deve ter pelo menos 18 anos.';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _phoneController,
                    label: 'Telefone',
                    hint: '(XX) XXXXX-XXXX',
                    keyboardType: TextInputType.phone,
                    suffixIcon: Text('Para contato via WhatsApp', style: textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o telefone';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'seuemail@example.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Por favor, insira um email válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _passwordController,
                    label: 'Senha',
                    hint: 'Crie uma senha forte',
                    obscureText: !_passwordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a senha';
                      }
                      if (value.length < 6) {
                        return 'Senha deve ter no mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirmar Senha',
                    hint: 'Repita sua senha',
                    obscureText: !_confirmPasswordVisible,
                     suffixIcon: IconButton(
                      icon: Icon(
                        _confirmPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _confirmPasswordVisible = !_confirmPasswordVisible;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, confirme a senha';
                      }
                      if (value != _passwordController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  Text('Endereço', style: textTheme.displayMedium?.copyWith(color: colorScheme.onBackground)), // h2 style
                  const SizedBox(height: 12),

                  _buildDropdownField<Estado>(
                    label: 'Estado (UF)',
                    hint: 'Selecione o Estado',
                    value: _selectedEstado,
                    items: _estados.map((Estado estado) {
                      return DropdownMenuItem<Estado>(
                        value: estado,
                        child: Text(estado.nome),
                      );
                    }).toList(),
                    onChanged: (Estado? newValue) {
                      setState(() {
                        _selectedEstado = newValue;
                        _selectedMunicipio = null;
                        _municipios = [];
                        if (newValue != null) {
                          _loadMunicipios(newValue.id.toString());
                        }
                      });
                    },
                    validator: (value) => value == null ? 'Selecione um estado' : null,
                  ),
                  const SizedBox(height: 20),

                  if (_loadingMunicipios) const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())),
                  if (_errorMunicipios != null) Center(child: Text(_errorMunicipios!, style: TextStyle(color: colorScheme.error))),
                  if (!_loadingMunicipios && _errorMunicipios == null && _selectedEstado != null)
                    _buildDropdownField<Municipio>(
                      label: 'Município',
                      hint: 'Selecione o Município',
                      value: _selectedMunicipio,
                      items: _municipios.map((Municipio municipio) {
                        return DropdownMenuItem<Municipio>(
                          value: municipio,
                          child: Text(municipio.nome),
                        );
                      }).toList(),
                      onChanged: (Municipio? newValue) {
                        setState(() {
                          _selectedMunicipio = newValue;
                        });
                      },
                      validator: (value) => value == null ? 'Selecione um município' : null,
                    ),
                  if (_selectedEstado != null) const SizedBox(height: 20), // Espacio solo si se muestra el dropdown de municipio

                  _buildTextField(
                    controller: _neighborhoodController,
                    label: 'Bairro',
                    hint: 'Seu bairro',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o bairro';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _streetController,
                    label: 'Logradouro (Rua, Av, etc.)',
                    hint: 'Nome da sua rua/avenida',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o logradouro';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _numberController,
                    label: 'Número',
                    hint: 'Ex: 123',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o número';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _complementController,
                    label: 'Complemento (Opcional)',
                    hint: 'Ex: Apto 101, Bloco B',
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _registerFreelancerAndContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A78ED), // Color específico solicitado
                      // foregroundColor: Colors.white, // Ya debería venir del tema si el backgroundColor es oscuro
                      // padding y textStyle vienen del tema
                    ),
                    child: const Text('Continuar'),
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

1.  **Estructura General:**
    *   El `body` ahora está envuelto en `Center -> SingleChildScrollView -> Padding -> ConstrainedBox -> Form`. Esto asegura que el formulario esté centrado, tenga un ancho máximo, y sea scrollable si el contenido es muy largo.
    *   Se usa `padding` general y `SizedBox` para espaciar los elementos de forma más consistente.
2.  **Labels Externos para Campos:**
    *   He creado métodos helper `_buildTextField` y `_buildDropdownField` para reducir la repetición. Estos métodos incluyen un `Text` widget para el `label` encima del campo, como en tu CSS. El estilo de estos labels se toma de `textTheme.labelMedium`.
3.  **TextFormFields y DropdownButtonFormFields:**
    *   Su `InputDecoration` ahora es más simple, ya que la mayoría de los estilos (bordes, color de relleno, padding interno) provienen del `inputDecorationTheme` definido en `main.dart`. Solo se especifican `hintText` o `suffixIcon` cuando es necesario.
    *   El campo de teléfono usa `suffixIcon` para mostrar la nota de WhatsApp de forma más integrada (en lugar de `helperText` que ocupa más espacio).
    *   Se añadieron iconos para mostrar/ocultar contraseña.
4.  **Títulos de Sección:**
    *   "Crie sua conta de Freelancer" usa `textTheme.displayLarge`.
    *   "Endereço" usa `textTheme.displayMedium`.
5.  **Botón "Continuar":**
    *   Mantiene el color `0xFF0A78ED` que especificaste. El resto del estilo (padding, forma, estilo de texto) debería heredarse del `elevatedButtonTheme` de `main.dart`.

**Después de reemplazar y guardar `lib/screens/register_freelancer_screen.dart`:**

*   **Reinicia completamente tu aplicación.**
*   Navega a la pantalla de Registro de Freelancer.

Deberías ver un cambio significativo en la apariencia, alineándose más con el estilo global que definimos: fuente Work Sans, campos de formulario consistentes, labels encima de los campos, y el botón con el estilo del tema (aunque con el color azul específico que solicitaste para este).

Avísame cómo se ve y si hay algo que ajustar en esta pantalla. Luego, pasaremos a `register_employer_screen.dart`.
