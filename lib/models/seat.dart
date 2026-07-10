import 'seat_status.dart';

class Seat {
  final int id;
  final String reservedBy;
  final SeatStatus status;

  const Seat({
    required this.id,
    required this.reservedBy,
    required this.status,
  });

  factory Seat.empty() =>
      const Seat(id: 0, reservedBy: '', status: SeatStatus.available);

  factory Seat.fromJson(Map<String, dynamic> json) => Seat(
        id: json['id'] as int,
        reservedBy: json['reservedBy'] as String? ?? '',
        status: SeatStatus.values.byName(json['status'] as String),
      );

  Seat copyWith({int? id, String? reservedBy, SeatStatus? status}) => Seat(
        id: id ?? this.id,
        reservedBy: reservedBy ?? this.reservedBy,
        status: status ?? this.status,
      );
}
