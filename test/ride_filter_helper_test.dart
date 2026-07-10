import 'package:flutter_test/flutter_test.dart';
import 'package:droovo_mobile_public/helpers/ride_filter_helper.dart';
import 'package:droovo_mobile_public/models/ride_status.dart';

import 'helpers/test_data.dart';

void main() {
  group('RideFilterHelper', () {
    test('availableRides keeps only pending rides', () {
      final available = RideFilterHelper.availableRides(TestData.rides);
      expect(
        available.map((r) => r.uid),
        containsAll([
          'ride-001-pending-open',
          'ride-002-full',
          'ride-004-external-facebook',
          'ride-006-invalid-negative-seats',
        ]),
      );
      expect(available.map((r) => r.uid), isNot(contains('ride-003-collecting-locked')));
      expect(available.map((r) => r.uid), isNot(contains('ride-005-past')));
    });

    test('internalRides excludes externally imported rides', () {
      final internal = RideFilterHelper.internalRides(TestData.rides);
      expect(internal.map((r) => r.uid), isNot(contains('ride-004-external-facebook')));
      expect(internal, hasLength(TestData.rides.length - 1));
    });

    test('ridesWithAvailableSeats keeps only rides with remainingPassengers > 0', () {
      final withSeats = RideFilterHelper.ridesWithAvailableSeats(TestData.rides);
      expect(
        withSeats.map((r) => r.uid),
        containsAll([
          'ride-001-pending-open',
          'ride-003-collecting-locked',
          'ride-004-external-facebook',
          'ride-005-past',
        ]),
      );
      expect(withSeats.map((r) => r.uid), isNot(contains('ride-002-full')));
      expect(withSeats.map((r) => r.uid), isNot(contains('ride-006-invalid-negative-seats')));
    });

    test('bookableRides applies every booking rule at once', () {
      final bookable = RideFilterHelper.bookableRides(TestData.rides);
      expect(bookable.map((r) => r.uid), equals(['ride-001-pending-open']));
    });

    test('sortByPriceAscending orders the cheapest ride first', () {
      final sorted = RideFilterHelper.sortByPriceAscending(TestData.rides);
      expect(sorted.first.uid, equals('ride-003-collecting-locked')); // 5.0 DT
      expect(sorted.last.uid, equals('ride-001-pending-open')); // 20.0 DT
      for (var i = 0; i < sorted.length - 1; i++) {
        expect(sorted[i].price, lessThanOrEqualTo(sorted[i + 1].price));
      }
    });

    test('sortByRemainingSeatsDescending orders the fullest seat count first', () {
      final sorted =
          RideFilterHelper.sortByRemainingSeatsDescending(TestData.rides);
      for (var i = 0; i < sorted.length - 1; i++) {
        expect(sorted[i].remainingPassengers,
            greaterThanOrEqualTo(sorted[i + 1].remainingPassengers));
      }
      expect(sorted.last.uid, equals('ride-006-invalid-negative-seats')); // -1
    });

    test('groupByDestination buckets rides sharing the same destination', () {
      final rideA = TestData.rideByUid('ride-001-pending-open')
          .copyWith(destination: 'City A');
      final rideB = TestData.rideByUid('ride-002-full')
          .copyWith(destination: 'City B');
      final rideC = TestData.rideByUid('ride-003-collecting-locked')
          .copyWith(destination: 'City A');

      final grouped = RideFilterHelper.groupByDestination([rideA, rideB, rideC]);

      expect(grouped.keys, containsAll(['City A', 'City B']));
      expect(grouped['City A'], hasLength(2));
      expect(grouped['City B'], hasLength(1));
    });

    test('findCheapestBookableRide picks the lowest price among bookable rides', () {
      final cheaperRide = TestData.rideByUid('ride-002-full').copyWith(
        uid: 'ride-002-reopened',
        remainingPassengers: 2,
        rideStatus: RideStatus.pending,
        price: 5.0,
      );
      final rides = [TestData.rideByUid('ride-001-pending-open'), cheaperRide];

      final cheapest = RideFilterHelper.findCheapestBookableRide(rides);
      expect(cheapest?.uid, equals('ride-002-reopened'));
    });

    test('findCheapestBookableRide returns null when nothing is bookable', () {
      final noneBookable = [
        TestData.rideByUid('ride-002-full'),
        TestData.rideByUid('ride-003-collecting-locked'),
      ];
      expect(RideFilterHelper.findCheapestBookableRide(noneBookable), isNull);
    });

    test('deduplicateById keeps a single ride per uid', () {
      final original = TestData.rideByUid('ride-001-pending-open');
      final duplicate = original.copyWith(price: 999);
      final rides = [original, TestData.rideByUid('ride-002-full'), duplicate];

      final unique = RideFilterHelper.deduplicateById(rides);
      expect(unique, hasLength(2));

      final deduped = unique.firstWhere((r) => r.uid == original.uid);
      expect(deduped.price, equals(999)); // last occurrence wins
    });
  });
}
