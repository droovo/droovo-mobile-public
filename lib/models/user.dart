import 'car.dart';

class User {
  final String uid;
  final String displayName;
  final String email;
  final String phone;
  final bool isDriver;
  final List<Car> cars;

  const User({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.phone,
    this.isDriver = false,
    this.cars = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        uid: json['uid'] as String,
        displayName: json['displayName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        isDriver: json['isDriver'] as bool? ?? false,
        cars: (json['cars'] as List<dynamic>? ?? [])
            .map((c) => Car.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}
