import '../models/car.dart';
import '../models/car_status.dart';
import '../models/seat.dart';
import '../models/seat_status.dart';
import '../models/user.dart';

/// Car-related helpers ported from `CarHelper` in the private app.
class CarHelper {
  CarHelper._();

  /// Formats a Tunisian car plate as "123 TN 4567".
  static String formatCarNo(String a, String b) {
    return '${a.trim()} TN ${b.trim()}';
  }

  /// Semantic color label used to badge a car's status in the UI.
  static String statusColorLabel(CarStatus status) =>
      status == CarStatus.reserved ? 'red' : 'green';

  static List<Car> getAvailableCars(List<Car> cars) =>
      cars.where((car) => car.status == CarStatus.available).toList();

  /// Checks that the user owns at least one available car whose seat
  /// layout is internally consistent: the driver seat (id 1) is locked and
  /// reserved by the user, and exactly the right number of the highest-id
  /// seats are locked to match `possibleSeats`.
  static bool hasValidSeatSetup(User user) {
    if (user.cars.isEmpty) return false;

    for (final car in user.cars) {
      if (car.status != CarStatus.available) continue;
      if (car.brand.isEmpty || car.carNo.isEmpty) continue;

      final seats = car.seats;
      final totalCarSeats = seats.length;
      final sharedSeats = car.possibleSeats;
      final expectedLockedSeats = totalCarSeats - (sharedSeats + 1);

      final driverSeat = seats.firstWhere(
        (s) => s.id == 1,
        orElse: () => Seat.empty(),
      );

      if (driverSeat.reservedBy != user.uid ||
          driverSeat.status != SeatStatus.lockedForDriver) {
        continue;
      }

      final lockedSeats = seats
          .where((s) => s.id != 1 && s.status == SeatStatus.locked)
          .map((s) => s.id)
          .toSet();

      final sortedSeatIds =
          seats.map((s) => s.id).where((id) => id != 1).toList()
            ..sort((a, b) => b.compareTo(a));

      final expectedLockedIds = sortedSeatIds.take(expectedLockedSeats).toSet();

      if (lockedSeats.length == expectedLockedIds.length &&
          lockedSeats.containsAll(expectedLockedIds)) {
        return true;
      }
    }
    return false;
  }
}
