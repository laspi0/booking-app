import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:register/config/theme.dart';

class Reservation {
  final DateTime startDate;
  final DateTime endDate;
  final TimeOfDay startTime;
  final TimeOfDay? endTime;
  final String? message;
  final String userId;
  final String listingId;

  Reservation({
    required this.startDate,
    required this.endDate,
    required this.startTime,
    this.endTime,
    this.message,
    required this.userId,
    required this.listingId,
  });

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': endTime != null ? '${endTime!.hour}:${endTime!.minute}' : null,
      'message': message,
      'userId': userId,
      'listingId': listingId,
    };
  }
}

class ReservationController {
  Future<void> createReservation(Reservation reservation) async {
    // Logique de sauvegarde de la réservation
  }
}

class ReservationPage extends StatefulWidget {
  final String? listingId;
  final String? userId;  

  const ReservationPage({
    Key? key,
    this.listingId,
    this.userId,
  }) : super(key: key);

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final ReservationController _controller = ReservationController();
  final TextEditingController _messageController = TextEditingController();
  
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  
  bool isLoading = false;

  Future<void> _selectDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        endTime = picked;
      });
    }
  }

  Future<void> _submitReservation() async {
    if (startDate == null || endDate == null || startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date de début, une date de fin et une heure de début'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validation : date de fin ne peut pas être avant la date de début
    if (endDate!.isBefore(startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date de fin doit être après la date de début'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final reservation = Reservation(
        startDate: startDate!,
        endDate: endDate!,
        startTime: startTime!,
        endTime: endTime,
        message: _messageController.text.trim(),
        userId: 'user_id', // Remplacer par l'ID utilisateur réel
        listingId: 'listing_id', // Remplacer par l'ID de la liste réel
      );

      await _controller.createReservation(reservation);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation confirmée !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedStartDate = startDate != null
        ? DateFormat('dd/MM/yyyy').format(startDate!)
        : 'Date de début';
    
    String formattedEndDate = endDate != null
        ? DateFormat('dd/MM/yyyy').format(endDate!)
        : 'Date de fin';
    
    String formattedStartTime = startTime != null
        ? startTime!.format(context)
        : 'Heure de début';
    
    String formattedEndTime = endTime != null
        ? endTime!.format(context)
        : 'Heure de fin (optionnel)';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réservation'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text('Début : $formattedStartDate'),
                        subtitle: Text('Fin : $formattedEndDate'),
                        onTap: () => _selectDateRange(context),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text('Début : $formattedStartTime'),
                        subtitle: Text('Fin : $formattedEndTime'),
                        onTap: () {
                          _selectStartTime(context);
                          if (startTime != null) {
                            _selectEndTime(context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _messageController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Message (optionnel)',
                      border: InputBorder.none,
                      hintText: 'Écrivez un message au vendeur...',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: isLoading ? null : _submitReservation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Confirmer la réservation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}