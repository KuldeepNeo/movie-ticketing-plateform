import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/movie_model.dart';
import '../controllers/admin_movie_provider.dart';

class MovieFormDialog extends ConsumerStatefulWidget {
  final MovieModel? movie;

  const MovieFormDialog({
    Key? key,
    this.movie,
  }) : super(key: key);

  @override
  ConsumerState<MovieFormDialog> createState() => _MovieFormDialogState();
}

class _MovieFormDialogState extends ConsumerState<MovieFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _titleController;
  late final TextEditingController _synopsisController;
  late final TextEditingController _runtimeController;
  late final TextEditingController _languageController;
  late final TextEditingController _genreController;
  late final TextEditingController _posterUrlController;
  late final TextEditingController _bannerUrlController;
  
  String _ageRating = 'U/A';
  String _status = 'draft';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.movie;
    _titleController = TextEditingController(text: m?.title ?? '');
    _synopsisController = TextEditingController(text: m?.synopsis ?? '');
    _runtimeController = TextEditingController(text: m?.runtimeMinutes.toString() ?? '');
    _languageController = TextEditingController(text: m?.language ?? '');
    _genreController = TextEditingController(text: m?.genre ?? '');
    _posterUrlController = TextEditingController(text: m?.posterUrl ?? '');
    _bannerUrlController = TextEditingController(text: m?.bannerUrl ?? '');
    if (m != null) {
      _ageRating = m.ageRating;
      _status = m.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _synopsisController.dispose();
    _runtimeController.dispose();
    _languageController.dispose();
    _genreController.dispose();
    _posterUrlController.dispose();
    _bannerUrlController.dispose();
    super.dispose();
  }

  bool _isValidUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    
    final payload = {
      'title': _titleController.text.trim(),
      'synopsis': _synopsisController.text.trim(),
      'runtime_minutes': int.parse(_runtimeController.text.trim()),
      'language': _languageController.text.trim(),
      'genre': _genreController.text.trim(),
      'age_rating': _ageRating,
      'poster_url': _posterUrlController.text.trim(),
      'banner_url': _bannerUrlController.text.trim(),
      'status': _status,
    };

    bool success = false;
    final notifier = ref.read(adminMovieProvider.notifier);
    
    if (widget.movie != null) {
      success = await notifier.updateMovie(widget.movie!.id, payload);
    } else {
      success = await notifier.createMovie(payload);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      final errorMsg = ref.read(adminMovieProvider).errorMessage ?? 'An error occurred while saving.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.movie != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'Edit Movie' : 'Add New Movie',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // In dark dialog
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 24, color: AppColors.border),
                
                // Title
                CustomTextField(
                  controller: _titleController,
                  labelText: 'Movie Title',
                  hintText: 'Enter movie title',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Title is required.';
                    if (val.trim().length > 255) return 'Title must not exceed 255 characters.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Synopsis
                CustomTextField(
                  controller: _synopsisController,
                  labelText: 'Synopsis',
                  hintText: 'Enter synopsis details (minimum 10 characters)',
                  maxLines: 4,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Synopsis is required.';
                    if (val.trim().length < 10) return 'Synopsis must be at least 10 characters.';
                    if (val.trim().length > 5000) return 'Synopsis must not exceed 5000 characters.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    // Runtime
                    Expanded(
                      child: CustomTextField(
                        controller: _runtimeController,
                        labelText: 'Runtime (Minutes)',
                        hintText: 'e.g. 148',
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Runtime is required.';
                          final runtime = int.tryParse(val.trim());
                          if (runtime == null || runtime <= 0) return 'Must be an integer > 0.';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Language
                    Expanded(
                      child: CustomTextField(
                        controller: _languageController,
                        labelText: 'Language',
                        hintText: 'e.g. English',
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Language is required.';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    // Genre
                    Expanded(
                      child: CustomTextField(
                        controller: _genreController,
                        labelText: 'Genre',
                        hintText: 'e.g. Action',
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Genre is required.';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Age Rating Dropdown
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Age Rating',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _ageRating,
                            dropdownColor: AppColors.surface,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'U', child: Text('U')),
                              DropdownMenuItem(value: 'U/A', child: Text('U/A')),
                              DropdownMenuItem(value: 'A', child: Text('A')),
                              DropdownMenuItem(value: 'PG-13', child: Text('PG-13')),
                              DropdownMenuItem(value: 'R', child: Text('R')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _ageRating = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Poster URL
                CustomTextField(
                  controller: _posterUrlController,
                  labelText: 'Poster Image URL',
                  hintText: 'https://example.com/poster.jpg',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Poster URL is required.';
                    if (!_isValidUrl(val.trim())) return 'Must be a valid URL starting with http/https.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Banner URL
                CustomTextField(
                  controller: _bannerUrlController,
                  labelText: 'Banner Image URL',
                  hintText: 'https://example.com/banner.jpg',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Banner URL is required.';
                    if (!_isValidUrl(val.trim())) return 'Must be a valid URL starting with http/https.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Status Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Publish Status',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'draft', child: Text('Draft')),
                        DropdownMenuItem(value: 'published', child: Text('Published')),
                        DropdownMenuItem(value: 'archived', child: Text('Archived')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _status = val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                PrimaryButton(
                  text: isEdit ? 'Save Changes' : 'Create Movie',
                  isLoading: _isSaving,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
