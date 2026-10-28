import 'package:flutter/material.dart';
import '../models/facility_booking.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.confirmedBookings, this.clock});

  // This list belongs to IituApp's State, so route changes do not erase it.
  final List<Booking> confirmedBookings;
  final DateTime Function()? clock;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final formKey = GlobalKey<FormState>();
  final purpose = TextEditingController();
  final dayText = TextEditingController();
  final timeText = TextEditingController();
  final scroll = ScrollController();
  String? facilityId;
  DateTime? selectedDay;
  TimeOfDay? selectedTime;
  int? durationMinutes;
  String? error;
  bool reviewing = false;
  bool pickerOpen = false;
  bool saved = false;

  DateTime get now => widget.clock?.call() ?? DateTime.now();
  bool get locked => reviewing || pickerOpen || saved;

  @override
  void dispose() {
    purpose.dispose();
    dayText.dispose();
    timeText.dispose();
    scroll.dispose();
    super.dispose();
  }

  String dateLabel(DateTime value) =>
      MaterialLocalizations.of(context).formatMediumDate(value);

  String timeLabel(DateTime value) => MaterialLocalizations.of(context)
      .formatTimeOfDay(TimeOfDay.fromDateTime(value),
        alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context));

  Booking? get candidate {
    final day = selectedDay;
    final time = selectedTime;
    final minutes = durationMinutes;
    final facility = facilityId;
    if (day == null || time == null || minutes == null || facility == null) return null;
    final start = DateTime(day.year, day.month, day.day, time.hour, time.minute);
    return Booking(facilityId: facility, purpose: purpose.text.trim(),
      start: start, end: start.add(Duration(minutes: minutes)));
  }

  Future<void> pickDay() async {
    if (locked) return;
    final current = now;
    final first = bookingToday(current);
    final last = bookingLastDay(current);
    var initial = selectedDay ?? first;
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;
    setState(() => pickerOpen = true);
    try {
      final picked = await showDatePicker(context: context,
        firstDate: first, lastDate: last, initialDate: initial,
        helpText: 'Choose a booking date');
      if (!mounted || picked == null) return;
      setState(() {
        selectedDay = picked;
        dayText.text = dateLabel(picked);
        error = null;
      });
    } finally {
      if (mounted) setState(() => pickerOpen = false);
    }
  }

  Future<void> pickTime() async {
    if (locked) return;
    setState(() => pickerOpen = true);
    try {
      final picked = await showTimePicker(context: context,
        initialTime: selectedTime ?? TimeOfDay.fromDateTime(now),
        helpText: 'Choose a start time');
      if (!mounted || picked == null) return;
      setState(() {
        selectedTime = picked;
        timeText.text = MaterialLocalizations.of(context).formatTimeOfDay(picked,
          alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context));
        error = null;
      });
    } finally {
      if (mounted) setState(() => pickerOpen = false);
    }
  }

  Widget summary(Booking item) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(bookingFacilityName(item.facilityId),
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      Text('Date: ${dateLabel(item.start)}'),
      const SizedBox(height: 8),
      Text('Start: ${timeLabel(item.start)}'),
      const SizedBox(height: 8),
      Text('End: ${timeLabel(item.end)}'),
      const SizedBox(height: 8),
      Text('Duration: ${item.end.difference(item.start).inMinutes} minutes'),
      const SizedBox(height: 12),
      Text('Purpose: ${item.purpose.isEmpty ? 'Not entered yet' : item.purpose}'),
    ],
  );

  Future<void> reviewBooking() async {
    if (locked) return;
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) {
      setState(() => error = 'Missing field: complete all required fields.');
      return;
    }
    final item = candidate;
    if (item == null) {
      setState(() => error = 'Missing field: complete all required fields.');
      return;
    }
    final initialError = bookingValidationError(item, widget.confirmedBookings, now);
    if (initialError != null) {
      setState(() => error = initialError);
      return;
    }
    setState(() { reviewing = true; error = null; });
    // Prevent an old success message from being mistaken for a cancelled review.
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    try {
      var answered = false;
      final accepted = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          void finish(bool result) {
            if (answered) return;
            answered = true;
            Navigator.pop(dialogContext, result);
          }
          return AlertDialog(
            title: const Text('Confirm facility booking'),
            content: SingleChildScrollView(child: summary(item)),
            actions: [
              TextButton(onPressed: () => finish(false), child: const Text('Cancel')),
              FilledButton(onPressed: () => finish(true), child: const Text('Confirm')),
            ],
          );
        },
      );
      if (!mounted || accepted != true) return;
      // Recheck current time, permitted date, hours and conflicts immediately
      // before committing. No await separates this check from the single add.
      final finalError = bookingValidationError(item, widget.confirmedBookings, now);
      if (finalError != null) {
        setState(() => error = finalError);
        return;
      }
      setState(() {
        widget.confirmedBookings.add(item);
        saved = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking confirmed.')));
    } finally {
      if (mounted) setState(() => reviewing = false);
    }
  }

  void newBooking() {
    if (reviewing || pickerOpen) return;
    formKey.currentState?.reset();
    purpose.clear(); dayText.clear(); timeText.clear();
    setState(() {
      facilityId = null; selectedDay = null; selectedTime = null;
      durationMinutes = null; saved = false; error = null;
    });
    if (scroll.hasClients) scroll.animateTo(0,
      duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final item = candidate;
    final history = List<Booking>.of(widget.confirmedBookings)
      ..sort((a, b) => a.start.compareTo(b.start));
    BookingFacility? selectedFacility;
    for (final facility in bookingFacilities) {
      if (facility.id == facilityId) selectedFacility = facility;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Facility booking')),
      body: SafeArea(child: SingleChildScrollView(
        controller: scroll,
        padding: const EdgeInsets.all(18),
        child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Make room for your next idea.',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text('Choose a campus space, review the time and confirm your booking.'),
            const SizedBox(height: 16),
            Card(color: primary.withValues(alpha: .07),
              child: const Padding(padding: EdgeInsets.all(16),
                child: Text('Demonstration only · Open 08:00–22:00\n'
                    'Today through the next 30 days. Bookings stay in this app '
                    'session and reset when the app restarts.'))),
            const SizedBox(height: 16),
            Card(child: Padding(padding: const EdgeInsets.all(20),
              child: Form(key: formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const Text('Booking details',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: facilityId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Facility *'),
                    items: bookingFacilities.map((facility) => DropdownMenuItem(
                      value: facility.id,
                      child: Text(facility.name, overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: locked ? null : (value) => setState(() {
                      facilityId = value; error = null;
                    }),
                    validator: (value) => value == null ? 'Missing field: choose a facility.' : null,
                  ),
                  if (selectedFacility != null) Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(selectedFacility.description)),
                  const SizedBox(height: 20),
                  TextFormField(
                    key: const ValueKey('booking-purpose'),
                    controller: purpose,
                    enabled: !locked,
                    minLines: 2, maxLines: 4, maxLength: 300,
                    decoration: const InputDecoration(labelText: 'Purpose *',
                      hintText: 'For example: practise a group presentation'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Missing field: enter the purpose.' : null,
                    onChanged: (_) => setState(() => error = null),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(builder: (context, box) {
                    final width = box.maxWidth >= 600 ? (box.maxWidth - 16) / 2 : box.maxWidth;
                    return Wrap(spacing: 16, runSpacing: 20, children: [
                      SizedBox(width: width, child: TextFormField(
                        key: const ValueKey('booking-day'),
                        controller: dayText, readOnly: true, enabled: !locked,
                        onTap: pickDay,
                        decoration: const InputDecoration(labelText: 'Booking date *',
                          hintText: 'Choose a date', suffixIcon: Icon(Icons.calendar_month_outlined)),
                        validator: (_) => selectedDay == null ? 'Missing field: choose a date.' : null,
                      )),
                      SizedBox(width: width, child: TextFormField(
                        key: const ValueKey('booking-time'),
                        controller: timeText, readOnly: true, enabled: !locked,
                        onTap: pickTime,
                        decoration: const InputDecoration(labelText: 'Start time *',
                          hintText: 'Choose a time', suffixIcon: Icon(Icons.schedule_outlined)),
                        validator: (_) => selectedTime == null ? 'Missing field: choose a start time.' : null,
                      )),
                    ]);
                  }),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<int>(
                    value: durationMinutes,
                    decoration: const InputDecoration(labelText: 'Duration *'),
                    items: const [30, 60, 90].map((minutes) => DropdownMenuItem(
                      value: minutes, child: Text('$minutes minutes'))).toList(),
                    onChanged: locked ? null : (value) => setState(() {
                      durationMinutes = value; error = null;
                    }),
                    validator: (value) => value == null ? 'Missing field: choose a duration.' : null,
                  ),
                  const SizedBox(height: 24),
                  Container(padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: .05),
                      borderRadius: BorderRadius.circular(12)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      const Text('Your booking summary',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      if (item == null)
                        const Text('Select a facility, date, time and duration to preview the start and end.')
                      else summary(item),
                    ])),
                  if (error != null) Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Semantics(liveRegion: true,
                      child: Text(error!, style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600)))),
                  const SizedBox(height: 20),
                  if (saved) ...[
                    const Text('Confirmed. Your choices are retained below. '
                        'Use New booking to create another request.'),
                    const SizedBox(height: 12),
                    FilledButton.icon(onPressed: newBooking,
                      icon: const Icon(Icons.add), label: const Text('New booking')),
                  ] else FilledButton.icon(
                    key: const ValueKey('review-booking'),
                    onPressed: locked ? null : reviewBooking,
                    icon: const Icon(Icons.event_available_outlined),
                    label: Text(reviewing ? 'Review in progress…' : 'Review booking'),
                  ),
                ])))),
            const SizedBox(height: 28),
            Text('Confirmed bookings (${history.length})',
              key: const ValueKey('booking-count'),
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (history.isEmpty)
              const Card(child: Padding(padding: EdgeInsets.all(20),
                child: Text('No confirmed bookings yet. Only Confirm saves a booking.'))),
            for (final booking in history)
              Card(child: Padding(padding: const EdgeInsets.all(20),
                child: summary(booking))),
            const SizedBox(height: 24),
          ]),
        )),
      )),
    );
  }
}
