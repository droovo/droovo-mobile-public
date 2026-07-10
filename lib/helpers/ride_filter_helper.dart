import '../models/ride.dart';
import '../models/ride_status.dart';
import 'ride_validation_helper.dart';

/// Filtering, sorting and grouping rules used across the private app's
/// ride list/search screens.
class RideFilterHelper {
  RideFilterHelper._();

  static List<Ride> availableRides(List<Ride> rides) =>
      rides.where((r) => r.rideStatus == RideStatus.pending).toList();

  static List<Ride> internalRides(List<Ride> rides) =>
      rides.where((r) => !r.isExternal).toList();

  static List<Ride> ridesWithAvailableSeats(List<Ride> rides) =>
      rides.where((r) => r.remainingPassengers > 0).toList();

  static List<Ride> bookableRides(List<Ride> rides) =>
      rides.where((r) => RideValidationHelper.canAcceptBooking(r)).toList();

  static List<Ride> sortByPriceAscending(List<Ride> rides) {
    final sorted = List<Ride>.of(rides);
    sorted.sort((a, b) => a.price.compareTo(b.price));
    return sorted;
  }

  static List<Ride> sortByRemainingSeatsDescending(List<Ride> rides) {
    final sorted = List<Ride>.of(rides);
    sorted.sort(
      (a, b) => b.remainingPassengers.compareTo(a.remainingPassengers),
    );
    return sorted;
  }

  static Map<String, List<Ride>> groupByDestination(List<Ride> rides) {
    final grouped = <String, List<Ride>>{};
    for (final ride in rides) {
      grouped.putIfAbsent(ride.destination, () => []).add(ride);
    }
    return grouped;
  }

  /// Cheapest ride that can still be booked, or `null` if none qualify.
  static Ride? findCheapestBookableRide(List<Ride> rides) {
    final bookable = sortByPriceAscending(bookableRides(rides));
    return bookable.isEmpty ? null : bookable.first;
  }

  /// Keeps the last occurrence of each ride uid, dropping earlier
  /// duplicates (e.g. from paginated/merged Firestore snapshots).
  static List<Ride> deduplicateById(List<Ride> rides) {
    final unique = <String, Ride>{};
    for (final ride in rides) {
      unique[ride.uid] = ride;
    }
    return unique.values.toList();
  }
}
