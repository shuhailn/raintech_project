import 'package:flutter/foundation.dart';

@immutable
class Room {
  final String roomCode;
  final String roomType;
  final int pricePerNight;
  final int maxGuests;
  final String? description;

  const Room({
    required this.roomCode,
    required this.roomType,
    required this.pricePerNight,
    required this.maxGuests,
    this.description,
  });

  Room copyWith({
    String? roomCode,
    String? roomType,
    int? pricePerNight,
    int? maxGuests,
    String? description,
  }) {
    return Room(
      roomCode: roomCode ?? this.roomCode,
      roomType: roomType ?? this.roomType,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      maxGuests: maxGuests ?? this.maxGuests,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomCode': roomCode,
      'roomType': roomType,
      'pricePerNight': pricePerNight,
      'maxGuests': maxGuests,
      if (description != null) 'description': description,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      roomCode: map['roomCode'] as String,
      roomType: map['roomType'] as String,
      pricePerNight: (map['pricePerNight'] as num).toInt(),
      maxGuests: (map['maxGuests'] as num).toInt(),
      description: map['description'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Room &&
          runtimeType == other.runtimeType &&
          roomCode == other.roomCode &&
          roomType == other.roomType &&
          pricePerNight == other.pricePerNight &&
          maxGuests == other.maxGuests;

  @override
  int get hashCode =>
      roomCode.hashCode ^
      roomType.hashCode ^
      pricePerNight.hashCode ^
      maxGuests.hashCode;

  @override
  String toString() {
    return 'Room(roomCode: $roomCode, roomType: $roomType, pricePerNight: $pricePerNight, maxGuests: $maxGuests)';
  }
}
