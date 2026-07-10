import 'package:flutter_test/flutter_test.dart';
import 'package:droovo_mobile_public/helpers/ride_validation_helper.dart';
import 'package:droovo_mobile_public/models/user.dart';

import 'helpers/test_data.dart';

void main() {
  group('RideValidationHelper.validatePassengerSeats', () {
    test('a freshly opened ride (no passengers yet) is valid', () {
      final ride = TestData.rideByUid('ride-001-pending-open');
      expect(RideValidationHelper.validatePassengerSeats(ride), isTrue);
    });

    test('a fully booked ride is still valid (seats sum to capacity)', () {
      final ride = TestData.rideByUid('ride-002-full');
      expect(RideValidationHelper.validatePassengerSeats(ride), isTrue);
    });

    test('BUG DETECTOR: negative remaining passengers is invalid', () {
      final ride = TestData.rideByUid('ride-006-invalid-negative-seats');
      expect(RideValidationHelper.validatePassengerSeats(ride), isFalse);
    });

    test('remaining passengers cannot exceed the car capacity', () {
      final ride = TestData.rideByUid(
        'ride-001-pending-open',
      ).copyWith(remainingPassengers: 99);
      expect(RideValidationHelper.validatePassengerSeats(ride), isFalse);
    });

    test('seat arithmetic mismatch is detected', () {
      final ride = TestData.rideByUid(
        'ride-001-pending-open',
      ).copyWith(remainingPassengers: 1); // passengers(0) + 1 != 4 seats
      expect(RideValidationHelper.validatePassengerSeats(ride), isFalse);
    });
  });

  group('RideValidationHelper.canAcceptBooking', () {
    test('an open ride with free seats can accept a booking', () {
      final ride = TestData.rideByUid('ride-001-pending-open');
      expect(RideValidationHelper.canAcceptBooking(ride), isTrue);
    });

    test('a full ride cannot accept a booking', () {
      final ride = TestData.rideByUid('ride-002-full');
      expect(RideValidationHelper.canAcceptBooking(ride), isFalse);
    });

    test('a "collecting" (locked) ride cannot accept a booking', () {
      final ride = TestData.rideByUid('ride-003-collecting-locked');
      expect(RideValidationHelper.canAcceptBooking(ride), isFalse);
    });

    test('an external (imported) ride is read-only', () {
      final ride = TestData.rideByUid('ride-004-external-facebook');
      expect(ride.isExternal, isTrue);
      expect(RideValidationHelper.canAcceptBooking(ride), isFalse);
    });

    test('a completed ride cannot accept a booking even with free seats', () {
      final ride = TestData.rideByUid('ride-005-past');
      expect(RideValidationHelper.canAcceptBooking(ride), isFalse);
    });
  });

  group('RideValidationHelper.isRideInFuture', () {
    test('a ride scheduled years from now is in the future', () {
      final ride = TestData.rideByUid('ride-001-pending-open');
      final now = DateTime.utc(2026, 1, 1);
      expect(RideValidationHelper.isRideInFuture(ride, now: now), isTrue);
    });

    test('a past ride is not in the future', () {
      final ride = TestData.rideByUid('ride-005-past');
      final now = DateTime.utc(2026, 1, 1);
      expect(RideValidationHelper.isRideInFuture(ride, now: now), isFalse);
    });
  });

  group('RideValidationHelper.isPriceValid / isRideComplete', () {
    test('every fixture ride has a strictly positive price', () {
      for (final ride in TestData.rides) {
        expect(
          RideValidationHelper.isPriceValid(ride),
          isTrue,
          reason: '${ride.uid} should have a valid price',
        );
      }
    });

    test('a price of zero is invalid', () {
      final ride = TestData.rideByUid(
        'ride-001-pending-open',
      ).copyWith(price: 0);
      expect(RideValidationHelper.isPriceValid(ride), isFalse);
    });

    test('a ride with all required fields set is complete', () {
      final ride = TestData.rideByUid('ride-001-pending-open');
      expect(RideValidationHelper.isRideComplete(ride), isTrue);
    });

    test('a ride missing its driver id is incomplete', () {
      final ride = TestData.rideByUid('ride-001-pending-open');
      final corruptedDriver = const User(
        uid: '',
        displayName: 'Ghost Driver',
        email: '',
        phone: '',
      );
      final broken = ride.copyWith(driver: corruptedDriver);

      expect(RideValidationHelper.isRideComplete(broken), isFalse);
    });
  });

  group('RideConsistencyHelper.validateRideConsistency', () {
    test('a well-formed ride reports zero issues', () {
      final ride = TestData.rideByUid('ride-002-full');
      final now = DateTime.utc(2026, 1, 1);
      final report = RideConsistencyHelper.validateRideConsistency(
        ride,
        now: now,
      );

      expect(report['isConsistent'], isTrue);
      expect(report['issues'], isEmpty);
      expect(report['issueCount'], equals(0));
    });

    test(
      'detects broken seat arithmetic, a past date and an invalid price',
      () {
        final ride = TestData.rideByUid(
          'ride-006-invalid-negative-seats',
        ).copyWith(price: 0, rideTime: DateTime.utc(2020, 1, 1));
        final report = RideConsistencyHelper.validateRideConsistency(
          ride,
          now: DateTime.utc(2026, 1, 1),
        );

        expect(report['isConsistent'], isFalse);
        expect(report['issueCount'], greaterThanOrEqualTo(3));
        expect(report['issues'], contains(contains('Seat arithmetic error')));
        expect(
          report['issues'],
          contains(contains('Ride time is in the past')),
        );
        expect(report['issues'], contains(contains('Invalid price')));
      },
    );
  });
}
