import 'package:flutter/foundation.dart';

@immutable
class BookingReservation {
  final String id;
  final String roomCode;
  final DateTime checkIn;
  final DateTime checkOut;
  final int? guestCount;
  final int? totalPrice;

  const BookingReservation({
    required this.id,
    required this.roomCode,
    required this.checkIn,
    required this.checkOut,
    this.guestCount,
    this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomCode': roomCode,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut.toIso8601String(),
      if (guestCount != null) 'guestCount': guestCount,
      if (totalPrice != null) 'totalPrice': totalPrice,
    };
  }

  factory BookingReservation.fromMap(Map<String, dynamic> map) {
    return BookingReservation(
      id: map['id'] as String,
      roomCode: map['roomCode'] as String,
      checkIn: DateTime.parse(map['checkIn'] as String),
      checkOut: DateTime.parse(map['checkOut'] as String),
      guestCount: (map['guestCount'] as num?)?.toInt(),
      totalPrice: (map['totalPrice'] as num?)?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingReservation &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          roomCode == other.roomCode &&
          checkIn == other.checkIn &&
          checkOut == other.checkOut;

  @override
  int get hashCode =>
      id.hashCode ^ roomCode.hashCode ^ checkIn.hashCode ^ checkOut.hashCode;

  @override
  String toString() {
    return 'BookingReservation(id: $id, roomCode: $roomCode, checkIn: $checkIn, checkOut: $checkOut)';
  }
}
