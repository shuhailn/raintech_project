import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_booking_app/features/booking/models/booking_calculation.dart';
import 'package:hotel_booking_app/features/booking/models/booking_reservation.dart';
import 'package:hotel_booking_app/features/booking/models/room.dart';
import 'package:hotel_booking_app/features/booking/services/booking_service.dart';

void main() {
  group('BookingService Logic & Calculations', () {
    late InMemoryBookingService service;
    final referenceDate = DateTime(2026, 9, 16);

    const testDeluxeRoom = Room(
      roomCode: 'R101',
      roomType: 'Deluxe Room',
      pricePerNight: 3500,
      maxGuests: 2,
    );

    const testSuiteRoom = Room(
      roomCode: 'R201',
      roomType: 'Executive Suite',
      pricePerNight: 5800,
      maxGuests: 3,
    );

    setUp(() {
      service = InMemoryBookingService(
        initialRooms: [testDeluxeRoom, testSuiteRoom],
        initialBookings: [
          BookingReservation(
            id: 'BKG-001',
            roomCode: 'R101',
            checkIn: DateTime(2026, 9, 20),
            checkOut: DateTime(2026, 9, 23),
          ),
        ],
      );
    });

    test('calculateNights correctly computes difference in days', () {
      final checkIn = DateTime(2026, 9, 16);
      final checkOut = DateTime(2026, 9, 19);

      expect(InMemoryBookingService.calculateNights(checkIn, checkOut), 3);
    });

    test('calculateTotalPrice calculates nights * pricePerNight', () {
      expect(InMemoryBookingService.calculateTotalPrice(3, 3500), 10500);
      expect(InMemoryBookingService.calculateTotalPrice(2, 5800), 11600);
      expect(InMemoryBookingService.calculateTotalPrice(0, 3500), 0);
    });

    test('evaluateBooking succeeds with valid dates and room', () {
      final result = service.evaluateBooking(
        checkIn: DateTime(2026, 9, 16),
        checkOut: DateTime(2026, 9, 18),
        room: testDeluxeRoom,
        referenceDate: referenceDate,
      );

      expect(result.isValid, isTrue);
      expect(result.status, BookingValidationStatus.valid);
      expect(result.nights, 2);
      expect(result.pricePerNight, 3500);
      expect(result.totalPrice, 7000);
      expect(result.errorMessage, isNull);
    });

    test('evaluateBooking fails when check-in is in the past', () {
      final result = service.evaluateBooking(
        checkIn: DateTime(2026, 9, 15), // Yesterday relative to 2026-09-16
        checkOut: DateTime(2026, 9, 18),
        room: testDeluxeRoom,
        referenceDate: referenceDate,
      );

      expect(result.isValid, isFalse);
      expect(result.status, BookingValidationStatus.pastCheckIn);
      expect(result.errorMessage, contains('cannot be in the past'));
    });

    test('evaluateBooking fails when check-in and check-out are the same day', () {
      final result = service.evaluateBooking(
        checkIn: DateTime(2026, 9, 17),
        checkOut: DateTime(2026, 9, 17),
        room: testDeluxeRoom,
        referenceDate: referenceDate,
      );

      expect(result.isValid, isFalse);
      expect(result.status, BookingValidationStatus.sameDay);
      expect(result.errorMessage, contains('at least 1 day after'));
    });

    test('evaluateBooking fails when check-out is before check-in', () {
      final result = service.evaluateBooking(
        checkIn: DateTime(2026, 9, 18),
        checkOut: DateTime(2026, 9, 17),
        room: testDeluxeRoom,
        referenceDate: referenceDate,
      );

      expect(result.isValid, isFalse);
      expect(result.status, BookingValidationStatus.checkOutBeforeCheckIn);
      expect(result.errorMessage, contains('must be after check-in'));
    });

    test('evaluateBooking detects room collision when dates overlap existing booking', () {
      // Existing booking for R101 is 2026-09-20 to 2026-09-23
      final result = service.evaluateBooking(
        checkIn: DateTime(2026, 9, 21),
        checkOut: DateTime(2026, 9, 24),
        room: testDeluxeRoom,
        referenceDate: referenceDate,
      );

      expect(result.isValid, isFalse);
      expect(result.status, BookingValidationStatus.roomUnavailable);
      expect(result.errorMessage, contains('already booked for the chosen dates'));
    });

    test('isRoomAvailable returns true when dates do not overlap', () {
      // Booking before existing
      expect(
        service.isRoomAvailable('R101', DateTime(2026, 9, 17), DateTime(2026, 9, 20)),
        isTrue,
      );

      // Booking after existing
      expect(
        service.isRoomAvailable('R101', DateTime(2026, 9, 23), DateTime(2026, 9, 26)),
        isTrue,
      );
    });

    test('getRooms filters rooms by minCapacity correctly', () {
      final allRooms = service.getRooms();
      expect(allRooms.length, 2);

      final capacity3Rooms = service.getRooms(minCapacity: 3);
      expect(capacity3Rooms.length, 1);
      expect(capacity3Rooms.first.roomCode, 'R201');

      final capacity4Rooms = service.getRooms(minCapacity: 4);
      expect(capacity4Rooms.isEmpty, isTrue);
    });

    test('bookRoom adds reservation and marks room unavailable for overlapping period', () async {
      final newReservation = BookingReservation(
        id: 'BKG-002',
        roomCode: 'R201',
        checkIn: DateTime(2026, 9, 27),
        checkOut: DateTime(2026, 9, 30),
      );

      final booked = await service.bookRoom(newReservation);
      expect(booked, isTrue);

      // Room should now be unavailable for those dates
      final available = service.isRoomAvailable(
        'R201',
        DateTime(2026, 9, 28),
        DateTime(2026, 9, 29),
      );
      expect(available, isFalse);
    });
  });
}
