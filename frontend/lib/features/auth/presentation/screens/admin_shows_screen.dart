import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/admin_show_provider.dart';
import '../controllers/admin_movie_provider.dart';
import '../controllers/admin_theater_provider.dart';
import '../controllers/admin_screen_provider.dart';
import '../../domain/entities/show_model.dart';
import '../../domain/entities/movie_model.dart';
import '../../domain/entities/theater_model.dart';

class AdminShowsScreen extends ConsumerStatefulWidget {
  const AdminShowsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminShowsScreen> createState() => _AdminShowsScreenState();
}

class _AdminShowsScreenState extends ConsumerState<AdminShowsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminShowProvider.notifier).fetchShows(page: 1);
      ref.read(adminMovieProvider.notifier).fetchMovies(page: 1, status: 'published');
      ref.read(adminTheaterProvider.notifier).fetchTheaters(status: 'active');
    });
  }

  void _openShowForm([ShowModel? show]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ShowFormDialog(show: show),
    );
  }

  Future<void> _cancelShow(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Show'),
        content: const Text('Are you sure you want to cancel this show? This will cancel bookings and free seat locks.'),
        actions: [
          TextButton(
            child: const Text('Go Back', style: TextStyle(color: AppColors.textSecondary)),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Cancel Show', style: TextStyle(color: AppColors.error)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref.read(adminShowProvider.notifier).cancelShow(id);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Show cancelled successfully.'), backgroundColor: AppColors.success),
        );
      } else {
        final error = ref.read(adminShowProvider).errorMessage ?? 'Failed to cancel show.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final showState = ref.watch(adminShowProvider);
    final movieState = ref.watch(adminMovieProvider);

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
                  'Shows Schedule',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  onPressed: () => _openShowForm(),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Schedule Show', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                child: showState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : showState.shows.isEmpty
                        ? const Center(child: Text('No shows scheduled yet.'))
                        : Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columns: const [
                                        DataColumn(label: Text('Show ID')),
                                        DataColumn(label: Text('Movie')),
                                        DataColumn(label: Text('Screen ID')),
                                        DataColumn(label: Text('Date')),
                                        DataColumn(label: Text('Timings')),
                                        DataColumn(label: Text('Price')),
                                        DataColumn(label: Text('Status')),
                                        DataColumn(label: Text('Actions')),
                                      ],
                                      rows: showState.shows.map((show) {
                                        final movie = movieState.movies.firstWhere(
                                          (m) => m.id == show.movieId,
                                          orElse: () => MovieModel(
                                            id: show.movieId,
                                            title: 'Movie ID: ${show.movieId}',
                                            synopsis: '',
                                            runtimeMinutes: 0,
                                            language: '',
                                            genre: '',
                                            ageRating: '',
                                            posterUrl: '',
                                            bannerUrl: '',
                                            status: '',
                                          ),
                                        );

                                        final startDT = DateTime.parse(show.startTime).toLocal();
                                        final endDT = DateTime.parse(show.endTime).toLocal();

                                        final timings = '${DateFormat('hh:mm a').format(startDT)} - ${DateFormat('hh:mm a').format(endDT)}';
                                        final dateFormatted = DateFormat('dd MMM yyyy').format(DateTime.parse(show.showDate));

                                        final isCancelled = show.status == 'cancelled';

                                        return DataRow(cells: [
                                          DataCell(Text('#${show.id}')),
                                          DataCell(Text(movie.title)),
                                          DataCell(Text('Screen #${show.screenId}')),
                                          DataCell(Text(dateFormatted)),
                                          DataCell(Text(timings)),
                                          DataCell(Text('Rs. ${show.ticketPrice}')),
                                          DataCell(Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isCancelled
                                                  ? AppColors.error.withOpacity(0.1)
                                                  : AppColors.success.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              show.status.toUpperCase(),
                                              style: TextStyle(
                                                color: isCancelled ? AppColors.error : AppColors.success,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )),
                                          DataCell(Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                                                onPressed: isCancelled ? null : () => _openShowForm(show),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                                                onPressed: isCancelled ? null : () => _cancelShow(show.id),
                                              ),
                                            ],
                                          )),
                                        ]);
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                              // Pagination Bar
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total shows: ${showState.total}'),
                                    Row(
                                      children: [
                                        TextButton(
                                          onPressed: showState.page > 1
                                              ? () => ref.read(adminShowProvider.notifier).fetchShows(page: showState.page - 1)
                                              : null,
                                          child: const Text('Previous'),
                                        ),
                                        const SizedBox(width: 8),
                                        Text('Page ${showState.page}'),
                                        const SizedBox(width: 8),
                                        TextButton(
                                          onPressed: (showState.page * showState.limit) < showState.total
                                              ? () => ref.read(adminShowProvider.notifier).fetchShows(page: showState.page + 1)
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShowFormDialog extends ConsumerStatefulWidget {
  final ShowModel? show;
  const ShowFormDialog({Key? key, this.show}) : super(key: key);

  @override
  ConsumerState<ShowFormDialog> createState() => _ShowFormDialogState();
}

class _ShowFormDialogState extends ConsumerState<ShowFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();

  int? _selectedMovieId;
  int? _selectedTheaterId;
  int? _selectedScreenId;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    if (widget.show != null) {
      final show = widget.show!;
      _selectedMovieId = show.movieId;
      _selectedDate = DateTime.parse(show.showDate);
      
      final startLocal = DateTime.parse(show.startTime).toLocal();
      final endLocal = DateTime.parse(show.endTime).toLocal();
      _startTime = TimeOfDay(hour: startLocal.hour, minute: startLocal.minute);
      _endTime = TimeOfDay(hour: endLocal.hour, minute: endLocal.minute);

      _priceController.text = show.ticketPrice.toString();
      _selectedScreenId = show.screenId;
      // Note: screen belongs to a theater, but in sqlite shows, theater is nested.
      // We can fetch screens or theaters first, but to keep edit working, we will load screens.
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 0)),
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 14, minute: 0),
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  void _onTheaterChanged(int? id) {
    if (id == null) return;
    setState(() {
      _selectedTheaterId = id;
      _selectedScreenId = null;
    });
    ref.read(adminScreenProvider.notifier).fetchScreens(id);
  }

  String _formatToISO8601(DateTime date, TimeOfDay time) {
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return dt.toUtc().toIso8601String();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMovieId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a movie.'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (_selectedScreenId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a screen.'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (_selectedDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select show date and times.'), backgroundColor: AppColors.error),
      );
      return;
    }

    // Validate end_time is after start_time
    final startDT = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _startTime!.hour, _startTime!.minute);
    final endDT = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _endTime!.hour, _endTime!.minute);

    if (!endDT.isAfter(startDT)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time.'), backgroundColor: AppColors.error),
      );
      return;
    }

    final price = int.tryParse(_priceController.text) ?? 0;

    final payload = {
      'movie_id': _selectedMovieId,
      'screen_id': _selectedScreenId,
      'show_date': _formatDate(_selectedDate!),
      'start_time': _formatToISO8601(_selectedDate!, _startTime!),
      'end_time': _formatToISO8601(_selectedDate!, _endTime!),
      'ticket_price': price,
    };

    bool success;
    if (widget.show != null) {
      success = await ref.read(adminShowProvider.notifier).updateShow(widget.show!.id, payload);
    } else {
      success = await ref.read(adminShowProvider.notifier).createShow(payload);
    }

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.show != null ? 'Show updated successfully.' : 'Show scheduled successfully.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      final error = ref.read(adminShowProvider).errorMessage ?? 'An error occurred.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final movieState = ref.watch(adminMovieProvider);
    final theaterState = ref.watch(adminTheaterProvider);
    final screenState = ref.watch(adminScreenProvider);
    final showState = ref.watch(adminShowProvider);

    return AlertDialog(
      title: Text(widget.show != null ? 'Edit Show Schedule' : 'Schedule New Show'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Movie dropdown
                DropdownButtonFormField<int>(
                  value: _selectedMovieId,
                  hint: const Text('Select Movie'),
                  items: movieState.movies.map((m) {
                    return DropdownMenuItem<int>(value: m.id, child: Text(m.title));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedMovieId = val),
                  decoration: const InputDecoration(labelText: 'Movie', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),

                // Theater dropdown (only needed on create or if we want to change screen)
                if (widget.show == null) ...[
                  DropdownButtonFormField<int>(
                    value: _selectedTheaterId,
                    hint: const Text('Select Theater'),
                    items: theaterState.theaters.map((t) {
                      return DropdownMenuItem<int>(value: t.id, child: Text(t.name));
                    }).toList(),
                    onChanged: _onTheaterChanged,
                    decoration: const InputDecoration(labelText: 'Theater', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                ],

                // Screen dropdown
                DropdownButtonFormField<int>(
                  value: _selectedScreenId,
                  hint: const Text('Select Screen'),
                  items: screenState.screens.map((s) {
                    return DropdownMenuItem<int>(value: s.id, child: Text(s.name));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedScreenId = val),
                  decoration: const InputDecoration(labelText: 'Screen', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),

                // Date Picker trigger
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Show Date', border: OutlineInputBorder()),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_selectedDate == null ? 'Choose Date' : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Start Time Picker
                InkWell(
                  onTap: _selectStartTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Start Time (UTC)', border: OutlineInputBorder()),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_startTime == null ? 'Choose Start Time' : _startTime!.format(context)),
                        const Icon(Icons.access_time),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // End Time Picker
                InkWell(
                  onTap: _selectEndTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'End Time (UTC)', border: OutlineInputBorder()),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_endTime == null ? 'Choose End Time' : _endTime!.format(context)),
                        const Icon(Icons.access_time),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Ticket Price
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Ticket Price (Rs.)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Ticket price is required.';
                    final price = int.tryParse(val);
                    if (price == null || price < 0) return 'Price must be a positive integer.';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: showState.isLoading ? null : _submit,
          child: showState.isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Submit', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
