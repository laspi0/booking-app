// models/reservation.dart
class Reservation {
  final int id;
  final int userId;
  final int listingId;
  final DateTime startDate;
  final DateTime endDate;
  final int durationMonths;
  final double monthlyRate;
  final double totalAmount;
  final String status;
  final String? notes;

  Reservation({
    required this.id,
    required this.userId,
    required this.listingId,
    required this.startDate,
    required this.endDate,
    required this.durationMonths,
    required this.monthlyRate,
    required this.totalAmount,
    required this.status,
    this.notes,
  });

 factory Reservation.fromJson(Map<String, dynamic> json) {
  return Reservation(
    id: json['id'],
    userId: json['user_id'],
    listingId: json['listing_id'],
    startDate: DateTime.parse(json['start_date']),
    endDate: DateTime.parse(json['end_date']),
    durationMonths: json['duration_months'],
    monthlyRate: double.tryParse(json['monthly_rate'].toString()) ?? 0.0,
    totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0.0,
    status: json['status'],
    notes: json['notes'],
  );
}

}
