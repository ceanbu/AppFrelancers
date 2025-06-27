import 'package:flutter/material.dart';
import 'package:jobbit/screens/login_screen.dart'; // Asegúrate que esta ruta sea correcta
import 'package:flutter_localizations/flutter_localizations.dart'; // Importación para localización
// import 'package:intl/date_symbol_data_local.dart'; // No es necesario aquí si se inicializa en la pantalla específica o se confía en flutter_localizations

void main() {
  // Si necesitas inicializar formatos de fecha específicos globalmente antes de runApp:
  // WidgetsFlutterBinding.ensureInitialized();
  // await initializeDateFormatting('es_ES', null); // o 'pt_BR'
  runApp(const MyApp());
}

// Definición de Colores según tu CSS
const Color primaryColor = Color(0xFF4A90E2); // Azul para botones primarios y enlaces
const Color primaryColorDark = Color(0xFF3A7BC8); // Azul más oscuro para hover/efectos
const Color secondaryButtonBgColor = Color(0xFFF0F0F0);
const Color secondaryButtonTextColor = Color(0xFF333333);
const Color appBackgroundColor = Color(0xFFF5F5F5);
const Color containerBackgroundColor = Colors.white;
const Color mainTextColor = Color(0xFF333333);
const Color titleH1Color = Color(0xFF222222);
const Color titleH2Color = Color(0xFF444444);
const Color subtitleColor = Color(0xFF666666);
const Color labelColor = Color(0xFF555555);
const Color inputBorderColor = Color(0xFFDDDDDD);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkFlex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Definición de la paleta de colores principal
        primaryColor: primaryColor,
        scaffoldBackgroundColor: appBackgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: primaryColorDark,
          background: appBackgroundColor,
          surface: containerBackgroundColor,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: mainTextColor,
          onSurface: mainTextColor,
          error: Colors.redAccent,
        ),

        fontFamily: 'WorkSans',

        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: titleH1Color), // h1
          displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: titleH2Color), // h2
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: mainTextColor), // AppBar titles, etc.
          bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: mainTextColor),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: mainTextColor),
          labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white), // For ElevatedButton
          labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: labelColor),
          bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: subtitleColor),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            textStyle: const TextStyle(
              fontFamily: 'WorkSans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0),
            ),
            elevation: 2,
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            textStyle: const TextStyle(
              fontFamily: 'WorkSans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: const BorderSide(color: inputBorderColor, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: const BorderSide(color: inputBorderColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: const BorderSide(color: primaryColor, width: 1.5),
          ),
          labelStyle: TextStyle(color: labelColor, fontFamily: 'WorkSans', fontWeight: FontWeight.w500, fontSize: 14),
          hintStyle: TextStyle(color: subtitleColor.withOpacity(0.8), fontFamily: 'WorkSans', fontWeight: FontWeight.w400),
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: containerBackgroundColor,
          foregroundColor: titleH1Color,
          elevation: 1.0,
          titleTextStyle: TextStyle(
            fontFamily: 'WorkSans',
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: titleH1Color,
          ),
          iconTheme: IconThemeData(color: titleH1Color),
        ),

        cardTheme: CardThemeData( // CORREGIDO AQUÍ
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
        ),

      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('pt', 'BR'),
      ],
      locale: const Locale('pt', 'BR'), // CAMBIADO A PORTUGUÉS COMO PREDETERMINADO - AJUSTA SI ES NECESARIO

      home: const LoginScreen(),
    );
  }
}
```

He aplicado la corrección a `CardThemeData` y también he cambiado el `locale` predeterminado a `'pt', 'BR'` ya que la mayoría de los textos de la UI que hemos estado usando están en portugués. Si prefieres español como predeterminado, simplemente cambia `Locale('pt', 'BR')` de nuevo a `Locale('es', 'ES')`.

Por favor, reemplaza el contenido de tu `main.dart` con este código, guarda y reinicia la aplicación. Avísame el resultado.
