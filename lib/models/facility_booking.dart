// Local demonstration data. Bookings are never written to Firestore or disk.
class Booking {
  const Booking({
    required this.facilityId,
    required this.purpose,
    required this.start,
    required this.end,
  });

  final String facilityId;
  final String purpose;
  final DateTime start;
  final DateTime end;
}

class BookingFacility {
  const BookingFacility(this.id, this.name, this.description);
  final String id, name, description;
}

const bookingFacilities = <BookingFacility>[
  BookingFacility('library-room', 'Library Discussion Room',
    'A sample quiet room for group study and project discussions.'),
  BookingFacility('sports-hall', 'Sports Hall',
    'A sample indoor space for student sports and team practice.'),
  BookingFacility('seminar-room', 'Seminar Room',
    'A sample room for presentations, workshops and study sessions.'),
  BookingFacility('music-room', 'Music Practice Room',
    'A sample practice space for individual or small-group rehearsals.'),
];

String bookingFacilityName(String id) {
  for (final facility in bookingFacilities) {
    if (facility.id == id) return facility.name;
  }
  return 'Unknown facility';
}

DateTime bookingToday(DateTime now) => DateTime(now.year, now.month, now.day);

// Calendar arithmetic keeps the permitted window inclusive across DST changes.
DateTime bookingLastDay(DateTime now) =>
    DateTime(now.year, now.month, now.day + 30);

bool hasConflict(String facilityId, DateTime start, DateTime end,
    List<Booking> bookings) => bookings.any((booking) =>
      booking.facilityId == facilityId &&
      start.isBefore(booking.end) && end.isAfter(booking.start));

String? bookingValidationError(Booking booking, List<Booking> bookings,
    DateTime now) {
  if (!bookingFacilities.any((f) => f.id == booking.facilityId) ||
      booking.purpose.trim().isEmpty) {
    return 'Missing field: select a facility and enter a purpose.';
  }
  final duration = booking.end.difference(booking.start);
  if (![30, 60, 90].any((minutes) => duration == Duration(minutes: minutes))) {
    return 'Missing field: choose a duration of 30, 60 or 90 minutes.';
  }
  final day = bookingToday(booking.start);
  if (day.isBefore(bookingToday(now)) || day.isAfter(bookingLastDay(now))) {
    return 'Date must be from today through the next 30 days.';
  }
  if (booking.start.isBefore(now)) return 'Time has passed. Choose a later start time.';
  final opens = DateTime(day.year, day.month, day.day, 8);
  final closes = DateTime(day.year, day.month, day.day, 22);
  if (booking.start.isBefore(opens) || booking.end.isAfter(closes)) {
    return 'Outside 08:00–22:00. The whole booking must fit within opening hours.';
  }
  if (hasConflict(booking.facilityId, booking.start, booking.end, bookings)) {
    return 'Facility already booked. Choose another time or facility.';
  }
  return null;
}
