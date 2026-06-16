import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../controllers/admin_screen_provider.dart';
import '../../domain/entities/theater_model.dart';

class AdminScreensScreen extends ConsumerStatefulWidget {
  final int theaterId;

  const AdminScreensScreen({
    Key? key,
    required this.theaterId,
  }) : super(key: key);

  @override
  ConsumerState<AdminScreensScreen> createState() => _AdminScreensScreenState();
}

class _AdminScreensScreenState extends ConsumerState<AdminScreensScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminScreenProvider.notifier).fetchScreens(widget.theaterId);
    });
  }

  void _openAddScreenDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AddScreenDialog(theaterId: widget.theaterId),
    );
  }

  Future<void> _deleteScreen(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this screen? All seats will be deleted as well.'),
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
      final success = await ref.read(adminScreenProvider.notifier).deleteScreen(id, widget.theaterId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Screen deleted successfully.'), backgroundColor: AppColors.success),
        );
      } else {
        final error = ref.read(adminScreenProvider).errorMessage ?? 'Failed to delete screen.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenState = ref.watch(adminScreenProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => context.go('/admin/theaters'),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Manage Screens',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  onPressed: _openAddScreenDialog,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add Screen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: screenState.isLoading && screenState.screens.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : screenState.screens.isEmpty
                      ? const Center(child: Text('No screens configured for this theater.', style: TextStyle(color: AppColors.textMuted)))
                      : _buildScreensTable(screenState.screens),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreensTable(List<ScreenModel> screens) {
    return Card(
      child: ListView.separated(
        itemCount: screens.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final screen = screens[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Text(
              screen.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Layout Dimensions: ${screen.rowsCount} Rows x ${screen.columnsCount} Columns',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Seat Inventory: ${screen.totalSeats ?? 0} seats generated',
                  style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: screen.status == 'active' ? AppColors.success.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: screen.status == 'active' ? AppColors.success : Colors.grey),
                  ),
                  child: Text(
                    screen.status.toUpperCase(),
                    style: TextStyle(
                      color: screen.status == 'active' ? AppColors.success : Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  onPressed: () => _deleteScreen(screen.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AddScreenDialog extends ConsumerStatefulWidget {
  final int theaterId;

  const _AddScreenDialog({
    Key? key,
    required this.theaterId,
  }) : super(key: key);

  @override
  ConsumerState<_AddScreenDialog> createState() => _AddScreenDialogState();
}

class _AddScreenDialogState extends ConsumerState<_AddScreenDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rowsController = TextEditingController(text: '10');
  final _columnsController = TextEditingController(text: '15');
  
  bool _dimensionsSubmitted = false;
  bool _isSaving = false;

  int _rowsCount = 10;
  int _columnsCount = 15;

  // Map to hold category selection for each row, key is row label (A, B, C...)
  final Map<String, String> _rowCategories = {};

  void _nextStep() {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _rowsCount = int.parse(_rowsController.text.trim());
      _columnsCount = int.parse(_columnsController.text.trim());
      
      // Initialize row category selections
      _rowCategories.clear();
      for (int i = 0; i < _rowsCount; i++) {
        final rowLabel = String.fromCharCode(65 + i);
        _rowCategories[rowLabel] = 'classic';
      }
      
      _dimensionsSubmitted = true;
    });
  }

  Future<void> _submit() async {
    setState(() => _isSaving = true);

    final payload = {
      'name': _nameController.text.trim(),
      'rows_count': _rowsCount,
      'columns_count': _columnsCount,
      'seat_categories': _rowCategories,
    };

    final success = await ref.read(adminScreenProvider.notifier).createScreen(widget.theaterId, payload);
    
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Screen & seat layout created successfully.'), backgroundColor: AppColors.success),
      );
    } else {
      final errorMsg = ref.read(adminScreenProvider).errorMessage ?? 'Failed to save screen.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rowsController.dispose();
    _columnsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 550,
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
                      _dimensionsSubmitted ? 'Configure Seat Layout Categories' : 'Add Screen Layout',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 24, color: AppColors.border),

                if (!_dimensionsSubmitted) ...[
                  // Step 1: Input dimensions
                  CustomTextField(
                    controller: _nameController,
                    labelText: 'Screen Name',
                    hintText: 'e.g. Screen 1, IMAX 3D',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Screen name is required.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _rowsController,
                          labelText: 'Number of Rows',
                          hintText: '1 - 26 (A-Z)',
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Required.';
                            final num = int.tryParse(val.trim());
                            if (num == null || num < 1 || num > 26) return 'Must be 1 - 26.';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: _columnsController,
                          labelText: 'Seats per Row',
                          hintText: '1 - 50',
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Required.';
                            final num = int.tryParse(val.trim());
                            if (num == null || num < 1 || num > 50) return 'Must be 1 - 50.';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: 'Next: Seat Categories',
                    onPressed: _nextStep,
                  ),
                ] else ...[
                  // Step 2: Configure categories for each row
                  const Text(
                    'Assign a category for each alphabetical row layout. Standard default is Classic.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.background,
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _rowsCount,
                      separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 1),
                      itemBuilder: (context, index) {
                        final rowLabel = String.fromCharCode(65 + index);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Row $rowLabel',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                              ),
                              DropdownButton<String>(
                                value: _rowCategories[rowLabel],
                                dropdownColor: AppColors.surface,
                                style: const TextStyle(color: Colors.white),
                                underline: Container(),
                                items: const [
                                  DropdownMenuItem(value: 'classic', child: Text('Classic')),
                                  DropdownMenuItem(value: 'premium', child: Text('Premium')),
                                  DropdownMenuItem(value: 'recliner', child: Text('Recliner')),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _rowCategories[rowLabel] = val;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => setState(() => _dimensionsSubmitted = false),
                          child: const Text('Back', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton(
                          text: 'Create Screen',
                          isLoading: _isSaving,
                          onPressed: _submit,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
