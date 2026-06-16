import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/theater_model.dart';

class AdminTheaterState {
  final List<TheaterModel> theaters;
  final bool isLoading;
  final String? errorMessage;

  AdminTheaterState({
    required this.theaters,
    this.isLoading = false,
    this.errorMessage,
  });

  factory AdminTheaterState.initial() => AdminTheaterState(theaters: []);

  AdminTheaterState copyWith({
    List<TheaterModel>? theaters,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AdminTheaterState(
      theaters: theaters ?? this.theaters,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AdminTheaterNotifier extends Notifier<AdminTheaterState> {
  @override
  AdminTheaterState build() {
    return AdminTheaterState.initial();
  }

  Future<void> fetchTheaters({int? cityId, String? status}) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final queryParameters = {
        if (cityId != null) 'city_id': cityId,
        if (status != null) 'status': status,
      };

      final response = await dio.get(
        ApiConstants.adminTheaters,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as List;
        state = state.copyWith(
          theaters: data.map((json) => TheaterModel.fromJson(json)).toList(),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Failed to load theaters.');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.toString();
      state = state.copyWith(isLoading: false, errorMessage: msg);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> createTheater(Map<String, dynamic> theaterData) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        ApiConstants.adminTheaters,
        data: theaterData,
      );

      if (response.statusCode == 201) {
        state = state.copyWith(isLoading: false);
        await fetchTheaters();
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.toString();
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateTheater(int id, Map<String, dynamic> theaterData) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.put(
        ApiConstants.adminTheater(id),
        data: theaterData,
      );

      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        await fetchTheaters();
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.toString();
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteTheater(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.delete(ApiConstants.adminTheater(id));

      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        await fetchTheaters();
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.toString();
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final adminTheaterProvider = NotifierProvider<AdminTheaterNotifier, AdminTheaterState>(() {
  return AdminTheaterNotifier();
});
