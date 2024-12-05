// controllers/reservation_controller.dart
import '../services/reservation_service.dart';
import '../models/reservation.dart';

class ReservationController {
  final ReservationService _reservationService = ReservationService();

  Future<List<Reservation>> getReservations() async {
    return await _reservationService.fetchReservations();
  }

  Future<Reservation> getReservation(int id) async {
    return await _reservationService.fetchReservation(id);
  }

  Future<Reservation> addReservation(Map<String, dynamic> reservationData) async {
    return await _reservationService.createReservation(reservationData);
  }

 /*  Future<void> updateReservationStatus(int id, String status) async {
    return await _reservationService.updateReservationStatus(id, status);
  }

  Future<void> cancelReservation(int id) async {
    return await _reservationService.cancelReservation(id);
  } */
}
