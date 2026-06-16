import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_ticketing_app/features/auth/presentation/screens/login_screen.dart';
import 'package:movie_ticketing_app/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:movie_ticketing_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:movie_ticketing_app/features/auth/domain/entities/user_entity.dart';
import 'package:movie_ticketing_app/core/local_storage/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MockAuthRepository implements IAuthRepository {
  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    return UserEntity(id: 1, name: 'Test', email: email, role: 'customer');
  }

  @override
  Future<void> logout() async {}

  @override
  Future<UserEntity> fetchProfile() async {
    throw UnimplementedError();
  }
}

class MockSecureStorage extends SecureStorageService {
  MockSecureStorage() : super(const FlutterSecureStorage());
  
  @override
  Future<String?> getAccessToken() async => null;
  
  @override
  Future<String?> getRefreshToken() async => null;
  
  @override
  Future<void> clearTokens() async {}
}

void main() {
  testWidgets('LoginScreen renders inputs and validation triggers', (WidgetTester tester) async {
    final mockRepo = MockAuthRepository();
    final mockStorage = MockSecureStorage();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepo),
          secureStorageServiceProvider.overrideWithValue(mockStorage),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Let the initial session checking complete
    await tester.pumpAndSettle();

    // Verify input fields are rendered
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Trigger form validations directly via FormState to bypass scrolling/button tap animations
    final FormState formState = tester.state(find.byType(Form));
    formState.validate();
    await tester.pumpAndSettle();

    // Verify validation error feedback messages are displayed
    expect(find.text('Email address is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
  });
}
