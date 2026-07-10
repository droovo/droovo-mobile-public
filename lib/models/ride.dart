import 'car.dart';
import 'lat_lng.dart';
import 'ride_status.dart';
import 'user.dart';

/// Plain equivalent of the private app's `RidesEntity`, stripped of
/// Firestore/Hive annotations — just the fields the public helpers reason
/// about.
class Ride {
  final String uid;
  final String pickUp;
  final String destination;
  final String pickupState;
  final String destinationState;
  final String phone;
  final double price;
  final int remainingPassengers;
  final int requestedPassengers;
  final int baggageCapacity;
  final DateTime rideTime;
  final RideStatus rideStatus;
  final String source;
  final Car car;
  final User driver;
  final List<User> passengers;
  final LatLng pickupGeoPoint;
  final LatLng destinationGeoPoint;

  const Ride({
    required this.uid,
    required this.pickUp,
    required this.destination,
    this.pickupState = '',
    this.destinationState = '',
    required this.phone,
    required this.price,
    required this.remainingPassengers,
    required this.requestedPassengers,
    this.baggageCapacity = 0,
    required this.rideTime,
    required this.rideStatus,
    this.source = 'app',
    required this.car,
    required this.driver,
    this.passengers = const [],
    required this.pickupGeoPoint,
    required this.destinationGeoPoint,
  });

  /// Rides scraped/imported from an external source (e.g. Facebook) are
  /// read-only in the private app: no new bookings are accepted on them.
  bool get isExternal => source != 'app';

  factory Ride.fromJson(Map<String, dynamic> json) => Ride(
        uid: json['uid'] as String,
        pickUp: json['pickUp'] as String,
        destination: json['destination'] as String,
        pickupState: json['pickupState'] as String? ?? '',
        destinationState: json['destinationState'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        price: (json['price'] as num).toDouble(),
        remainingPassengers: json['remainingPassengers'] as int,
        requestedPassengers: json['requestedPassengers'] as int,
        baggageCapacity: json['baggageCapacity'] as int? ?? 0,
        rideTime: DateTime.parse(json['rideTime'] as String),
        rideStatus: RideStatus.values.byName(json['rideStatus'] as String),
        source: json['source'] as String? ?? 'app',
        car: Car.fromJson(json['car'] as Map<String, dynamic>),
        driver: User.fromJson(json['driver'] as Map<String, dynamic>),
        passengers: (json['passengers'] as List<dynamic>? ?? [])
            .map((p) => User.fromJson(p as Map<String, dynamic>))
            .toList(),
        pickupGeoPoint:
            LatLng.fromJson(json['pickupGeoPoint'] as Map<String, dynamic>),
        destinationGeoPoint: LatLng.fromJson(
            json['destinationGeoPoint'] as Map<String, dynamic>),
      );

  Ride copyWith({
    String? uid,
    String? pickUp,
    String? destination,
    String? pickupState,
    String? destinationState,
    String? phone,
    double? price,
    int? remainingPassengers,
    int? requestedPassengers,
    int? baggageCapacity,
    DateTime? rideTime,
    RideStatus? rideStatus,
    String? source,
    Car? car,
    User? driver,
    List<User>? passengers,
    LatLng? pickupGeoPoint,
    LatLng? destinationGeoPoint,
  }) {
    return Ride(
      uid: uid ?? this.uid,
      pickUp: pickUp ?? this.pickUp,
      destination: destination ?? this.destination,
      pickupState: pickupState ?? this.pickupState,
      destinationState: destinationState ?? this.destinationState,
      phone: phone ?? this.phone,
      price: price ?? this.price,
      remainingPassengers: remainingPassengers ?? this.remainingPassengers,
      requestedPassengers: requestedPassengers ?? this.requestedPassengers,
      baggageCapacity: baggageCapacity ?? this.baggageCapacity,
      rideTime: rideTime ?? this.rideTime,
      rideStatus: rideStatus ?? this.rideStatus,
      source: source ?? this.source,
      car: car ?? this.car,
      driver: driver ?? this.driver,
      passengers: passengers ?? this.passengers,
      pickupGeoPoint: pickupGeoPoint ?? this.pickupGeoPoint,
      destinationGeoPoint: destinationGeoPoint ?? this.destinationGeoPoint,
    );
  }
}
