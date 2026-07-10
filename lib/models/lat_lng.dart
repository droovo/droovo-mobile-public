/// A plain latitude/longitude pair, decoupled from any maps SDK so that
/// helpers depending on coordinates can be tested without platform plugins.
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  factory LatLng.fromJson(Map<String, dynamic> json) => LatLng(
    (json['latitude'] as num).toDouble(),
    (json['longitude'] as num).toDouble(),
  );

  @override
  bool operator ==(Object other) =>
      other is LatLng &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'LatLng($latitude, $longitude)';
}
