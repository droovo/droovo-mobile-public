import '../models/ride.dart';
import '../models/ride_status.dart';

/// Critical booking-invariant checks ported from the private app's ride
/// validation logic. These are the rules that, if broken, corrupt the
/// booking system (double-booked seats, negative seat counts, etc.).
class RideValidationHelper {
  RideValidationHelper._();

  /// Rule: `passengers.length + remainingPassengers == car.possibleSeats`,
  /// and both counts must stay non-negative.
  static bool validatePassengerSeats(Ride ride) {
    if (ride.remainingPassengers < 0) return false;
    if (ride.remainingPassengers > ride.car.possibleSeats) return false;
    if (ride.passengers.length + ride.remainingPassengers !=
        ride.car.possibleSeats) {
      return false;
    }
    if (ride.requestedPassengers < 0) return false;
    return true;
  }

  /// Whether the ride can accept a new booking: seats left, status still
  /// open for booking, and not an external (read-only) ride.
  static bool canAcceptBooking(Ride ride) {
    if (ride.remainingPassengers <= 0) return false;
    if (ride.rideStatus != RideStatus.pending) return false;
    if (ride.isExternal) return false;
    return true;
  }

  /// [now] is injectable so tests don't depend on the real wall clock.
  static bool isRideInFuture(Ride ride, {DateTime? now}) {
    return ride.rideTime.isAfter(now ?? DateTime.now());
  }

  static bool isPriceValid(Ride ride) => ride.price > 0;

  static bool isRideComplete(Ride ride) {
    return ride.uid.isNotEmpty &&
        ride.destination.isNotEmpty &&
        ride.pickUp.isNotEmpty &&
        ride.phone.isNotEmpty &&
        ride.driver.uid.isNotEmpty;
  }
}

/// Aggregates every consistency rule into a single report, useful for
/// diagnosing corrupted ride data in one pass.
class RideConsistencyHelper {
  RideConsistencyHelper._();

  static Map<String, dynamic> validateRideConsistency(Ride ride,
      {DateTime? now}) {
    final issues = <String>[];

    if (ride.passengers.length + ride.remainingPassengers !=
        ride.car.possibleSeats) {
      issues.add(
        'Seat arithmetic error: ${ride.passengers.length} passengers + '
        '${ride.remainingPassengers} remaining ≠ ${ride.car.possibleSeats} total seats',
      );
    }

    if (!ride.rideTime.isAfter(now ?? DateTime.now())) {
      issues.add('Ride time is in the past: ${ride.rideTime}');
    }

    if (ride.price <= 0) {
      issues.add('Invalid price: ${ride.price}');
    }

    if (ride.driver.uid.isEmpty) {
      issues.add('Driver UID is empty');
    }

    if (ride.pickUp.isEmpty || ride.destination.isEmpty) {
      issues.add('Missing pickup or destination location');
    }

    return {
      'isConsistent': issues.isEmpty,
      'issues': issues,
      'issueCount': issues.length,
    };
  }
}
