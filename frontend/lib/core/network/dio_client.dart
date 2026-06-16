import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../local_storage/secure_storage_service.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final secureStorage = ref.read(secureStorageServiceProvider);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Automatically attach JWT access token if available
        final accessToken = await secureStorage.getAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        // If unauthorized (401), try refreshing the access token
        if (error.response?.statusCode == 401) {
          final requestPath = error.requestOptions.path;

          // If the refresh call itself failed, clear tokens and exit
          if (requestPath == ApiConstants.refresh || requestPath == ApiConstants.login) {
            await secureStorage.clearTokens();
            return handler.next(error);
          }

          final refreshToken = await secureStorage.getRefreshToken();
          if (refreshToken != null) {
            try {
              // Use separate clean Dio client to execute refresh request
              final refreshDio = Dio(
                BaseOptions(
                  baseUrl: ApiConstants.baseUrl,
                  headers: {'Content-Type': 'application/json'},
                ),
              );

              final response = await refreshDio.post(
                ApiConstants.refresh,
                data: {'refresh_token': refreshToken},
              );

              if (response.statusCode == 200 && response.data != null) {
                final responseData = response.data;
                final String newAccessToken = responseData['data']['access_token'];

                // Persist new access token
                await secureStorage.saveAccessToken(newAccessToken);

                // Retry original request with the new credentials
                final options = error.requestOptions;
                options.headers['Authorization'] = 'Bearer $newAccessToken';

                final retryResponse = await dio.fetch(options);
                return handler.resolve(retryResponse);
              }
            } catch (refreshError) {
              // Token refresh failed, clear local credentials
              await secureStorage.clearTokens();
            }
          }
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
});
