import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../controllers/admin_theater_provider.dart';
import '../controllers/city_provider.dart';
import '../../domain/entities/theater_model.dart';
import '../../domain/entities/city_model.dart';

class AdminTheatersScreen extends ConsumerStatefulWidget {
  const AdminTheatersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminTheatersScreen> createState() => _AdminTheatersScreenState();
}

class _AdminTheatersScreenState extends ConsumerState<AdminTheatersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminTheaterProvider.notifier).fetchTheaters();
      ref.read(activeCitiesProvider); // Pre-fetch cities
    });
  }

  void _openTheaterForm([TheaterModel? theater]) async {
    final citiesAsync = ref.read(activeCitiesProvider);
    final cities = citiesAsync.value ?? [];

    if (cities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot create theater. No active cities found. Please add a city first.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TheaterFormDialog(theater: theater, cities: cities),
    );
  }

  Future<void> _deleteTheater(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this theater? This will fail if there are active screens inside.'),
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
      final success = await ref.read(adminTheaterProvider.notifier).deleteTheater(id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Theater deleted successfully.'), backgroundColor: AppColors.success),
        );
      } else {
        final error = ref.read(adminTheaterProvider).errorMessage ?? 'Failed to delete theater.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theaterState = ref.watch(adminTheaterProvider);
    final citiesAsync = ref.watch(activeCitiesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Theaters & Cinemas',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  onPressed: () => _openTheaterForm(),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add Theater', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: theaterState.isLoading && theaterState.theaters.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : theaterState.theaters.isEmpty
                      ? const Center(child: Text('No theaters found.', style: TextStyle(color: AppColors.textMuted)))
                      : _buildTheatersTable(theaterState.theaters, citiesAsync.value ?? []),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTheatersTable(List<TheaterModel> theaters, List<CityModel> cities) {
    String getCityName(int cityId) {
      final city = cities.firstWhere((c) => c.id == cityId, orElse: () => CityModel(id: cityId, name: 'ID: $cityId'));
      return city.name;
    }

    return Card(
      child: ListView.separated(
        itemCount: theaters.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final theater = theaters[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Text(
              theater.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Address: ${theater.address}',
                  style: TextStyle(color: Colors.grey[800]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Location: ${theater.area}, ${getCityName(theater.cityId)}',
                  style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => context.go('/admin/theaters/${theater.id}/screens'),
                  icon: const Icon(Icons.display_settings_rounded, size: 18),
                  label: const Text('Screens'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  onPressed: () => _openTheaterForm(theater),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  onPressed: () => _deleteTheater(theater.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TheaterFormDialog extends ConsumerStatefulWidget {
  final TheaterModel? theater;
  final List<CityModel> cities;

  const _TheaterFormDialog({
    Key? key,
    this.theater,
    required this.cities,
  }) : super(key: key);

  @override
  ConsumerState<_TheaterFormDialog> createState() => _TheaterFormDialogState();
}

class _TheaterFormDialogState extends ConsumerState<_TheaterFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _areaController;
  
  late int _selectedCityId;
  String _status = 'active';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.theater;
    _nameController = TextEditingController(text: t?.name ?? '');
    _addressController = TextEditingController(text: t?.address ?? '');
    _areaController = TextEditingController(text: t?.area ?? '');
    _selectedCityId = t?.cityId ?? widget.cities.first.id;
    if (t != null) {
      _status = t.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final payload = {
      'name': _nameController.text.trim(),
      'address': _addressController.text.trim(),
      'city_id': _selectedCityId,
      'area': _areaController.text.trim(),
      'status': _status
    };

    bool success = false;
    final notifier = ref.read(adminTheaterProvider.notifier);

    if (widget.theater != null) {
      success = await notifier.updateTheater(widget.theater!.id, payload);
    } else {
      success = await notifier.createTheater(payload);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.theater != null ? 'Theater updated successfully.' : 'Theater created successfully.'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final errorMsg = ref.read(adminTheaterProvider).errorMessage ?? 'An error occurred while saving.';
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
    final isEdit = widget.theater != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
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
                      isEdit ? 'Edit Theater' : 'Add New Theater',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 24, color: AppColors.border),
                                // Name
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Theater Name',
                  hintText: 'e.g. PVR Multiplex',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Theater name is required.';
                    if (val.trim().length < 2) return 'Must be at least 2 characters.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Address
                CustomTextField(
                  controller: _addressController,
                  labelText: 'Address',
                  hintText: 'Enter full building address',
                  maxLines: 2,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Address is required.';
                    if (val.trim().length < 5) return 'Address must be at least 5 characters.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // City Dropdown selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'City Location',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                     DropdownButtonFormField<int>(
                      initialValue: _selectedCityId,
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
                      items: widget.cities.map((city) {
                        return DropdownMenuItem<int>(
                          value: city.id,
                          child: Text(city.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCityId = val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Area / Sub-locality
                CustomTextField(
                  controller: _areaController,
                  labelText: 'Area / Locality',
                  hintText: 'e.g. Indiranagar',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Area is required.';
                    if (val.trim().length < 2) return 'Must be at least 2 characters.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Status Dropdown
                if (isEdit) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
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
                          DropdownMenuItem(value: 'active', child: Text('Active')),
                          DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _status = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 24),
                PrimaryButton(
                  text: isEdit ? 'Save Changes' : 'Create Theater',
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
