import 'package:flutter_test/flutter_test.dart';
import 'package:droovo_mobile_public/helpers/pricing_calculator.dart';

void main() {
  group('PricingCalculator', () {
    test('calculates price breakdown for a diesel car with AC', () {
      final result = PricingCalculator.calculatePrice(
        distanceKm: 100,
        passengerCount: 3,
        fuelType: 'diesel',
        hasAC: true,
      );

      expect(result['baseCost'], closeTo(34.9, 0.001));
      expect(result['perPersonCost'], closeTo(8.7, 0.001));
      expect(result['price'], closeTo(8.7, 0.001));
      expect(result['minPrice'], closeTo(7.8, 0.001));
      expect(result['maxPrice'], closeTo(9.6, 0.001));
      expect(result['driverContribution'], closeTo(8.7, 0.001));
    });

    test('essence rate is higher than diesel for the same trip', () {
      final diesel = PricingCalculator.calculatePrice(
        distanceKm: 50,
        passengerCount: 2,
        fuelType: 'diesel',
        hasAC: false,
      );
      final essence = PricingCalculator.calculatePrice(
        distanceKm: 50,
        passengerCount: 2,
        fuelType: 'essence',
        hasAC: false,
      );

      expect(essence['baseCost'], greaterThan(diesel['baseCost'] as double));
    });

    test('AC surcharge applies an exact 12.5% multiplier before rounding', () {
      final withoutAC = PricingCalculator.calculatePrice(
        distanceKm: 40,
        passengerCount: 2,
        fuelType: 'diesel',
        hasAC: false,
      );
      final withAC = PricingCalculator.calculatePrice(
        distanceKm: 40,
        passengerCount: 2,
        fuelType: 'diesel',
        hasAC: true,
      );

      // Compare the exact (pre-rounding) multiplier exposed in the
      // breakdown, since 'baseCost' itself is rounded to 1 decimal and a
      // ratio of two rounded values would not land exactly on 1.125.
      final withoutBreakdown = withoutAC['breakdown'] as Map<String, dynamic>;
      final withBreakdown = withAC['breakdown'] as Map<String, dynamic>;
      expect(withoutBreakdown['acMultiplier'], equals(1.0));
      expect(withBreakdown['acMultiplier'], equals(1.125));
    });

    test(
      'non-positive distance falls back to 1 km instead of dividing by zero',
      () {
        final zero = PricingCalculator.calculatePrice(
          distanceKm: 0,
          passengerCount: 1,
          fuelType: 'diesel',
          hasAC: false,
        );
        final negative = PricingCalculator.calculatePrice(
          distanceKm: -5,
          passengerCount: 1,
          fuelType: 'diesel',
          hasAC: false,
        );

        expect(zero['baseCost'], equals(negative['baseCost']));
        expect(zero['baseCost'], greaterThan(0));
      },
    );

    test('passenger count is clamped between 1 and 7', () {
      final tooFew = PricingCalculator.calculatePrice(
        distanceKm: 30,
        passengerCount: 0,
        fuelType: 'diesel',
        hasAC: false,
      );
      final tooMany = PricingCalculator.calculatePrice(
        distanceKm: 30,
        passengerCount: 20,
        fuelType: 'diesel',
        hasAC: false,
      );

      final breakdownFew = tooFew['breakdown'] as Map<String, dynamic>;
      final breakdownMany = tooMany['breakdown'] as Map<String, dynamic>;
      expect(breakdownFew['passengers'], equals(1));
      expect(breakdownMany['passengers'], equals(7));
    });

    test('getFuelTypeLabel maps known and unknown fuel types', () {
      expect(PricingCalculator.getFuelTypeLabel('diesel'), equals('Diesel'));
      expect(PricingCalculator.getFuelTypeLabel('ESSENCE'), equals('Essence'));
      expect(
        PricingCalculator.getFuelTypeLabel('electric'),
        equals('electric'),
      );
    });

    test('getBreakdownText renders a human readable summary', () {
      final result = PricingCalculator.calculatePrice(
        distanceKm: 10,
        passengerCount: 1,
        fuelType: 'diesel',
        hasAC: false,
      );

      final text = PricingCalculator.getBreakdownText(result);
      expect(text, contains('km'));
      expect(text, contains('DT/km'));
      expect(text, contains('occupants'));
    });
  });
}
