import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:register/controllers/reservation_controller.dart';
import 'package:register/models/listing_model.dart';
import 'package:register/models/reservation.dart';
import 'package:register/screens/payment_page.dart';

class ReservationPage extends StatefulWidget {
  final Listing listing; // Passez le listing entier
  final int userId;

  const ReservationPage({
    Key? key,
    required this.listing,
    required this.userId,
  }) : super(key: key);

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  int _selectedMonths = 1;
  Reservation? _pendingReservation;
  bool _isCreatingReservation = false;

  // Create an instance of ReservationController
  final ReservationController _reservationController = ReservationController();

  void _selectDateRange() async {
    final DateTimeRange? result = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              primary: Colors.teal,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() {
        _startDate = result.start;
        _endDate = result.end;
        _selectedMonths = _calculateMonthsDifference(_startDate!, _endDate!);
      });

      // Automatically create a pending reservation
      await _createPendingReservation();
    }
  }

  Future<void> _createPendingReservation() async {
    if (_startDate == null || _endDate == null) return;

    setState(() {
      _isCreatingReservation = true;
    });

    try {
      // Prepare reservation data
      final reservationData = {
        'user_id': widget.userId,
        'listing_id': widget.listing.id,
        'start_date': _startDate!.toIso8601String(),
        'end_date': _endDate!.toIso8601String(),
        'duration_months': _selectedMonths,
        'monthly_rate': widget.listing.price, // Utilisation du tarif dynamique
        'total_amount': _calculateTotalPrice(),
        'status': 'pending',
        'notes': 'Reservation created automatically',
      };

      // Create reservation
      final reservation =
          await _reservationController.addReservation(reservationData);

      setState(() {
        _pendingReservation = reservation;
        _isCreatingReservation = false;
      });

      // Optional: Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Réservation en attente créée'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isCreatingReservation = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de création de réservation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _calculateMonthsDifference(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + end.month - start.month + 1;
  }

  double _calculateTotalPrice() {
    return _selectedMonths * widget.listing.price; // Tarif dynamique
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close Button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              // Title
              const Text(
                'Nouvelle Réservation',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Date Range Selector
              GestureDetector(
                onTap: _selectDateRange,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Période de réservation',
                        style: TextStyle(
                          color: Colors.teal.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _startDate != null
                                ? DateFormat('dd MMM yyyy').format(_startDate!)
                                : 'Date de début',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _endDate != null
                                ? DateFormat('dd MMM yyyy').format(_endDate!)
                                : 'Date de fin',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Pricing Section
              if (_startDate != null && _endDate != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Détails de la réservation',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Durée de réservation',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          Text(
                            '$_selectedMonths mois',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tarif mensuel',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          Text(
                            NumberFormat.currency(locale: 'fr_XAF', symbol: 'FCFA').format(widget.listing.price),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            NumberFormat.currency(
                                    locale: 'fr_XAF', symbol: 'FCFA')
                                .format(_calculateTotalPrice()),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Confirm Button
              if (_startDate != null && _endDate != null && _pendingReservation != null)
                ElevatedButton(
                  onPressed: _isCreatingReservation
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(
                                id: _pendingReservation!.id,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isCreatingReservation
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Confirmer la réservation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
