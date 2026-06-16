import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/movie_model.dart';
import 'city_provider.dart';

class CustomerMovieState {
  final List<MovieModel> movies;
  final int page;
  final int limit;
  final int total;
  final String search;
  final String language;
  final String genre;
  final String ageRating;
  final String sortBy;
  final String sortOrder;
  final bool isLoading;
  final String? errorMessage;

  CustomerMovieState({
    required this.movies,
    required this.page,
    required this.limit,
    required this.total,
    required this.search,
    required this.language,
    required this.genre,
    required this.ageRating,
    required this.sortBy,
    required this.sortOrder,
    this.isLoading = false,
    this.errorMessage,
  });

  factory CustomerMovieState.initial() => CustomerMovieState(
        movies: [],
        page: 1,
        limit: 20,
        total: 0,
        search: '',
        language: '',
        genre: '',
        ageRating: '',
        sortBy: 'title',
        sortOrder: 'asc',
      );

  CustomerMovieState copyWith({
    List<MovieModel>? movies,
    int? page,
    int? limit,
    int? total,
    String? search,
    String? language,
    String? genre,
    String? ageRating,
    String? sortBy,
    String? sortOrder,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CustomerMovieState(
      movies: movies ?? this.movies,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      search: search ?? this.search,
      language: language ?? this.language,
      genre: genre ?? this.genre,
      ageRating: ageRating ?? this.ageRating,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CustomerMovieNotifier extends Notifier<CustomerMovieState> {
  @override
  CustomerMovieState build() {
    // Automatically re-fetch movies when the selected city changes
    ref.listen(selectedCityProvider, (previous, next) {
      if (next != null) {
        fetchMovies(page: 1, cityId: next.id);
      } else {
        state = CustomerMovieState.initial();
      }
    });

    return CustomerMovieState.initial();
  }

  Future<void> fetchMovies({
    int? page,
    int? cityId,
    String? search,
    String? language,
    String? genre,
    String? ageRating,
    String? sortBy,
    String? sortOrder,
  }) async {
    final activeCity = ref.read(selectedCityProvider);
    final finalCityId = cityId ?? activeCity?.id;

    if (finalCityId == null) {
      state = state.copyWith(
        movies: [],
        total: 0,
        isLoading: false,
        errorMessage: 'Please select a city first.',
      );
      return;
    }

    final currentPage = page ?? state.page;
    final currentSearch = search ?? state.search;
    final currentLanguage = language ?? state.language;
    final currentGenre = genre ?? state.genre;
    final currentAgeRating = ageRating ?? state.ageRating;
    final currentSortBy = sortBy ?? state.sortBy;
    final currentSortOrder = sortOrder ?? state.sortOrder;

    state = state.copyWith(
      isLoading: true,
      page: currentPage,
      search: currentSearch,
      language: currentLanguage,
      genre: currentGenre,
      ageRating: currentAgeRating,
      sortBy: currentSortBy,
      sortOrder: currentSortOrder,
    );

    try {
      final dio = ref.read(dioProvider);
      final queryParameters = {
        'city_id': finalCityId,
        'page': currentPage,
        'limit': state.limit,
        if (currentSearch.isNotEmpty) 'search': currentSearch,
        if (currentLanguage.isNotEmpty) 'language': currentLanguage,
        if (currentGenre.isNotEmpty) 'genre': currentGenre,
        if (currentAgeRating.isNotEmpty) 'age_rating': currentAgeRating,
        'sort_by': currentSortBy,
        'sort_order': currentSortOrder,
      };

      final response = await dio.get(
        ApiConstants.movies,
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
          errorMessage: null,
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

  void resetFilters() {
    final activeCity = ref.read(selectedCityProvider);
    state = CustomerMovieState.initial();
    if (activeCity != null) {
      fetchMovies(page: 1, cityId: activeCity.id);
    }
  }
}

final customerMovieProvider = NotifierProvider<CustomerMovieNotifier, CustomerMovieState>(() {
  return CustomerMovieNotifier();
});

/// Future provider to load individual movie details
final movieDetailsProvider = FutureProvider.family<MovieModel, int>((ref, movieId) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get(
    ApiConstants.movieDetails(movieId),
  );

  if (response.statusCode == 200 && response.data != null) {
    return MovieModel.fromJson(response.data['data']);
  }
  throw Exception('Failed to load movie details.');
});
