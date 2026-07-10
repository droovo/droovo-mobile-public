/// Form-field validation rules ported from `RideFormHelper` in the
/// private app's ride-creation screen.
class RideFormValidationHelper {
  RideFormValidationHelper._();

  /// Price must parse as a non-negative number, capped at [maxPrice]
  /// dinars per seat.
  static bool validatePrice(String value, {double maxPrice = 25}) {
    if (value.trim().isEmpty) return false;
    final price = double.tryParse(value);
    if (price == null) return false;
    return price >= 0 && price <= maxPrice;
  }

  /// Requested seat count must be between [minSeats] and the car's
  /// [carPossibleSeats].
  static bool validateSeats(
    String value, {
    required int? carPossibleSeats,
    required int minSeats,
  }) {
    if (value.trim().isEmpty) return false;
    final seats = int.tryParse(value);
    if (carPossibleSeats == null || seats == null) return false;
    return seats >= minSeats && seats <= carPossibleSeats;
  }

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
