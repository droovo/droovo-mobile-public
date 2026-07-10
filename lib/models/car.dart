import 'car_status.dart';
import 'seat.dart';

class Car {
  final String uid;
  final String brand;
  final String model;
  final String color;
  final String carNo;
  final int possibleSeats;
  final bool airConditioner;
  final CarStatus status;
  final List<Seat> seats;

  const Car({
    required this.uid,
    required this.brand,
    required this.model,
    required this.color,
    required this.carNo,
    required this.possibleSeats,
    required this.airConditioner,
    required this.status,
    this.seats = const [],
  });

  factory Car.fromJson(Map<String, dynamic> json) => Car(
    uid: json['uid'] as String,
    brand: json['brand'] as String,
    model: json['model'] as String,
    color: json['color'] as String? ?? '',
    carNo: json['carNo'] as String? ?? '',
    possibleSeats: json['possibleSeats'] as int,
    airConditioner: json['airConditioner'] as bool? ?? false,
    status: CarStatus.values.byName(json['status'] as String),
    seats: (json['seats'] as List<dynamic>? ?? [])
        .map((s) => Seat.fromJson(s as Map<String, dynamic>))
        .toList(),
  );

  Car copyWith({List<Seat>? seats, CarStatus? status}) => Car(
    uid: uid,
    brand: brand,
    model: model,
    color: color,
    carNo: carNo,
    possibleSeats: possibleSeats,
    airConditioner: airConditioner,
    status: status ?? this.status,
    seats: seats ?? this.seats,
  );
}
