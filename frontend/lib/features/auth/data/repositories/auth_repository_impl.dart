import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../data_sources/auth_api_client.dart';
import '../../../../core/local_storage/secure_storage_service.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthApiClient _apiClient;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl(this._apiClient, this._secureStorage);

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.register(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      return UserEntity.fromJson(response['data']);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.login(
        email: email,
        password: password,
      );
      
      final data = response['data'];
      final userJson = data['user'];
      final accessToken = data['access_token'];
      final refreshToken = data['refresh_token'];

      // Persist Access & Refresh tokens in secure local storage
      await _secureStorage.saveAccessToken(accessToken);
      await _secureStorage.saveRefreshToken(refreshToken);

      return UserEntity.fromJson(userJson);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.logout();
    } catch (_) {
      // Suppress network errors on logout to ensure local tokens are cleared
    } finally {
      await _secureStorage.clearTokens();
    }
  }

  @override
  Future<UserEntity> fetchProfile() async {
    try {
      final response = await _apiClient.me();
      return UserEntity.fromJson(response['data']);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Exception _parseError(DioException e) {
    if (e.response != null && e.response!.data != null && e.response!.data is Map) {
      final message = e.response!.data['message'];
      if (message != null) {
        return Exception(message.toString());
      }
    }
    return Exception(e.message ?? 'An unknown network error occurred.');
  }
}

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authApiClientProvider),
    ref.read(secureStorageServiceProvider),
  );
});
