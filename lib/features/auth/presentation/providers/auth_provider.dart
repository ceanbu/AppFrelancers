import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stream del estado de autenticación de Firebase
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Provider del usuario actual
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

/// Servicio de autenticación
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
    required bool rememberSession,
  }) async {
    // RF1.6 — Persistencia de sesión según checkbox "Recordar sesión"
    await _auth.setPersistence(
      rememberSession ? Persistence.LOCAL : Persistence.SESSION,
    );
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUser({
    required String email,
    required String password,
  }) async {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Estado del login
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
      case 'user-not-found':
        return 'No existe una cuenta con ese email';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'El email no es válido';
      case 'user-disabled':
        return 'Esta cuenta fue deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Intentá más tarde';
      default:
        return 'Error al iniciar sesión. Intentá nuevamente';
    }
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(ref.watch(authServiceProvider));
});
