import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/theater_model.dart';

class AdminScreenState {
  final List<ScreenModel> screens;
  final bool isLoading;
  final String? errorMessage;

  AdminScreenState({
    required this.screens,
    this.isLoading = false,
    this.errorMessage,
  });

  factory AdminScreenState.initial() => AdminScreenState(screens: []);

  AdminScreenState copyWith({
    List<ScreenModel>? screens,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AdminScreenState(
      screens: screens ?? this.screens,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AdminScreenNotifier extends Notifier<AdminScreenState> {
  @override
  AdminScreenState build() {
    return AdminScreenState.initial();
  }

  Future<void> fetchScreens(int theaterId) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiConstants.adminTheaterScreens(theaterId));

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as List;
        state = state.copyWith(
          screens: data.map((json) => ScreenModel.fromJson(json)).toList(),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Failed to load screens.');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.toString();
      state = state.copyWith(isLoading: false, errorMessage: msg);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> createScreen(int theaterId, Map<String, dynamic> screenData) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        ApiConstants.adminTheaterScreens(theaterId),
        data: screenData,
      );

      if (response.statusCode == 201) {
        state = state.copyWith(isLoading: false);
        await fetchScreens(theaterId);
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

  Future<bool> updateScreen(int id, int theaterId, Map<String, dynamic> screenData) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.put(
        ApiConstants.adminScreen(id),
        data: screenData,
      );

      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        await fetchScreens(theaterId);
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

  Future<bool> deleteScreen(int id, int theaterId) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.delete(ApiConstants.adminScreen(id));

      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        await fetchScreens(theaterId);
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

final adminScreenProvider = NotifierProvider<AdminScreenNotifier, AdminScreenState>(() {
  return AdminScreenNotifier();
});
