import 'package:flutter/material.dart';
import 'package:jobbit/screens/register_employer_screen.dart';
import 'package:jobbit/screens/register_freelancer_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Acceder a los estilos de texto definidos en ThemeData
    final TextTheme textTheme = Theme.of(context).textTheme;
    // Acceder al color primario para los botones si no se usa el ElevatedButtonTheme directamente
    // final Color primaryButtonColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha seu Perfil'),
        // El estilo del AppBar ya debería venir del ThemeData en main.dart
      ),
      body: Container(
        // Opcional: Si quieres un color de fondo específico para el cuerpo de esta pantalla
        // que sea diferente al scaffoldBackgroundColor general, puedes añadirlo aquí.
        // color: Theme.of(context).colorScheme.background,
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400), // Similar al max-width del CSS
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Como você quer usar o WorkFlex?',
                  textAlign: TextAlign.center,
                  style: textTheme.displayLarge?.copyWith( // Usando h1-like style
                    color: Theme.of(context).colorScheme.onBackground, // Color de texto principal
                  ) ?? const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12), // Reducido un poco el espacio
                Text(
                  'Selecione o tipo de conta que você gostaria de criar.', // Subtítulo
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith( // Usando .subtitle-like style
                     color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ) ?? const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                ElevatedButton.icon(
                  icon: const Icon(Icons.person_search_outlined, size: 24), // Icono actualizado
                  label: const Text('Sou Freelancer'),
                  style: ElevatedButton.styleFrom(
                    // El estilo base viene del theme, aquí podemos hacer overrides si es necesario
                    // backgroundColor: primaryButtonColor, // Ya debería venir del tema
                    // foregroundColor: Colors.white, // Ya debería venir del tema
                    textStyle: textTheme.labelLarge, // Estilo de texto para botones
                    padding: const EdgeInsets.symmetric(vertical: 16), // Ajuste de padding
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterFreelancerScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20), // Espacio entre botones

                ElevatedButton.icon(
                  icon: const Icon(Icons.business_center_outlined, size: 24), // Icono actualizado
                  label: const Text('Sou Empregador'),
                  style: ElevatedButton.styleFrom(
                    // Si quisiéramos que este fuera un botón secundario según el CSS:
                    // backgroundColor: Theme.of(context).brightness == Brightness.light
                    //                     ? const Color(0xFFF0F0F0) // secondaryButtonBgColor
                    //                     : Theme.of(context).colorScheme.surfaceVariant,
                    // foregroundColor: Theme.of(context).brightness == Brightness.light
                    //                     ? const Color(0xFF333333) // secondaryButtonTextColor
                    //                     : Theme.of(context).colorScheme.onSurfaceVariant,
                    // textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
                    // Pero por ahora, lo dejaremos como primario también para consistencia visual fuerte.
                    // Si quieres diferenciarlo, puedes aplicar los estilos de secundario aquí.
                    textStyle: textTheme.labelLarge,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterEmployerScreen()),
                    );
                  },
                ),
                const SizedBox(height: 40),
                 // Texto al final del formulario (si aplica)
                Text(
                  'Ao continuar, você concorda com nossos Termos de Serviço e Política de Privacidade.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith( // .form-footer o .security-note like
                     color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ) ?? const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**Cambios Clave en este código:**

1.  **Uso de `ElevatedButton.icon`:** Se reemplazan los `Card` con `InkWell` por `ElevatedButton.icon` para un look más de botón estándar.
2.  **Estilos del Tema:**
    *   Los `ElevatedButton` tomarán automáticamente el estilo base definido en `elevatedButtonTheme` en tu `main.dart` (color de fondo, color de texto, fuente, padding, forma).
    *   Los `Text` widgets ahora usan `textTheme.displayLarge`, `textTheme.bodyMedium`, `textTheme.bodySmall` para intentar replicar los estilos de `h1`, `.subtitle`, y `.form-footer`/`.security-note` de tu CSS, tomando los colores y la fuente `WorkSans` del tema.
3.  **Color de Botones:** Ambos botones usarán el estilo primario por defecto. Si quisieras que uno fuera "secundario" (con fondo gris claro como en tu CSS `.btn-secondary`), tendrías que aplicar un `style` específico a ese botón, como he comentado en el código. Por ahora, ambos son azules.
4.  **Iconos:** He usado `Icons.person_search_outlined` y `Icons.business_center_outlined` que son un poco más estándar.
5.  **Padding y Spacing:** Ajustados para una apariencia más limpia.
6.  **`ConstrainedBox`:** Para limitar el ancho del contenido central, similar al `max-width: 450px;` de tu CSS.
7.  **Textos:** Actualizados algunos textos para que sean más coherentes con una pantalla de selección de rol.

**Después de reemplazar el contenido y guardar `lib/screens/role_selection_screen.dart`:**

*   **Reinicia completamente tu aplicación** (stop y run).
*   Navega a la pantalla de selección de rol.

Deberías ver que los botones ahora son `ElevatedButton` azules, la fuente es Work Sans, y los textos tienen un estilo más acorde al tema general. El fondo de la pantalla debería ser el `appBackgroundColor` (`#f5f5f5`) y el `AppBar` debería tener fondo blanco.

Avísame si esto se ve como esperas o si necesitas más ajustes en esta pantalla. Una vez que estés conforme, podemos pasar a la siguiente.
