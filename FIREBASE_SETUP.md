# 🔥 Configuración de Firebase para WorkFlex

## Paso 1 — Crear proyecto en Firebase Console

1. Ir a https://console.firebase.google.com
2. "Crear proyecto" → nombre: `workflex-app` (o el que prefieras)
3. Desactivar Google Analytics (no es necesario para V1.7)
4. Esperar que se cree el proyecto

---

## Paso 2 — Habilitar servicios necesarios

En el menú lateral de Firebase Console:

### Authentication
- Build → Authentication → "Comenzar"
- Sign-in method → Habilitar **Email/Password**

### Firestore Database
- Build → Firestore Database → "Crear base de datos"
- Elegir **modo de producción**
- Seleccionar región: **us-central1** (o southamerica-east1 para menor latencia)

### Cloud Messaging (FCM)
- Build → Messaging → automáticamente disponible

---

## Paso 3 — Instalar FlutterFire CLI

```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Asegurarse de que está en el PATH (agregar a ~/.bashrc o ~/.zshrc si no lo está)
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

---

## Paso 4 — Configurar el proyecto Flutter

```bash
# Desde la raíz del proyecto workflex/
cd workflex

# Instalar dependencias
flutter pub get

# Configurar Firebase (esto genera firebase_options.dart real)
flutterfire configure

# Seguir el wizard:
# - Seleccionar proyecto Firebase que creaste
# - Plataformas: Android (y iOS si lo necesitás en el futuro)
# - Esto va a crear/reemplazar lib/firebase_options.dart
```

---

## Paso 5 — Configurar google-services.json (Android)

FlutterFire CLI lo hace automáticamente, pero verificar que esté en:
```
android/app/google-services.json
```

Verificar que en `android/build.gradle` esté:
```gradle
classpath 'com.google.gms:google-services:4.4.0'
```

Y en `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'
```

---

## Paso 6 — Reglas de Firestore (Seguridad básica)

En Firebase Console → Firestore → Rules, pegar:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Freelancers solo pueden leer/escribir su propio perfil
    match /freelancers/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Empleadores solo pueden leer/escribir su propio perfil
    match /employers/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Vacantes: empleador dueño puede crear/editar, freelancers autenticados pueden leer
    match /vacancies/{vacancyId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
        resource.data.employerId == request.auth.uid;
      allow create: if request.auth != null;
    }

    // Postulaciones
    match /applications/{appId} {
      allow read: if request.auth != null &&
        (resource.data.freelancerId == request.auth.uid ||
         resource.data.employerId == request.auth.uid);
      allow create: if request.auth != null;
      allow update: if request.auth != null &&
        (resource.data.freelancerId == request.auth.uid ||
         resource.data.employerId == request.auth.uid);
    }

    // Habilidades (solo lectura para todos los autenticados)
    match /skills/{skillId} {
      allow read: if request.auth != null;
      allow write: if false; // Solo admin
    }
  }
}
```

---

## Paso 7 — Verificar que compila

```bash
flutter run
```

Si hay errores de `firebase_options.dart`, ejecutar nuevamente:
```bash
flutterfire configure
```

---

## Colecciones a crear en Firestore

Crear manualmente (o se crean automáticamente al registrar el primer usuario):

| Colección      | Descripción                            |
|----------------|----------------------------------------|
| `freelancers`  | Perfiles de freelancers                |
| `employers`    | Perfiles de empleadores                |
| `vacancies`    | Vacantes publicadas                    |
| `applications` | Postulaciones                          |
| `skills`       | Lista de habilidades (seed manual)     |

### Seed de habilidades (agregar manualmente en Firestore)

Crear colección `skills` con documentos:
- `{ "name": "Atención al cliente", "category": "gastronomia" }`
- `{ "name": "Cocina", "category": "gastronomia" }`
- `{ "name": "Barismo", "category": "gastronomia" }`
- `{ "name": "Servicio de salón", "category": "gastronomia" }`
- `{ "name": "Caja registradora", "category": "comercio" }`
- `{ "name": "Repositor", "category": "comercio" }`
- `{ "name": "Limpieza", "category": "general" }`
- `{ "name": "Seguridad", "category": "general" }`
- (agregar más según necesidad)
