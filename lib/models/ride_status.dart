/// Mirrors the subset of `RideStatus` from the private app that the
/// public helpers need to reason about.
enum RideStatus { pending, collecting, inRoute, completed, cancelled, closed }

/// Statuses under which a ride is still open for booking activity.
const List<RideStatus> openedRideStatuses = [
  RideStatus.pending,
  RideStatus.inRoute,
  RideStatus.collecting,
];
