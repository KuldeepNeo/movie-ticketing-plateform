import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/movie_model.dart';

class AdminMovieState {
  final List<MovieModel> movies;
  final int page;
  final int limit;
  final int total;
  final String? search;
  final String? status;
  final bool isLoading;
  final String? errorMessage;

  AdminMovieState({
    required this.movies,
    required this.page,
    required this.limit,
    required this.total,
    this.search,
    this.status,
    this.isLoading = false,
    this.errorMessage,
  });

  factory AdminMovieState.initial() => AdminMovieState(
        movies: [],
        page: 1,
        limit: 20,
        total: 0,
      );

  AdminMovieState copyWith({
    List<MovieModel>? movies,
    int? page,
    int? limit,
    int? total,
    String? search,
    String? status,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AdminMovieState(
      movies: movies ?? this.movies,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      search: search ?? this.search,
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AdminMovieNotifier extends Notifier<AdminMovieState> {
  @override
  AdminMovieState build() {
    return AdminMovieState.initial();
  }

  Future<void> fetchMovies({
    int? page,
    String? search,
    String? status,
  }) async {
    final currentPage = page ?? state.page;
    final currentSearch = search ?? state.search;
    final currentStatus = status ?? state.status;

    state = state.copyWith(
      isLoading: true,
      page: currentPage,
      search: currentSearch,
      status: currentStatus,
    );

    try {
      final dio = ref.read(dioProvider);
      final queryParameters = {
        'page': currentPage,
        'limit': state.limit,
        if (currentSearch != null && currentSearch.isNotEmpty) 'search': currentSearch,
        if (currentStatus != null && currentStatus.isNotEmpty) 'status': currentStatus,
      };

      final response = await dio.get(
        ApiConstants.adminMovies,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as List;
        final meta = response.data['meta'];
        
        state = state.copyWith(
          movies: data.map((json) => MovieModel.fromJson(json)).toList(),
          total: meta['total'] as int,
          page: meta['page'] as int,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Failed to load movies.');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.toString();
      state = state.copyWith(isLoading: false, errorMessage: msg);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> createMovie(Map<String, dynamic> movieData) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        ApiConstants.adminMovies,
        data: movieData,
      );

      if (response.statusCode == 201) {
        state = state.copyWith(isLoading: false);
        await fetchMovies(page: 1); // reload list from page 1
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

  Future<bool> updateMovie(int id, Map<String, dynamic> movieData) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.put(
        ApiConstants.adminMovie(id),
        data: movieData,
      );

      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        await fetchMovies(); // reload list
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

  Future<bool> deleteMovie(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.delete(ApiConstants.adminMovie(id));

      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        await fetchMovies(); // reload list
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

final adminMovieProvider = NotifierProvider<AdminMovieNotifier, AdminMovieState>(() {
  return AdminMovieNotifier();
});
