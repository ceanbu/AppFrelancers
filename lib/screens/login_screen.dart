import 'package:flutter/material.dart';
import 'package:jobbit/screens/role_selection_screen.dart';
// import 'package:jobbit/screens/forgot_password_screen.dart'; // Si la tienes
// import 'package:jobbit/screens/dashboard_screen.dart'; // O a donde deba ir después del login

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      // Lógica de inicio de sesión (simulada)
      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');
      print('Remember me: $_rememberMe');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Iniciando sesión... (simulado)')),
      );
      // TODO: Implementar lógica de autenticación real
      // Si es exitoso, navegar al dashboard o pantalla principal
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const DashboardScreen()),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // appBar: AppBar( // Opcional, si tu diseño de login no tiene AppBar
      //   title: const Text('WorkFlex Login'),
      // ),
      body: Center( // Centra el contenido en la pantalla
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0), // Padding general del container
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400), // Ancho máximo del formulario
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Puedes añadir un logo o título aquí si quieres
                  // FlutterLogo(size: 80),
                  // SizedBox(height: 30),
                  Text(
                    'Bem-vindo de volta!', // Título h1-like
                    textAlign: TextAlign.center,
                    style: textTheme.displayLarge?.copyWith(color: colorScheme.onBackground),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Faça login para continuar.', // Subtítulo
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 30),

                  // Campo Email
                  Text('Email', style: textTheme.labelMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    // La decoración base viene del theme, aquí puedes añadir hints o iconos
                    decoration: const InputDecoration(
                      hintText: 'seuemail@example.com',
                      prefixIcon: Icon(Icons.alternate_email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Por favor, insira um email válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Campo Senha
                  Text('Senha', style: textTheme.labelMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      hintText: 'Sua senha',
                      prefixIcon: const Icon(Icons.lock_outline),
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
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira sua senha';
                      }
                      if (value.length < 6) {
                        return 'Senha deve ter no mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Remember me y Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (bool? value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            activeColor: colorScheme.primary,
                          ),
                          Text('Lembrar-me', style: textTheme.bodyMedium),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navegar para a tela de esqueci minha senha
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Página "Esqueci minha senha" não implementada.')),
                          );
                        },
                        child: Text('Esqueceu a senha?', style: textTheme.bodySmall?.copyWith(color: colorScheme.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Botón Iniciar Sesión
                  ElevatedButton(
                    onPressed: _login,
                    // El estilo principal viene del elevatedButtonTheme
                    child: const Text('Iniciar Sesión'),
                  ),
                  const SizedBox(height: 20),

                  // Footer para registrarse
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Não tem uma conta?', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7))),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                          );
                        },
                        child: Text('Cadastre-se', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                      ),
                    ],
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

**Cambios realizados en este código:**

1.  **Estructura General:**
    *   Se usa `Center` y `SingleChildScrollView` para manejar contenido que podría exceder la altura de la pantalla y para centrar el formulario.
    *   `ConstrainedBox` limita el ancho máximo del formulario a 400px, como en el CSS.
    *   El `Scaffold` usará el `scaffoldBackgroundColor` del `ThemeData`.
2.  **Textos:**
    *   Los títulos y otros textos usan `textTheme` (ej. `textTheme.displayLarge`, `textTheme.bodyMedium`, `textTheme.labelMedium`).
    *   Se han ajustado los colores para que coincidan con los `onBackground` y `onSurface` del `ColorScheme` para mejor adaptabilidad a temas oscuros/claros si se implementaran.
3.  **TextFormFields:**
    *   Ahora tienen un `Text` widget separado como `label` encima del campo, como es común en muchos diseños web y como tu CSS lo sugiere (`label { display: block; ... }`).
    *   La `InputDecoration` se simplifica ya que mucho del estilo (bordes, colores de borde, relleno, padding interno) vendrá del `inputDecorationTheme` en `main.dart`. Solo se añaden `hintText` y `prefixIcon`/`suffixIcon` específicos.
4.  **Checkbox `Lembrar-me`:**
    *   Usa el `activeColor` del `colorScheme.primary`.
5.  **Botón `Iniciar Sesión`:**
    *   Es un `ElevatedButton` que tomará su estilo principal del `elevatedButtonTheme`.
6.  **Enlaces `Esqueceu a senha?` y `Cadastre-se`:**
    *   Son `TextButton` que tomarán su estilo del `textButtonTheme` (color primario).

**Después de reemplazar el contenido y guardar `lib/screens/login_screen.dart`:**

*   **Reinicia completamente tu aplicación.**
*   Observa la pantalla de Login. Debería tener un aspecto mucho más cercano al CSS que proporcionaste:
    *   Fuente Work Sans.
    *   Colores de fondo y texto según el tema.
    *   Campos de texto con bordes redondeados y el estilo definido.
    *   Botón de "Iniciar Sesión" azul y con el estilo del tema.
    *   Enlaces en color azul.

Avísame cuando hayas hecho esto y si la pantalla de login se ve como esperas. Luego pasaremos a la siguiente pantalla.
