import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../core/local_storage/secure_storage_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);
  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);
  factory AuthState.authenticated(UserEntity user) => AuthState(status: AuthStatus.authenticated, user: user);
  factory AuthState.unauthenticated() => const AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.error(String message) => AuthState(status: AuthStatus.error, errorMessage: message);

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Asynchronous session initialization scheduled on build
    Future.microtask(() => initializeSession());
    return AuthState.initial();
  }

  /**
   * Auto-run on startup: Checks secure storage for token. If found, fetches active profile.
   */
  Future<void> initializeSession() async {
    state = AuthState.loading();
    final secureStorage = ref.read(secureStorageServiceProvider);
    final authRepository = ref.read(authRepositoryProvider);

    try {
      final token = await secureStorage.getAccessToken();
      if (token != null) {
        final profile = await authRepository.fetchProfile();
        state = AuthState.authenticated(profile);
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (_) {
      // Invalidation fallback: clear storage
      await secureStorage.clearTokens();
      state = AuthState.unauthenticated();
    }
  }

  /**
   * Register and automatically log in.
   */
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = AuthState.loading();
    final authRepository = ref.read(authRepositoryProvider);

    try {
      await authRepository.register(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      // Auto-login after registration
      await login(email: email, password: password);
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /**
   * Authenticate and login.
   */
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = AuthState.loading();
    final authRepository = ref.read(authRepositoryProvider);

    try {
      final user = await authRepository.login(email: email, password: password);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /**
   * Clean local and remote sessions.
   */
  Future<void> logout() async {
    state = AuthState.loading();
    final authRepository = ref.read(authRepositoryProvider);

    try {
      await authRepository.logout();
    } finally {
      state = AuthState.unauthenticated();
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});
