import 'package:flutter_test/flutter_test.dart';
import 'package:droovo_mobile_public/helpers/distance_helper.dart';
import 'package:droovo_mobile_public/models/lat_lng.dart';

void main() {
  group('DistanceHelper', () {
    test('distance between identical points is zero', () {
      const point = LatLng(36.8065, 10.1815);
      expect(
        DistanceHelper.calculateDistanceKm(point, point),
        closeTo(0, 0.0001),
      );
    });

    test('Tunis to Sfax is roughly 235km', () {
      const tunis = LatLng(36.8065, 10.1815);
      const sfax = LatLng(34.7406, 10.7603);

      final distance = DistanceHelper.calculateDistanceKm(tunis, sfax);
      expect(distance, greaterThan(225));
      expect(distance, lessThan(245));
    });

    test('distance is symmetric regardless of direction', () {
      const a = LatLng(36.8065, 10.1815);
      const b = LatLng(34.7406, 10.7603);

      final ab = DistanceHelper.calculateDistanceKm(a, b);
      final ba = DistanceHelper.calculateDistanceKm(b, a);
      expect(ab, closeTo(ba, 0.0001));
    });

    test('isWithinDistance respects the given radius', () {
      const a = LatLng(36.8065, 10.1815);
      const nearby = LatLng(36.81, 10.19); // a few hundred meters away
      const farAway = LatLng(34.7406, 10.7603); // Sfax

      expect(DistanceHelper.isWithinDistance(a, nearby, 5), isTrue);
      expect(DistanceHelper.isWithinDistance(a, farAway, 5), isFalse);
    });

    test('calculateDistanceText formats with 2 decimals and km suffix', () {
      const a = LatLng(36.8065, 10.1815);
      const b = LatLng(36.8065, 10.1815);
      expect(DistanceHelper.calculateDistanceText(a, b), equals('0.00 km'));
    });

    test('getTruncatedStates truncates both fields to the limit', () {
      final result = DistanceHelper.getTruncatedStates(
        'Ben Arous',
        'Manouba',
        5,
      );
      expect(result['pickup'], equals('Ben A'));
      expect(result['destination'], equals('Manou'));
    });

    test('getTruncatedStates leaves short strings untouched', () {
      final result = DistanceHelper.getTruncatedStates('Tunis', 'Sfax', 10);
      expect(result['pickup'], equals('Tunis'));
      expect(result['destination'], equals('Sfax'));
    });

    test('buildGroupName joins the first word of each state', () {
      expect(
        DistanceHelper.buildGroupName('Tunis Centre', 'Sfax Sud'),
        equals('Tunis-Sfax'),
      );
    });
  });
}
