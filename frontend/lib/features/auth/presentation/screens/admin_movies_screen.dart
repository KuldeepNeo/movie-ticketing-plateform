import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/admin_movie_provider.dart';
import '../../domain/entities/movie_model.dart';
import '../widgets/movie_form_dialog.dart';

class AdminMoviesScreen extends ConsumerStatefulWidget {
  const AdminMoviesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminMoviesScreen> createState() => _AdminMoviesScreenState();
}

class _AdminMoviesScreenState extends ConsumerState<AdminMoviesScreen> {
  final _searchController = TextEditingController();
  String _selectedStatus = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminMovieProvider.notifier).fetchMovies(page: 1, search: '', status: '');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    ref.read(adminMovieProvider.notifier).fetchMovies(page: 1, search: val);
  }

  void _onStatusChanged(String? val) {
    final status = val ?? '';
    setState(() => _selectedStatus = status);
    ref.read(adminMovieProvider.notifier).fetchMovies(page: 1, status: status);
  }

  void _openForm([MovieModel? movie]) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MovieFormDialog(movie: movie),
    );

    if (!mounted) return;
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(movie != null ? 'Movie updated successfully.' : 'Movie created successfully.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _deleteMovie(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this movie? This action cannot be undone.'),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref.read(adminMovieProvider.notifier).deleteMovie(id);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Movie deleted successfully.'), backgroundColor: AppColors.success),
        );
      } else {
        final error = ref.read(adminMovieProvider).errorMessage ?? 'Failed to delete movie.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final movieState = ref.watch(adminMovieProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // Render inside shell background
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Movies Catalog',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add Movie', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Filters bar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search by title...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 180,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedStatus.isEmpty ? null : _selectedStatus,
                        hint: const Text('Filter by Status'),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: '', child: Text('All Statuses')),
                          DropdownMenuItem(value: 'draft', child: Text('Draft')),
                          DropdownMenuItem(value: 'published', child: Text('Published')),
                          DropdownMenuItem(value: 'archived', child: Text('Archived')),
                        ],
                        onChanged: _onStatusChanged,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Movie List Grid
            Expanded(
              child: movieState.isLoading && movieState.movies.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : movieState.movies.isEmpty
                      ? const Center(child: Text('No movies found.', style: TextStyle(color: AppColors.textMuted)))
                      : Column(
                          children: [
                            Expanded(
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 260,
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: movieState.movies.length,
                                itemBuilder: (context, index) {
                                  final movie = movieState.movies[index];
                                  return _buildMovieCard(movie);
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Paging controls
                            _buildPagination(movieState),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieCard(MovieModel movie) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    movie.posterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[350],
                      child: const Icon(Icons.movie, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: movie.status == 'published'
                          ? AppColors.success.withOpacity(0.9)
                          : (movie.status == 'draft' ? Colors.orange.withOpacity(0.9) : Colors.grey.withOpacity(0.9)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      movie.status.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  '${movie.genre} • ${movie.language} • ${movie.ageRating}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Runtime: ${movie.runtimeMinutes} mins',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () => _openForm(movie),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                      onPressed: () => _deleteMovie(movie.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(AdminMovieState movieState) {
    final totalPages = (movieState.total / movieState.limit).ceil();
    final hasNext = movieState.page < totalPages;
    final hasPrev = movieState.page > 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Showing ${(movieState.page - 1) * movieState.limit + 1} - ${movieState.page * movieState.limit > movieState.total ? movieState.total : movieState.page * movieState.limit} of ${movieState.total} Movies',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey[300],
              ),
              onPressed: hasPrev
                  ? () => ref.read(adminMovieProvider.notifier).fetchMovies(page: movieState.page - 1)
                  : null,
              child: const Text('Previous', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 16),
            Text(
              'Page ${movieState.page} of ${totalPages > 0 ? totalPages : 1}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey[300],
              ),
              onPressed: hasNext
                  ? () => ref.read(adminMovieProvider.notifier).fetchMovies(page: movieState.page + 1)
                  : null,
              child: const Text('Next', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }
}
