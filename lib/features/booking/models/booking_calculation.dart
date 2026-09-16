import 'package:flutter/foundation.dart';

enum BookingValidationStatus {
  valid,
  incomplete,
  pastCheckIn,
  sameDay,
  checkOutBeforeCheckIn,
  roomUnavailable,
  exceedsMaxGuests,
}

@immutable
class BookingCalculation {
  final int nights;
  final int pricePerNight;
  final int totalPrice;
  final BookingValidationStatus status;
  final String? errorMessage;

  const BookingCalculation({
    required this.nights,
    required this.pricePerNight,
    required this.totalPrice,
    required this.status,
    this.errorMessage,
  });

  bool get isValid => status == BookingValidationStatus.valid;

  factory BookingCalculation.empty() {
    return const BookingCalculation(
      nights: 0,
      pricePerNight: 0,
      totalPrice: 0,
      status: BookingValidationStatus.incomplete,
      errorMessage: null,
    );
  }

  factory BookingCalculation.invalid({
    required BookingValidationStatus status,
    required String errorMessage,
    int nights = 0,
    int pricePerNight = 0,
  }) {
    return BookingCalculation(
      nights: nights,
      pricePerNight: pricePerNight,
      totalPrice: 0,
      status: status,
      errorMessage: errorMessage,
    );
  }

  factory BookingCalculation.valid({
    required int nights,
    required int pricePerNight,
    required int totalPrice,
  }) {
    return BookingCalculation(
      nights: nights,
      pricePerNight: pricePerNight,
      totalPrice: totalPrice,
      status: BookingValidationStatus.valid,
      errorMessage: null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingCalculation &&
          runtimeType == other.runtimeType &&
          nights == other.nights &&
          pricePerNight == other.pricePerNight &&
          totalPrice == other.totalPrice &&
          status == other.status &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      nights.hashCode ^
      pricePerNight.hashCode ^
      totalPrice.hashCode ^
      status.hashCode ^
      errorMessage.hashCode;

  @override
  String toString() {
    return 'BookingCalculation(nights: $nights, pricePerNight: $pricePerNight, totalPrice: $totalPrice, status: $status, errorMessage: $errorMessage)';
  }
}
