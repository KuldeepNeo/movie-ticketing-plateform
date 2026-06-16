import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/customer_movie_provider.dart';

class MovieDetailsScreen extends ConsumerWidget {
  final int movieId;
  const MovieDetailsScreen({Key? key, required this.movieId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieDetailsAsync = ref.watch(movieDetailsProvider(movieId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: movieDetailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                err.toString().contains('Exception:') ? err.toString().split('Exception:').last : err.toString(),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(movieDetailsProvider(movieId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (movie) {
          final isBannerValid = movie.bannerUrl.startsWith('http');
          final isPosterValid = movie.posterUrl.startsWith('http');

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner section
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        image: isBannerValid
                            ? DecorationImage(
                                image: NetworkImage(movie.bannerUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: !isBannerValid
                          ? Center(
                              child: Icon(
                                Icons.image_rounded,
                                size: 60,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            )
                          : null,
                    ),
                    // Gradient overlay on banner
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    // Poster image overlapping banner
                    Positioned(
                      bottom: -60,
                      left: 24,
                      child: Container(
                        height: 150,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
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
                            ? const Center(child: Icon(Icons.movie_creation, size: 36))
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 80),
                // Details content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Meta details row
                      Row(
                        children: [
                          _buildChip(movie.ageRating, AppColors.primary),
                          const SizedBox(width: 8),
                          _buildChip(movie.language, AppColors.textSecondary),
                          const SizedBox(width: 8),
                          _buildChip('${movie.runtimeMinutes} mins', AppColors.textSecondary),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Genre
                      Row(
                        children: [
                          const Icon(Icons.local_movies_rounded, color: AppColors.textSecondary, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            movie.genre,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 40, color: AppColors.border),
                      const Text(
                        'Synopsis',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        movie.synopsis,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
