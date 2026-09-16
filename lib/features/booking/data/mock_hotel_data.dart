import '../models/booking_reservation.dart';
import '../models/room.dart';

class MockHotelData {
  /// Sample rooms provided in the assessment specification.
  static const List<Room> rooms = [
    Room(
      roomCode: 'R101',
      roomType: 'Deluxe Room',
      pricePerNight: 3500,
      maxGuests: 2,
      description: 'Comfortable king-size bed with city view and complimentary breakfast.',
    ),
    Room(
      roomCode: 'R102',
      roomType: 'Deluxe Room',
      pricePerNight: 3500,
      maxGuests: 2,
      description: 'Peaceful garden facing room with king bed and high-speed Wi-Fi.',
    ),
    Room(
      roomCode: 'R201',
      roomType: 'Executive Suite',
      pricePerNight: 5800,
      maxGuests: 3,
      description: 'Spacious suite with separate living area, work desk, and balcony.',
    ),
    Room(
      roomCode: 'R202',
      roomType: 'Executive Suite',
      pricePerNight: 5800,
      maxGuests: 3,
      description: 'Luxury executive suite with premium lounge access and minibar.',
    ),
    Room(
      roomCode: 'R301',
      roomType: 'Family Room',
      pricePerNight: 4200,
      maxGuests: 4,
      description: 'Ideal for families: 2 queen beds, spacious bathroom, and entertainment hub.',
    ),
  ];

  /// Initial sample bookings to demonstrate the bonus collision feature:
  /// e.g. R102 is booked from 20 to 23 of current month, R201 from 25 to 28.
  static List<BookingReservation> getInitialBookings({DateTime? referenceDate}) {
    final now = referenceDate ?? DateTime.now();
    final year = now.year;
    final month = now.month;

    return [
      BookingReservation(
        id: 'BKG-1001',
        roomCode: 'R102',
        checkIn: DateTime(year, month, 20),
        checkOut: DateTime(year, month, 23),
        guestCount: 2,
        totalPrice: 10500,
      ),
      BookingReservation(
        id: 'BKG-1002',
        roomCode: 'R201',
        checkIn: DateTime(year, month, 25),
        checkOut: DateTime(year, month, 28),
        guestCount: 3,
        totalPrice: 17400,
      ),
    ];
  }
}
