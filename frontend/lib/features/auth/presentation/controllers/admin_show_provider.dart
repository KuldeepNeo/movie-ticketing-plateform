import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/show_model.dart';

class AdminShowState {
  final List<ShowModel> shows;
  final int page;
  final int limit;
  final int total;
  final int? movieIdFilter;
  final int? screenIdFilter;
  final String? statusFilter;
  final bool isLoading;
  final String? errorMessage;

  AdminShowState({
    required this.shows,
    required this.page,
    required this.limit,
    required this.total,
    this.movieIdFilter,
    this.screenIdFilter,
    this.statusFilter,
    this.isLoading = false,
    this.errorMessage,
  });

  factory AdminShowState.initial() => AdminShowState(
        shows: [],
        page: 1,
        limit: 20,
        total: 0,
      );

  AdminShowState copyWith({
    List<ShowModel>? shows,
    int? page,
    int? limit,
    int? total,
    int? movieIdFilter,
    int? screenIdFilter,
    String? statusFilter,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AdminShowState(
      shows: shows ?? this.shows,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      movieIdFilter: movieIdFilter ?? this.movieIdFilter,
      screenIdFilter: screenIdFilter ?? this.screenIdFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Reset error if not provided
    );
  }
}

class AdminShowNotifier extends Notifier<AdminShowState> {
  @override
  AdminShowState build() {
    return AdminShowState.initial();
  }

  Future<void> fetchShows({
    int? page,
    int? movieId,
    int? screenId,
    String? status,
    String? showDate,
  }) async {
    final currentPage = page ?? state.page;
    final currentMovieId = movieId ?? state.movieIdFilter;
    final currentScreenId = screenId ?? state.screenIdFilter;
    final currentStatus = status ?? state.statusFilter;

    state = state.copyWith(
      isLoading: true,
      page: currentPage,
      movieIdFilter: currentMovieId,
      screenIdFilter: currentScreenId,
      statusFilter: currentStatus,
    );

    try {
      final dio = ref.read(dioProvider);
      final queryParameters = {
        'page': currentPage,
        'limit': state.limit,
        if (currentMovieId != null) 'movie_id': currentMovieId,
        if (currentScreenId != null) 'screen_id': currentScreenId,
        if (currentStatus != null && currentStatus.isNotEmpty) 'status': currentStatus,
        if (showDate != null && showDate.isNotEmpty) 'show_date': showDate,
      };

      final response = await dio.get(
        ApiConstants.adminShows,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as List;
        final meta = response.data['meta'];

        state = state.copyWith(
          shows: data.map((json) => ShowModel.fromJson(json)).toList(),
          total: meta['total'] as int,
          page: meta['page'] as int,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Failed to load shows.');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.toString();
      state = state.copyWith(isLoading: false, errorMessage: msg);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> createShow(Map<String, dynamic> showData) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        ApiConstants.adminShows,
        data: showData,
      );

      if (response.statusCode == 201) {
        state = state.copyWith(isLoading: false);
        await fetchShows(page: 1); // reload
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

  Future<bool> updateShow(int id, Map<String, dynamic> showData) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.put(
        ApiConstants.adminShow(id),
        data: showData,
      );

      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        await fetchShows(); // reload
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

  Future<bool> cancelShow(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.delete(ApiConstants.adminShow(id));

      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        await fetchShows(); // reload
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

final adminShowProvider = NotifierProvider<AdminShowNotifier, AdminShowState>(() {
  return AdminShowNotifier();
});
