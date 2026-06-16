import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../controllers/city_provider.dart';
import '../controllers/customer_movie_provider.dart';
import '../widgets/city_selector_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCitySelection();
      _loadMovies();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _checkCitySelection() {
    final selectedCity = ref.read(selectedCityProvider);
    if (selectedCity == null) {
      _openCitySelector(isDismissible: false);
    }
  }

  void _loadMovies() {
    final city = ref.read(selectedCityProvider);
    if (city != null) {
      ref.read(customerMovieProvider.notifier).fetchMovies(page: 1, cityId: city.id);
    }
  }

  void _openCitySelector({required bool isDismissible}) {
    showDialog(
      context: context,
      barrierDismissible: isDismissible,
      builder: (context) => CitySelectorDialog(isDismissible: isDismissible),
    ).then((_) => _loadMovies());
  }

  void _onSearchChanged(String val) {
    ref.read(customerMovieProvider.notifier).fetchMovies(page: 1, search: val);
  }

  void _toggleLanguageFilter(String lang) {
    final state = ref.read(customerMovieProvider);
    final nextLang = state.language == lang ? '' : lang;
    ref.read(customerMovieProvider.notifier).fetchMovies(page: 1, language: nextLang);
  }

  void _toggleGenreFilter(String genre) {
    final state = ref.read(customerMovieProvider);
    final nextGenre = state.genre == genre ? '' : genre;
    ref.read(customerMovieProvider.notifier).fetchMovies(page: 1, genre: nextGenre);
  }

  void _toggleAgeRatingFilter(String rating) {
    final state = ref.read(customerMovieProvider);
    final nextRating = state.ageRating == rating ? '' : rating;
    ref.read(customerMovieProvider.notifier).fetchMovies(page: 1, ageRating: nextRating);
  }

  @override
  Widget build(BuildContext context) {
    final selectedCity = ref.watch(selectedCityProvider);
    final movieState = ref.watch(customerMovieProvider);

    // Filter values
    final genres = ['Action', 'Comedy', 'Drama', 'Thriller'];
    final languages = ['English', 'Hindi', 'Spanish'];
    final ageRatings = ['U', 'U/A', 'A'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('BookMyShow'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () => _openCitySelector(isDismissible: true),
            icon: const Icon(Icons.location_on_rounded, size: 18),
            label: Text(selectedCity?.name ?? 'Select City'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: selectedCity == null
          ? const Center(child: Text('Select a city to start browsing movies.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Now Showing in ${selectedCity.name}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search Bar Input
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search movies by title...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        // Genre filters
                        ...genres.map((g) {
                          final isSelected = movieState.genre == g;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(g),
                              selected: isSelected,
                              onSelected: (_) => _toggleGenreFilter(g),
                              selectedColor: AppColors.primary.withOpacity(0.15),
                              checkmarkColor: AppColors.primary,
                            ),
                          );
                        }),
                        // Language filters
                        ...languages.map((l) {
                          final isSelected = movieState.language == l;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(l),
                              selected: isSelected,
                              onSelected: (_) => _toggleLanguageFilter(l),
                              selectedColor: AppColors.primary.withOpacity(0.15),
                              checkmarkColor: AppColors.primary,
                            ),
                          );
                        }),
                        // Age rating filters
                        ...ageRatings.map((r) {
                          final isSelected = movieState.ageRating == r;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(r),
                              selected: isSelected,
                              onSelected: (_) => _toggleAgeRatingFilter(r),
                              selectedColor: AppColors.primary.withOpacity(0.15),
                              checkmarkColor: AppColors.primary,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // Reset Filters
                  if (movieState.genre.isNotEmpty ||
                      movieState.language.isNotEmpty ||
                      movieState.ageRating.isNotEmpty ||
                      movieState.search.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: ActionChip(
                        avatar: const Icon(Icons.clear, size: 16, color: Colors.white),
                        backgroundColor: AppColors.error,
                        label: const Text('Reset Filters', style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(customerMovieProvider.notifier).resetFilters();
                        },
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Movies Horizontal Carousel / List View
                  movieState.isLoading
                      ? const SizedBox(
                          height: 320,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : movieState.errorMessage != null
                          ? Container(
                              height: 320,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                movieState.errorMessage!,
                                style: const TextStyle(color: AppColors.error),
                              ),
                            )
                          : movieState.movies.isEmpty
                              ? const SizedBox(
                                  height: 320,
                                  child: Center(
                                    child: Text(
                                      'No published movies found matching the filters.',
                                      style: TextStyle(color: AppColors.textSecondary),
                                    ),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 340,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        itemCount: movieState.movies.length,
                                        itemBuilder: (context, idx) {
                                          final movie = movieState.movies[idx];
                                          final isPosterValid = movie.posterUrl.startsWith('http');

                                          return Container(
                                            width: 170,
                                            margin: const EdgeInsets.symmetric(horizontal: 8),
                                            child: InkWell(
                                              onTap: () => context.push('/movies/${movie.id}'),
                                              borderRadius: BorderRadius.circular(12),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // Poster Image Card
                                                  Expanded(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        borderRadius: BorderRadius.circular(12),
                                                        border: Border.all(color: AppColors.border),
                                                        boxShadow: const [
                                                          BoxShadow(
                                                            color: Colors.black12,
                                                            blurRadius: 4,
                                                            offset: Offset(0, 2),
                                                          ),
                                                        ],
                                                        image: isPosterValid
                                                            ? DecorationImage(
                                                                image: NetworkImage(movie.posterUrl),
                                                                fit: BoxFit.cover,
                                                              )
                                                            : null,
                                                      ),
                                                      child: !isPosterValid
                                                          ? const Center(
                                                              child: Icon(Icons.movie_creation, size: 40, color: AppColors.textSecondary),
                                                            )
                                                          : null,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  // Title
                                                  Text(
                                                    movie.title,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  // Language & Age Rating
                                                  Text(
                                                    '${movie.language} • ${movie.ageRating}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  // Genre
                                                  Text(
                                                    movie.genre,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.primary,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    // Pagination Controllers
                                    const SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Total movies: ${movieState.total}',
                                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                          ),
                                          Row(
                                            children: [
                                              TextButton(
                                                onPressed: movieState.page > 1
                                                    ? () => ref.read(customerMovieProvider.notifier).fetchMovies(page: movieState.page - 1)
                                                    : null,
                                                child: const Text('Prev'),
                                              ),
                                              const SizedBox(width: 8),
                                              Text('Page ${movieState.page}'),
                                              const SizedBox(width: 8),
                                              TextButton(
                                                onPressed: (movieState.page * movieState.limit) < movieState.total
                                                    ? () => ref.read(customerMovieProvider.notifier).fetchMovies(page: movieState.page + 1)
                                                    : null,
                                                child: const Text('Next'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                ],
              ),
            ),
    );
  }
}
