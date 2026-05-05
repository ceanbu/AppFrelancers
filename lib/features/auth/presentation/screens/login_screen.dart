import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workflex/core/constants/app_colors.dart';
import 'package:workflex/core/constants/app_text_styles.dart';
import 'package:workflex/core/widgets/wf_button.dart';
import 'package:workflex/core/widgets/wf_text_field.dart';
import 'package:workflex/core/utils/validators.dart';
import 'package:workflex/core/router/app_router.dart';
import '../providers/auth_provider.dart';

/// A7 â€” Pantalla de Inicio de SesiÃ³n (RF1.6)
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _rememberSession = false; // RF1.6.1

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(loginProvider.notifier).login(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          rememberSession: _rememberSession,
        );
    if (success && mounted) {
      // El router redirigirÃ¡ automÃ¡ticamente al dashboard correspondiente
      // basÃ¡ndose en el rol guardado en Firestore
      context.go('/freelancer/jobs'); // placeholder, ajustar con rol real
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Iniciar SesiÃ³n'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text('Bienvenido de nuevo', style: AppTextStyles.displayMedium),
                const SizedBox(height: 8),
                Text(
                  'IniciÃ¡ sesiÃ³n para continuar',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                WFTextField(
                  hint: 'tu@email.com',
                  label: 'Email',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidators.validateEmail,
                ),
                const SizedBox(height: 16),

                WFTextField(
                  hint: 'MÃ­nimo 6 caracteres',
                  label: 'ContraseÃ±a',
                  controller: _passwordCtrl,
                  obscureText: true, // RF1.6 + RNF3.1.7 (ojo incluido en widget)
                  validator: AppValidators.validatePassword,
                ),
                const SizedBox(height: 8),

                // RF1.6.1 â€” Recordar sesiÃ³n
                Row(
                  children: [
                    Checkbox(
                      value: _rememberSession,
                      onChanged: (v) =>
                          setState(() => _rememberSession = v ?? false),
                      activeColor: AppColors.primary,
                    ),
                    Text(
                      'Recordar sesiÃ³n',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {}, // TODO: Recuperar contraseÃ±a
                      child: Text(
                        'Â¿Olvidaste tu contraseÃ±a?',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Error message
                if (loginState.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            loginState.error!,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                WFButton(
                  label: 'Iniciar SesiÃ³n',
                  onPressed: _login,
                  isLoading: loginState.isLoading,
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Â¿No tenÃ©s cuenta? ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/'),
                      child: Text(
                        'Registrate',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
