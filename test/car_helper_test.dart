import 'package:flutter_test/flutter_test.dart';
import 'package:droovo_mobile_public/helpers/car_helper.dart';
import 'package:droovo_mobile_public/models/car.dart';
import 'package:droovo_mobile_public/models/car_status.dart';
import 'package:droovo_mobile_public/models/seat.dart';
import 'package:droovo_mobile_public/models/seat_status.dart';
import 'package:droovo_mobile_public/models/user.dart';

import 'helpers/test_data.dart';

void main() {
  test('formatCarNo builds a Tunisian plate string', () {
    expect(CarHelper.formatCarNo(' 123 ', ' 4567 '), equals('123 TN 4567'));
  });

  group('statusColorLabel', () {
    test('reserved cars are flagged red', () {
      expect(CarHelper.statusColorLabel(CarStatus.reserved), equals('red'));
    });

    test('every other status is flagged green', () {
      expect(CarHelper.statusColorLabel(CarStatus.available), equals('green'));
      expect(CarHelper.statusColorLabel(CarStatus.selected), equals('green'));
      expect(CarHelper.statusColorLabel(CarStatus.locked), equals('green'));
    });
  });

  test('getAvailableCars keeps only available cars from the fixture', () {
    final available = CarHelper.getAvailableCars(TestData.cars);
    expect(available.map((c) => c.uid), equals(['car-001', 'car-002']));
  });

  group('hasValidSeatSetup', () {
    test('is true for a user whose car has a correctly locked driver seat', () {
      // 5 physical seats, 3 shared with passengers -> exactly 1 extra seat
      // (the highest id) must be permanently locked: 5 - (3 + 1) = 1.
      const car = Car(
        uid: 'car-consistent',
        brand: 'Toyota',
        model: 'Corolla',
        color: 'White',
        carNo: '123-TN-4567',
        possibleSeats: 3,
        airConditioner: true,
        status: CarStatus.available,
        seats: [
          Seat(
            id: 1,
            reservedBy: 'user-driver-1',
            status: SeatStatus.lockedForDriver,
          ),
          Seat(id: 2, reservedBy: '', status: SeatStatus.available),
          Seat(id: 3, reservedBy: 'passenger-1', status: SeatStatus.reserved),
          Seat(id: 4, reservedBy: '', status: SeatStatus.available),
          Seat(id: 5, reservedBy: '', status: SeatStatus.locked),
        ],
      );
      const user = User(
        uid: 'user-driver-1',
        displayName: 'Amine Driver',
        email: 'amine@example.com',
        phone: '+21620000001',
        isDriver: true,
        cars: [car],
      );

      expect(CarHelper.hasValidSeatSetup(user), isTrue);
    });

    test('is false when the user owns no cars', () {
      const user = User(
        uid: 'user-x',
        displayName: 'No Car',
        email: '',
        phone: '',
      );
      expect(CarHelper.hasValidSeatSetup(user), isFalse);
    });

    test('is false when the driver seat is reserved by someone else', () {
      const car = Car(
        uid: 'car-tampered',
        brand: 'Toyota',
        model: 'Yaris',
        color: 'Grey',
        carNo: '999-TN-0000',
        possibleSeats: 4,
        airConditioner: false,
        status: CarStatus.available,
        seats: [
          Seat(
            id: 1,
            reservedBy: 'someone-else',
            status: SeatStatus.lockedForDriver,
          ),
          Seat(id: 2, reservedBy: '', status: SeatStatus.available),
          Seat(id: 3, reservedBy: '', status: SeatStatus.available),
          Seat(id: 4, reservedBy: '', status: SeatStatus.available),
          Seat(id: 5, reservedBy: '', status: SeatStatus.locked),
        ],
      );
      const user = User(
        uid: 'user-driver-1',
        displayName: 'Amine Driver',
        email: '',
        phone: '',
        isDriver: true,
        cars: [car],
      );

      expect(CarHelper.hasValidSeatSetup(user), isFalse);
    });
  });
}
