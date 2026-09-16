import 'package:flutter/foundation.dart';
import '../data/mock_hotel_data.dart';
import '../models/booking_calculation.dart';
import '../models/booking_reservation.dart';
import '../models/room.dart';

/// Abstract contract for booking operations following clean architecture principles.
abstract class BookingService {
  List<Room> getRooms({int? minCapacity});
  List<BookingReservation> getBookings();
  bool isRoomAvailable(String roomCode, DateTime checkIn, DateTime checkOut);
  BookingCalculation evaluateBooking({
    required DateTime? checkIn,
    required DateTime? checkOut,
    required Room? room,
    int? guestCount,
    DateTime? referenceDate,
  });
  Future<bool> bookRoom(BookingReservation reservation);
}

/// In-memory implementation of [BookingService] with pure logic and collision checking.
class InMemoryBookingService implements BookingService {
  final List<Room> _rooms;
  final List<BookingReservation> _bookings;

  InMemoryBookingService({
    List<Room>? initialRooms,
    List<BookingReservation>? initialBookings,
  })  : _rooms = initialRooms ?? MockHotelData.rooms,
        _bookings = List<BookingReservation>.from(
          initialBookings ?? MockHotelData.getInitialBookings(),
        );

  @override
  List<Room> getRooms({int? minCapacity}) {
    if (minCapacity == null || minCapacity <= 0) {
      return List.unmodifiable(_rooms);
    }
    return List.unmodifiable(
      _rooms.where((room) => room.maxGuests >= minCapacity),
    );
  }

  @override
  List<BookingReservation> getBookings() {
    return List.unmodifiable(_bookings);
  }

  /// Calculates number of nights between checkIn and checkOut.
  /// Normalized to midnight to prevent timezone/hour daylight saving issues.
  static int calculateNights(DateTime checkIn, DateTime checkOut) {
    final start = DateTime(checkIn.year, checkIn.month, checkIn.day);
    final end = DateTime(checkOut.year, checkOut.month, checkOut.day);
    final difference = end.difference(start);
    return difference.inDays;
  }

  /// Calculates total price for the stay.
  static int calculateTotalPrice(int nights, int pricePerNight) {
    if (nights <= 0 || pricePerNight <= 0) return 0;
    return nights * pricePerNight;
  }

  /// Checks whether two date ranges overlap.
  /// Standard hotel reservation interval overlap:
  /// (startA < endB) && (endA > startB)
  static bool hasDateOverlap(
    DateTime startA,
    DateTime endA,
    DateTime startB,
    DateTime endB,
  ) {
    final normalizedStartA = DateTime(startA.year, startA.month, startA.day);
    final normalizedEndA = DateTime(endA.year, endA.month, endA.day);
    final normalizedStartB = DateTime(startB.year, startB.month, startB.day);
    final normalizedEndB = DateTime(endB.year, endB.month, endB.day);

    return normalizedStartA.isBefore(normalizedEndB) &&
        normalizedEndA.isAfter(normalizedStartB);
  }

  @override
  bool isRoomAvailable(String roomCode, DateTime checkIn, DateTime checkOut) {
    for (final booking in _bookings) {
      if (booking.roomCode == roomCode) {
        if (hasDateOverlap(checkIn, checkOut, booking.checkIn, booking.checkOut)) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  BookingCalculation evaluateBooking({
    required DateTime? checkIn,
    required DateTime? checkOut,
    required Room? room,
    int? guestCount,
    DateTime? referenceDate,
  }) {
    if (checkIn == null || checkOut == null) {
      return BookingCalculation.invalid(
        status: BookingValidationStatus.incomplete,
        errorMessage: 'Please select both Check-in and Check-out dates.',
        pricePerNight: room?.pricePerNight ?? 0,
      );
    }

    final today = referenceDate ?? DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedCheckIn = DateTime(checkIn.year, checkIn.month, checkIn.day);
    final normalizedCheckOut = DateTime(checkOut.year, checkOut.month, checkOut.day);

    // Rule 1: Check-in cannot be in the past
    if (normalizedCheckIn.isBefore(normalizedToday)) {
      return BookingCalculation.invalid(
        status: BookingValidationStatus.pastCheckIn,
        errorMessage: 'Check-in date cannot be in the past.',
        pricePerNight: room?.pricePerNight ?? 0,
      );
    }

    // Rule 2: Check-out must be after check-in (same-day not allowed)
    if (normalizedCheckOut.isAtSameMomentAs(normalizedCheckIn)) {
      return BookingCalculation.invalid(
        status: BookingValidationStatus.sameDay,
        errorMessage: 'Check-out date must be at least 1 day after check-in.',
        pricePerNight: room?.pricePerNight ?? 0,
      );
    }

    // Rule 3: Check-out cannot precede check-in
    if (normalizedCheckOut.isBefore(normalizedCheckIn)) {
      return BookingCalculation.invalid(
        status: BookingValidationStatus.checkOutBeforeCheckIn,
        errorMessage: 'Check-out date must be after check-in date.',
        pricePerNight: room?.pricePerNight ?? 0,
      );
    }

    final nights = calculateNights(normalizedCheckIn, normalizedCheckOut);

    if (room == null) {
      return BookingCalculation.invalid(
        status: BookingValidationStatus.incomplete,
        errorMessage: 'Please select a room from the list.',
        nights: nights,
      );
    }

    // Capacity validation (bonus feature)
    if (guestCount != null && guestCount > room.maxGuests) {
      return BookingCalculation.invalid(
        status: BookingValidationStatus.exceedsMaxGuests,
        errorMessage:
            'Selected room accommodates at most ${room.maxGuests} guests ($guestCount requested).',
        nights: nights,
        pricePerNight: room.pricePerNight,
      );
    }

    // Room collision check (bonus feature)
    if (!isRoomAvailable(room.roomCode, normalizedCheckIn, normalizedCheckOut)) {
      return BookingCalculation.invalid(
        status: BookingValidationStatus.roomUnavailable,
        errorMessage:
            'Room ${room.roomCode} (${room.roomType}) is already booked for the chosen dates.',
        nights: nights,
        pricePerNight: room.pricePerNight,
      );
    }

    // Success calculation
    final totalPrice = calculateTotalPrice(nights, room.pricePerNight);
    return BookingCalculation.valid(
      nights: nights,
      pricePerNight: room.pricePerNight,
      totalPrice: totalPrice,
    );
  }

  @override
  Future<bool> bookRoom(BookingReservation reservation) async {
    final available = isRoomAvailable(
      reservation.roomCode,
      reservation.checkIn,
      reservation.checkOut,
    );

    if (!available) {
      debugPrint('Booking failed: Room ${reservation.roomCode} is already booked.');
      return false;
    }

    _bookings.add(reservation);
    debugPrint('Booking confirmed for Room ${reservation.roomCode}, ID: ${reservation.id}');
    return true;
  }
}
