/// Ride Pricing Calculator
/// Uses the same formula as the private app and the web app for consistency.
/// Formula: basePrice = distance × rate_per_km × ac_multiplier
/// Per-person = basePrice ÷ (passengers + 1)
class PricingCalculator {
  // Rate per kilometer (in Dinars)
  static const double dieselRate = 0.310;
  static const double essenceRate = 0.360;

  // AC Multiplier (12.5% increase if AC enabled)
  static const double acMultiplier = 1.125;

  // Price range multipliers (±10%)
  static const double minMultiplier = 0.9;
  static const double maxMultiplier = 1.1;

  /// Calculate price based on distance, passengers, fuel type, and AC.
  /// Returns: {price, minPrice, maxPrice, driverContribution, baseCost,
  /// perPersonCost, breakdown}
  static Map<String, dynamic> calculatePrice({
    required double distanceKm,
    required int passengerCount,
    required String fuelType, // 'diesel' or 'essence'
    required bool hasAC,
  }) {
    final double distance = distanceKm > 0 ? distanceKm : 1.0;
    final int passengers = passengerCount.clamp(1, 7).toInt();

    final rate = fuelType.toLowerCase() == 'diesel' ? dieselRate : essenceRate;
    final acMult = hasAC ? acMultiplier : 1.0;

    final baseCost = distance * rate * acMult;
    final perPersonCost = baseCost / (passengers + 1);
    final driverContribution = baseCost - (perPersonCost * passengers);

    final minPrice = _roundToOneDecimal(perPersonCost * minMultiplier);
    final maxPrice = _roundToOneDecimal(perPersonCost * maxMultiplier);
    final suggestedPrice = _roundToOneDecimal(perPersonCost);

    return {
      'price': suggestedPrice,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'driverContribution': _roundToOneDecimal(driverContribution),
      'baseCost': _roundToOneDecimal(baseCost),
      'perPersonCost': _roundToOneDecimal(perPersonCost),
      'breakdown': {
        'distance': distance,
        'rate': rate,
        'acMultiplier': acMult,
        'passengers': passengers,
        'fuelType': fuelType,
      },
    };
  }

  static double _roundToOneDecimal(double value) => (value * 10).round() / 10;

  /// Get readable label for fuel type.
  static String getFuelTypeLabel(String fuelType) {
    switch (fuelType.toLowerCase()) {
      case 'diesel':
        return 'Diesel';
      case 'essence':
        return 'Essence';
      default:
        return fuelType;
    }
  }

  /// Get readable breakdown text.
  static String getBreakdownText(Map<String, dynamic> calculation) {
    final breakdown = calculation['breakdown'] as Map<String, dynamic>;
    final distance = breakdown['distance'];
    final rate = breakdown['rate'];
    final passengers = breakdown['passengers'] as int;
    final acMult = breakdown['acMultiplier'] as double;
    final baseCost = calculation['baseCost'];

    return 'Distance: ${(distance as num).toStringAsFixed(1)}km × ${rate}DT/km '
        '× ${acMult.toStringAsFixed(3)} = ${baseCost}DT ÷ ${passengers + 1} occupants';
  }
}
