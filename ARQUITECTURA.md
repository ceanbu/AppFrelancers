# WorkFlex — Estructura del Proyecto

## Arquitectura: Feature-First + Clean Architecture

```
workflex/
├── lib/
│   ├── main.dart                        # Entry point
│   ├── firebase_options.dart            # Config Firebase (generado por FlutterFire CLI)
│   │
│   ├── core/                            # Código compartido entre features
│   │   ├── constants/
│   │   │   ├── app_colors.dart          # Paleta de colores
│   │   │   ├── app_text_styles.dart     # Tipografías
│   │   │   └── app_strings.dart         # Textos/labels
│   │   ├── router/
│   │   │   └── app_router.dart          # Rutas con GoRouter
│   │   ├── theme/
│   │   │   └── app_theme.dart           # ThemeData global
│   │   ├── widgets/                     # Widgets reutilizables
│   │   │   ├── wf_button.dart
│   │   │   ├── wf_text_field.dart
│   │   │   ├── wf_skill_chip.dart
│   │   │   ├── wf_calendar.dart         # Componente calendario (RF1.3 / RF2.2.A)
│   │   │   └── wf_loading.dart
│   │   └── utils/
│   │       ├── validators.dart          # Validaciones (edad, horarios)
│   │       └── extensions.dart
│   │
│   ├── features/
│   │   ├── auth/                        # RF1.1, RF1.6, RF1.7
│   │   │   ├── data/
│   │   │   │   ├── auth_repository.dart
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── domain/
│   │   │   │   └── user_role.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   ├── role_selection_screen.dart   # A1
│   │   │       │   └── login_screen.dart            # A7
│   │   │       └── providers/
│   │   │           └── auth_provider.dart
│   │   │
│   │   ├── onboarding_freelancer/       # RF1.2 → RF1.4 → RF1.8
│   │   │   ├── data/
│   │   │   │   └── freelancer_repository.dart
│   │   │   ├── domain/
│   │   │   │   ├── freelancer.dart
│   │   │   │   └── work_experience.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   ├── step1_personal_info_screen.dart   # A2
│   │   │       │   ├── step1b_about_me_screen.dart       # A3
│   │   │       │   ├── step2_availability_screen.dart    # A5
│   │   │       │   ├── step3_skills_screen.dart          # A4/N4
│   │   │       │   └── step4_experience_screen.dart      # A(Nuevo)
│   │   │       └── providers/
│   │   │           └── onboarding_provider.dart
│   │   │
│   │   ├── onboarding_employer/         # RF1.5
│   │   │   ├── data/
│   │   │   │   └── employer_repository.dart
│   │   │   ├── domain/
│   │   │   │   └── employer.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   └── employer_register_screen.dart     # A6
│   │   │       └── providers/
│   │   │           └── employer_onboarding_provider.dart
│   │   │
│   │   ├── employer_dashboard/          # RF2.1 → RF2.7
│   │   │   ├── data/
│   │   │   │   └── vacancy_repository.dart
│   │   │   ├── domain/
│   │   │   │   ├── vacancy.dart
│   │   │   │   └── applicant.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   ├── employer_home_screen.dart         # B1
│   │   │       │   ├── create_vacancy_step1_screen.dart  # B2
│   │   │       │   ├── create_vacancy_step2_screen.dart  # B2.1
│   │   │       │   ├── vacancy_detail_screen.dart        # B3
│   │   │       │   └── applicants_screen.dart
│   │   │       └── providers/
│   │   │           └── vacancy_provider.dart
│   │   │
│   │   ├── freelancer_jobs/             # RF3.1 → RF3.5
│   │   │   ├── data/
│   │   │   │   └── jobs_repository.dart
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   ├── jobs_feed_screen.dart             # C1
│   │   │       │   ├── job_detail_screen.dart            # C2
│   │   │       │   └── my_applications_screen.dart       # C3
│   │   │       └── providers/
│   │   │           └── jobs_provider.dart
│   │   │
│   │   ├── match/                       # RF4.1 → RF4.4, RF5.x, RF6.x
│   │   │   ├── data/
│   │   │   │   └── match_repository.dart
│   │   │   └── presentation/
│   │   │       └── providers/
│   │   │           └── match_provider.dart
│   │   │
│   │   ├── profile/                     # Perfil freelancer y empleador
│   │   │   └── presentation/
│   │   │       ├── screens/
│   │   │       │   ├── freelancer_profile_screen.dart
│   │   │       │   └── employer_profile_screen.dart
│   │   │       └── providers/
│   │   │           └── profile_provider.dart
│   │   │
│   │   └── location/                    # API IBGE (RF1.2 / RF1.5 / RF2.2.B)
│   │       ├── data/
│   │       │   └── ibge_repository.dart
│   │       ├── domain/
│   │       │   ├── estado.dart
│   │       │   └── municipio.dart
│   │       └── providers/
│   │           └── location_provider.dart
│
├── assets/
│   ├── images/
│   ├── icons/
│   ├── animations/       # Lottie JSONs
│   └── fonts/
│
├── firebase.json
├── .firebaserc
└── pubspec.yaml
```

## Convenciones

- **Providers**: Riverpod con `@riverpod` annotation
- **Naming**: `snake_case` para archivos, `PascalCase` para clases
- **Models**: Inmutables con `copyWith`, `toMap`, `fromMap`
- **Colores**: Siempre usar `AppColors.*`, nunca hardcodear
- **Navegación**: Solo `context.go()` / `context.push()` de GoRouter

## Orden de desarrollo recomendado

1. ✅ Estructura base + tema + router
2. 🔲 Auth (selección de rol → login → registro)
3. 🔲 Onboarding Freelancer (4 pasos)
4. 🔲 Onboarding Empleador
5. 🔲 Dashboard Empleador + Crear Vacante
6. 🔲 Feed Freelancer + Postulación
7. 🔲 Match + WhatsApp
8. 🔲 Notificaciones (FCM)
