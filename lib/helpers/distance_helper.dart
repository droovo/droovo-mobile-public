import 'dart:math';

import '../models/lat_lng.dart';

/// Distance & location-text helpers, ported from `RideHelper` in the
/// private app. The original used `Geolocator.distanceBetween`; here the
/// same haversine math is inlined so this helper has zero plugin
/// dependencies and can run in a plain `dart test`.
class DistanceHelper {
  DistanceHelper._();

  static const double earthRadiusKm = 6371;

  /// Great-circle distance between two coordinates, in kilometers.
  static double calculateDistanceKm(LatLng start, LatLng end) {
    final dLat = _toRadians(end.latitude - start.latitude);
    final dLon = _toRadians(end.longitude - start.longitude);

    final lat1 = _toRadians(start.latitude);
    final lat2 = _toRadians(end.latitude);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  static double _toRadians(double degree) => degree * pi / 180;

  /// Whether [a] and [b] are within [maxDistanceKm] of each other.
  static bool isWithinDistance(LatLng a, LatLng b, num maxDistanceKm) {
    return calculateDistanceKm(a, b) <= maxDistanceKm;
  }

  /// Human readable distance, e.g. "12.34 km".
  static String calculateDistanceText(LatLng start, LatLng end) {
    return '${calculateDistanceKm(start, end).toStringAsFixed(2)} km';
  }

  /// Truncates the pickup/destination state names to [limit] characters,
  /// used when building compact group/chat names.
  static Map<String, String> getTruncatedStates(
    String pickupState,
    String destinationState,
    int limit,
  ) {
    String safeTruncate(String input) =>
        input.length <= limit ? input : input.substring(0, limit);

    return {
      'pickup': safeTruncate(pickupState),
      'destination': safeTruncate(destinationState),
    };
  }

  /// Builds a short "Pickup-Destination" label from the first word of each
  /// state name, e.g. "Tunis-Sfax".
  static String buildGroupName(String pickupState, String destinationState) {
    final pickupFirst = pickupState.trim().isEmpty
        ? ''
        : pickupState.trim().split(' ').first;
    final destinationFirst = destinationState.trim().isEmpty
        ? ''
        : destinationState.trim().split(' ').first;
    return '$pickupFirst-$destinationFirst';
  }
}
