import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_ticketing_app/features/auth/domain/entities/user_entity.dart';
import 'package:movie_ticketing_app/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:movie_ticketing_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:movie_ticketing_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:movie_ticketing_app/core/local_storage/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MockAuthRepository implements IAuthRepository {
  bool registerCalled = false;
  bool loginCalled = false;
  bool logoutCalled = false;
  bool fetchProfileCalled = false;

  UserEntity? mockUser;
  bool throwError = false;

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    registerCalled = true;
    if (throwError) throw Exception('Registration failed');
    return mockUser ?? UserEntity(id: 1, name: name, email: email, role: 'customer');
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    loginCalled = true;
    if (throwError) throw Exception('Invalid credentials');
    return mockUser ?? UserEntity(id: 1, name: 'Test User', email: email, role: 'customer');
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }

  @override
  Future<UserEntity> fetchProfile() async {
    fetchProfileCalled = true;
    if (throwError) throw Exception('Failed to fetch profile');
    return mockUser ?? const UserEntity(id: 1, name: 'Test User', email: 'test@example.com', role: 'customer');
  }
}

class MockSecureStorage extends SecureStorageService {
  String? accessToken;
  String? refreshToken;

  MockSecureStorage() : super(const FlutterSecureStorage());

  @override
  Future<void> saveAccessToken(String token) async {
    accessToken = token;
  }

  @override
  Future<String?> getAccessToken() async {
    return accessToken;
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    refreshToken = token;
  }

  @override
  Future<String?> getRefreshToken() async {
    return refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;
  }
}

void main() {
  late MockAuthRepository mockRepository;
  late MockSecureStorage mockStorage;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockAuthRepository();
    mockStorage = MockSecureStorage();
    mockRepository.mockUser = const UserEntity(id: 1, name: 'John Doe', email: 'john@example.com', role: 'customer');

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepository),
        secureStorageServiceProvider.overrideWithValue(mockStorage),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('Initial state is loading then unauthenticated when no token exists', () async {
    // Read provider, which triggers build() and initializeSession()
    final state = container.read(authControllerProvider);
    expect(state.status, AuthStatus.initial);

    // Wait for the microtask to finish initializeSession
    await container.read(authControllerProvider.notifier).initializeSession();
    
    final finalState = container.read(authControllerProvider);
    expect(finalState.status, AuthStatus.unauthenticated);
    expect(mockRepository.fetchProfileCalled, false);
  });

  test('Initial state is authenticated when token exists and profile succeeds', () async {
    mockStorage.accessToken = 'valid_token';

    // We call initializeSession to run with overridden values
    await container.read(authControllerProvider.notifier).initializeSession();

    final finalState = container.read(authControllerProvider);
    expect(finalState.status, AuthStatus.authenticated);
    expect(finalState.user?.name, 'John Doe');
    expect(mockRepository.fetchProfileCalled, true);
  });

  test('Login updates state to authenticated on success', () async {
    await container.read(authControllerProvider.notifier).login(email: 'john@example.com', password: 'SecureP@ss1');

    final finalState = container.read(authControllerProvider);
    expect(finalState.status, AuthStatus.authenticated);
    expect(finalState.user?.email, 'john@example.com');
  });

  test('Login updates state to error on failure', () async {
    mockRepository.throwError = true;

    await container.read(authControllerProvider.notifier).login(email: 'john@example.com', password: 'wrongPassword');

    final finalState = container.read(authControllerProvider);
    expect(finalState.status, AuthStatus.error);
    expect(finalState.errorMessage, 'Invalid credentials');
  });
}
