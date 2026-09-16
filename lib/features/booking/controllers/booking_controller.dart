import 'package:flutter/material.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/dialog_snackbar_helper.dart';
import '../models/booking_calculation.dart';
import '../models/booking_reservation.dart';
import '../models/room.dart';
import '../services/booking_service.dart';

class BookingController extends ChangeNotifier {
  final BookingService _bookingService;

  DateTime? _checkIn;
  DateTime? _checkOut;
  Room? _selectedRoom;
  int? _guestFilter;
  bool _isBookingInProgress = false;

  late BookingCalculation _calculation;

  BookingController({BookingService? bookingService})
      : _bookingService = bookingService ?? InMemoryBookingService() {
    _recalculate();
  }

  // Getters
  DateTime? get checkIn => _checkIn;
  DateTime? get checkOut => _checkOut;
  Room? get selectedRoom => _selectedRoom;
  int? get guestFilter => _guestFilter;
  bool get isBookingInProgress => _isBookingInProgress;
  BookingCalculation get calculation => _calculation;

  List<Room> get rooms => _bookingService.getRooms(minCapacity: _guestFilter);

  /// Checks whether a room is currently available for the chosen dates.
  bool isRoomAvailable(Room room) {
    if (_checkIn == null || _checkOut == null) return true;
    return _bookingService.isRoomAvailable(room.roomCode, _checkIn!, _checkOut!);
  }

  /// Sets the check-in date and triggers recalculation.
  void setCheckIn(DateTime date) {
    _checkIn = DateTime(date.year, date.month, date.day);

    // If existing check-out is before or same day as new check-in, reset check-out
    if (_checkOut != null && !_checkOut!.isAfter(_checkIn!)) {
      _checkOut = null;
    }

    _recalculate();
    notifyListeners();
  }

  /// Sets the check-out date and triggers recalculation.
  void setCheckOut(DateTime date) {
    _checkOut = DateTime(date.year, date.month, date.day);
    _recalculate();
    notifyListeners();
  }

  /// Selects a room.
  void selectRoom(Room room) {
    _selectedRoom = room;
    _recalculate();
    notifyListeners();
  }

  /// Clears room selection.
  void clearRoomSelection() {
    _selectedRoom = null;
    _recalculate();
    notifyListeners();
  }

  /// Sets the guest capacity filter (null = all).
  void setGuestFilter(int? minCapacity) {
    _guestFilter = minCapacity;

    // If the currently selected room does not fit the new filter, clear selection
    if (_selectedRoom != null &&
        minCapacity != null &&
        _selectedRoom!.maxGuests < minCapacity) {
      _selectedRoom = null;
    }

    _recalculate();
    notifyListeners();
  }

  /// Resets all inputs to starting state.
  void reset() {
    _checkIn = null;
    _checkOut = null;
    _selectedRoom = null;
    _guestFilter = null;
    _recalculate();
    notifyListeners();
  }

  void _recalculate() {
    _calculation = _bookingService.evaluateBooking(
      checkIn: _checkIn,
      checkOut: _checkOut,
      room: _selectedRoom,
      guestCount: _guestFilter,
    );
  }

  /// Confirms booking with validation checks, confirmation dialog, and feedback.
  Future<void> confirmBooking(BuildContext context) async {
    // 1. If not valid, notify user clearly instead of failing silently
    if (!_calculation.isValid) {
      final message = _calculation.errorMessage ?? 'Please complete all required booking details.';
      DialogSnackbarHelper.showErrorSnackBar(context, message);
      return;
    }

    final room = _selectedRoom!;
    final inDate = _checkIn!;
    final outDate = _checkOut!;
    final nights = _calculation.nights;
    final totalFormatted = DateFormatter.formatCurrency(_calculation.totalPrice);

    // 2. Prompt confirmation dialog
    final shouldProceed = await DialogSnackbarHelper.showConfirmationDialog(
      context,
      title: 'Confirm Your Reservation',
      content:
          'You are booking ${room.roomType} (${room.roomCode}) from ${DateFormatter.formatShort(inDate)} to ${DateFormatter.formatShort(outDate)} for $nights night${nights > 1 ? "s" : ""}.\n\nTotal Price: $totalFormatted',
      confirmText: 'Book Now',
    );

    if (shouldProceed != true || !context.mounted) return;

    _isBookingInProgress = true;
    notifyListeners();

    final reservation = BookingReservation(
      id: 'BKG-${DateTime.now().millisecondsSinceEpoch % 100000}',
      roomCode: room.roomCode,
      checkIn: inDate,
      checkOut: outDate,
      guestCount: _guestFilter ?? room.maxGuests,
      totalPrice: _calculation.totalPrice,
    );

    final success = await _bookingService.bookRoom(reservation);

    _isBookingInProgress = false;

    if (!context.mounted) return;

    if (success) {
      // 1. Close any open modal bottom sheet first
      Navigator.of(context, rootNavigator: false).popUntil((route) => route.isFirst);

      // 2. Clear selected room and dates so the form resets cleanly
      _selectedRoom = null;
      _checkIn = null;
      _checkOut = null;
      _recalculate();
      notifyListeners();

      // 3. Display success confirmation dialog
      await DialogSnackbarHelper.showSuccessDialog(
        context,
        title: 'Booking Confirmed!',
        message:
            'Booking Reference: ${reservation.id}\nRoom: ${room.roomCode} - ${room.roomType}\nDates: ${DateFormatter.formatShort(inDate)} to ${DateFormatter.formatShort(outDate)}\nNights: $nights\nTotal Paid: $totalFormatted',
      );
    } else {
      _recalculate();
      notifyListeners();
      DialogSnackbarHelper.showErrorSnackBar(
        context,
        'Booking failed. The room was booked by someone else for these dates.',
      );
    }
  }
}
