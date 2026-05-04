import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

// Detecta si es la primera vez que se abre la app
final isFirstLaunchProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final isFirst = prefs.getBool('is_first_launch') ?? true;
  return isFirst;
});

// Marca que ya no es la primera vez
Future<void> markFirstLaunchDone() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_first_launch', false);
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
    required bool rememberSession,
  }) async {
    await _auth.setPersistence(
      rememberSession ? Persistence.LOCAL : Persistence.SESSION,
    );
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> createUser({
    required String email,
    required String password,
  }) async {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  // Nuevo método: registrar freelancer con todos los datos
  Future<void> registerFreelancer({
    required String email,
    required String password,
    required String fullName,
    required String documentType,
    required String documentNumber,
    required DateTime birthDate,
    required String phone,
    String? aboutMe,
    required Map<String, String> address,
  }) async {
    // 1. Crear usuario en Firebase Auth
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final userId = userCredential.user!.uid;

    // 2. Guardar perfil del freelancer en Firestore
    final freelancerData = {
      'fullName': fullName,
      'documentType': documentType,
      'documentNumber': documentNumber, // En producción, cifrar antes
      'birthDate': birthDate.toIso8601String(),
      'phone': phone,
      'email': email,
      'aboutMe': aboutMe ?? '',
      'address': address,
      'skills': [],
      'experience': [],
      'availability': {},
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('freelancers').doc(userId).set(freelancerData);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class LoginState {
  final bool isLoading;
  final String? error;
  const LoginState({this.isLoading = false, this.error});
}

class LoginNotifier extends StateNotifier<LoginState> {
  final AuthService _authService;
  LoginNotifier(this._authService) : super(const LoginState());

  Future<bool> login({
    required String email,
    required String password,
    required bool rememberSession,
  }) async {
    state = const LoginState(isLoading: true);
    try {
      await _authService.signInWithEmail(
        email: email,
        password: password,
        rememberSession: rememberSession,
      );
      state = const LoginState();
      return true;
    } on FirebaseAuthException catch (e) {
      state = LoginState(error: _mapFirebaseError(e.code));
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found': return 'No existe una cuenta con ese email';
      case 'wrong-password': return 'Contrasena incorrecta';
      case 'invalid-email': return 'El email no es valido';
      case 'user-disabled': return 'Esta cuenta fue deshabilitada';
      case 'too-many-requests': return 'Demasiados intentos. Intenta mas tarde';
      default: return 'Error al iniciar sesion. Intenta nuevamente';
    }
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(ref.watch(authServiceProvider));
});
