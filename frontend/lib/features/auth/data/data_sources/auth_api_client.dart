import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

class AuthApiClient {
  final Dio _dio;

  AuthApiClient(this._dio);

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _dio.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );
    return response.data;
  }

  Future<void> logout() async {
    await _dio.post(ApiConstants.logout);
  }

  Future<Map<String, dynamic>> me() async {
    final response = await _dio.get(ApiConstants.me);
    return response.data;
  }
}

final authApiClientProvider = Provider<AuthApiClient>((ref) {
  return AuthApiClient(ref.read(dioProvider));
});
