import 'package:flutter_test/flutter_test.dart';
import 'package:droovo_mobile_public/helpers/ride_form_validation_helper.dart';

void main() {
  group('RideFormValidationHelper.validatePrice', () {
    test('accepts a price within the 0-25 range', () {
      expect(RideFormValidationHelper.validatePrice('12.5'), isTrue);
      expect(RideFormValidationHelper.validatePrice('0'), isTrue);
      expect(RideFormValidationHelper.validatePrice('25'), isTrue);
    });

    test('rejects an empty value', () {
      expect(RideFormValidationHelper.validatePrice(''), isFalse);
      expect(RideFormValidationHelper.validatePrice('   '), isFalse);
    });

    test('rejects a non-numeric value', () {
      expect(RideFormValidationHelper.validatePrice('abc'), isFalse);
    });

    test('rejects a negative price', () {
      expect(RideFormValidationHelper.validatePrice('-5'), isFalse);
    });

    test('rejects a price above the configured maximum', () {
      expect(RideFormValidationHelper.validatePrice('26'), isFalse);
      expect(
        RideFormValidationHelper.validatePrice('40', maxPrice: 50),
        isTrue,
      );
      expect(
        RideFormValidationHelper.validatePrice('60', maxPrice: 50),
        isFalse,
      );
    });
  });

  group('RideFormValidationHelper.validateSeats', () {
    test('accepts a seat count within [minSeats, carPossibleSeats]', () {
      expect(
        RideFormValidationHelper.validateSeats(
          '2',
          carPossibleSeats: 4,
          minSeats: 1,
        ),
        isTrue,
      );
    });

    test('rejects a seat count above the car capacity', () {
      expect(
        RideFormValidationHelper.validateSeats(
          '5',
          carPossibleSeats: 4,
          minSeats: 1,
        ),
        isFalse,
      );
    });

    test('rejects a seat count below the minimum', () {
      expect(
        RideFormValidationHelper.validateSeats(
          '1',
          carPossibleSeats: 4,
          minSeats: 2,
        ),
        isFalse,
      );
    });

    test('rejects when there is no car selected', () {
      expect(
        RideFormValidationHelper.validateSeats(
          '2',
          carPossibleSeats: null,
          minSeats: 1,
        ),
        isFalse,
      );
    });

    test('rejects non-numeric or empty input', () {
      expect(
        RideFormValidationHelper.validateSeats(
          '',
          carPossibleSeats: 4,
          minSeats: 1,
        ),
        isFalse,
      );
      expect(
        RideFormValidationHelper.validateSeats(
          'two',
          carPossibleSeats: 4,
          minSeats: 1,
        ),
        isFalse,
      );
    });
  });

  group('RideFormValidationHelper.getMinimumSeats', () {
    test('is the gap between requested and remaining passengers', () {
      expect(
        RideFormValidationHelper.getMinimumSeats(
          requestedPassengers: 3,
          remainingPassengers: 1,
        ),
        equals(2),
      );
    });

    test('never goes below zero', () {
      expect(
        RideFormValidationHelper.getMinimumSeats(
          requestedPassengers: 1,
          remainingPassengers: 3,
        ),
        equals(0),
      );
    });
  });
}
