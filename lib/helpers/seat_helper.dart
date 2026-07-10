import '../models/seat.dart';
import '../models/seat_status.dart';

/// Seat-assignment rules ported from `CarHelper` in the private app.
/// Seat 1 is always the driver's seat; the remaining seats get locked or
/// released depending on how many passengers are requested.
class SeatHelper {
  SeatHelper._();

  static const int totalSeats = 5;
  static const int defaultLockedSeatsCount = 4;

  /// Which seat ids must stay locked (unavailable) for a given
  /// [passengerCount], beyond the driver's own seat.
  static List<int> getLockedSeatIds(int passengerCount) {
    switch (passengerCount) {
      case 4:
        return [];
      case 3:
        return [4];
      case 2:
        return [3, 4];
      case 1:
        return [3, 4, 5];
      default:
        throw ArgumentError('Invalid passengerCount: $passengerCount');
    }
  }

  /// Builds a fresh seat layout for a car: seat 1 locked for the driver,
  /// seats implied by [passengerCount] locked, the rest available.
  static List<Seat> generateSeats(String userId, int passengerCount) {
    final lockedIds = getLockedSeatIds(
      passengerCount > 0 ? passengerCount : defaultLockedSeatsCount,
    );

    return List.generate(totalSeats, (i) {
      final id = i + 1;
      if (id == 1) {
        return Seat(
            id: id, reservedBy: userId, status: SeatStatus.lockedForDriver);
      } else if (lockedIds.contains(id)) {
        return Seat(id: id, reservedBy: '', status: SeatStatus.locked);
      } else {
        return Seat(id: id, reservedBy: '', status: SeatStatus.available);
      }
    });
  }

  /// Reuses [existingSeats] when present (just re-locking seat 1 for the
  /// driver); otherwise falls back to a freshly generated layout.
  static List<Seat> generateSeatsForCar(
    List<Seat> existingSeats, {
    String driverId = '',
  }) {
    if (existingSeats.isEmpty) {
      return generateSeats(driverId, defaultLockedSeatsCount);
    }

    return existingSeats.map((seat) {
      return Seat(
        id: seat.id,
        status: seat.id == 1 ? SeatStatus.lockedForDriver : seat.status,
        reservedBy: seat.reservedBy,
      );
    }).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
  }

  /// Converts a seat count that includes the driver into the
  /// "possibleSeats" count used elsewhere (passenger seats only).
  static int seatsToPossibleSeats(int seatsIncludingDriver) {
    return seatsIncludingDriver <= 1 ? 0 : seatsIncludingDriver - 1;
  }

  static bool hasAvailableSeats(List<Seat> seats) => seats.any(
        (seat) =>
            seat.status == SeatStatus.available ||
            seat.status == SeatStatus.selected,
      );

  static List<Seat> getAvailableSeats(List<Seat> seats) =>
      seats.where((seat) => seat.status == SeatStatus.available).toList();

  /// Minimum number of seats a booking/edit form must allow, derived from
  /// how many passengers already booked vs. how many are still requested.
  static int getMinimumSeats({
    required int requestedPassengers,
    required int remainingPassengers,
  }) {
    final result = requestedPassengers - remainingPassengers;
    return result < 0 ? 0 : result;
  }
}
