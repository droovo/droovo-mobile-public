import 'package:flutter_test/flutter_test.dart';
import 'package:droovo_mobile_public/helpers/seat_helper.dart';
import 'package:droovo_mobile_public/models/seat.dart';
import 'package:droovo_mobile_public/models/seat_status.dart';

import 'helpers/test_data.dart';

void main() {
  group('SeatHelper.getLockedSeatIds', () {
    test('4 passengers locks no extra seats', () {
      expect(SeatHelper.getLockedSeatIds(4), isEmpty);
    });

    test('3 passengers locks seat 4', () {
      expect(SeatHelper.getLockedSeatIds(3), equals([4]));
    });

    test('2 passengers locks seats 3 and 4', () {
      expect(SeatHelper.getLockedSeatIds(2), equals([3, 4]));
    });

    test('1 passenger locks seats 3, 4 and 5', () {
      expect(SeatHelper.getLockedSeatIds(1), equals([3, 4, 5]));
    });

    test('an unsupported passenger count throws', () {
      expect(() => SeatHelper.getLockedSeatIds(0), throwsArgumentError);
      expect(() => SeatHelper.getLockedSeatIds(5), throwsArgumentError);
    });
  });

  group('SeatHelper.generateSeats', () {
    test('always locks seat 1 for the driver', () {
      final seats = SeatHelper.generateSeats('driver-42', 4);
      final driverSeat = seats.firstWhere((s) => s.id == 1);

      expect(driverSeat.status, equals(SeatStatus.lockedForDriver));
      expect(driverSeat.reservedBy, equals('driver-42'));
    });

    test('locks the correct seats for a 2-passenger ride', () {
      final seats = SeatHelper.generateSeats('driver-1', 2);
      final lockedIds =
          seats.where((s) => s.status == SeatStatus.locked).map((s) => s.id);

      // getLockedSeatIds(2) only locks seats 3 and 4 -- seat 5 stays
      // available even though it won't be offered for a 2-passenger ride.
      expect(lockedIds, equals([3, 4]));
      expect(
        seats
            .where((s) => s.status == SeatStatus.available)
            .map((s) => s.id),
        equals([2, 5]),
      );
    });

    test('falls back to the default lock count when passengerCount is 0', () {
      final seats = SeatHelper.generateSeats('driver-1', 0);
      final lockedIds =
          seats.where((s) => s.status == SeatStatus.locked).map((s) => s.id);
      expect(lockedIds, isEmpty); // default (4) locks nothing extra
    });
  });

  group('SeatHelper.generateSeatsForCar', () {
    test('generates a fresh layout when there are no existing seats', () {
      final seats = SeatHelper.generateSeatsForCar([], driverId: 'driver-9');
      expect(seats, hasLength(SeatHelper.totalSeats));
      expect(seats.first.status, equals(SeatStatus.lockedForDriver));
    });

    test('re-locks seat 1 for the driver even if it was not locked before', () {
      final existing = [
        const Seat(id: 1, reservedBy: '', status: SeatStatus.available),
        const Seat(id: 2, reservedBy: '', status: SeatStatus.available),
      ];

      final seats = SeatHelper.generateSeatsForCar(existing);
      final driverSeat = seats.firstWhere((s) => s.id == 1);
      expect(driverSeat.status, equals(SeatStatus.lockedForDriver));
    });

    test('keeps existing seats sorted by id', () {
      final existing = [
        const Seat(id: 2, reservedBy: '', status: SeatStatus.available),
        const Seat(id: 1, reservedBy: '', status: SeatStatus.available),
      ];

      final seats = SeatHelper.generateSeatsForCar(existing);
      expect(seats.map((s) => s.id).toList(), equals([1, 2]));
    });
  });

  test('seatsToPossibleSeats subtracts the driver seat', () {
    expect(SeatHelper.seatsToPossibleSeats(5), equals(4));
    expect(SeatHelper.seatsToPossibleSeats(1), equals(0));
    expect(SeatHelper.seatsToPossibleSeats(0), equals(0));
  });

  group('using fixture data', () {
    test('car-001 has available seats', () {
      final car = TestData.carByUid('car-001');
      expect(SeatHelper.hasAvailableSeats(car.seats), isTrue);
    });

    test('car-003 (fully reserved) has no available seats', () {
      final car = TestData.carByUid('car-003');
      expect(SeatHelper.hasAvailableSeats(car.seats), isFalse);
    });

    test('getAvailableSeats returns only the available ones for car-002', () {
      final car = TestData.carByUid('car-002');
      final available = SeatHelper.getAvailableSeats(car.seats);
      expect(available.map((s) => s.id), equals([3]));
    });
  });

  group('SeatHelper.getMinimumSeats', () {
    test('never goes negative even if remaining exceeds requested', () {
      final min = SeatHelper.getMinimumSeats(
        requestedPassengers: 1,
        remainingPassengers: 3,
      );
      expect(min, equals(0));
    });

    test('returns the booked-passenger count otherwise', () {
      final min = SeatHelper.getMinimumSeats(
        requestedPassengers: 3,
        remainingPassengers: 1,
      );
      expect(min, equals(2));
    });
  });
}
