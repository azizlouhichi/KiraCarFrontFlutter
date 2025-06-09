import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ReservationHistoryScreen extends StatefulWidget {
  const ReservationHistoryScreen({super.key});

  @override
  State<ReservationHistoryScreen> createState() => _ReservationHistoryScreenState();
}

class _ReservationHistoryScreenState extends State<ReservationHistoryScreen> {
  List<dynamic> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservationHistory();
  }

  Future<void> _loadReservationHistory() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final apiService = authService.getApiService();

    try {
      final currentUser = authService.currentUser;

      if (currentUser == null || currentUser['id'] == null) {
        throw Exception('Utilisateur non connecté ou ID manquant. Veuillez vous reconnecter.');
      }

      final int userId = currentUser['id'] as int;
      final reservations = await apiService.getReservation(userId); // Or use specific history endpoint
      setState(() {
        _reservations = reservations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load history: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reservation History')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadReservationHistory,
        child: _reservations.isEmpty
            ? const Center(child: Text('No reservation history'))
            : ListView.builder(
          itemCount: _reservations.length,
          itemBuilder: (context, index) {
            final reservation = _reservations[index];
            return Card(
              child: ListTile(
                title: Text('${reservation['voiture']['marque']} ${reservation['voiture']['modele']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Client: ${reservation['utilisateur']['username']}'),
                    Text('Dates: ${reservation['date_debut']} to ${reservation['date_fin']}'),
                    Text('Status: ${reservation['etat']}'),
                    Text('Price: ${reservation['voiture']['prix_par_jour']} TND/day'),
                  ],
                ),
                trailing: Chip(
                  label: Text(
                    reservation['etat'],
                    style: TextStyle(
                      color: _getStatusColor(reservation['etat']),
                    ),
                  ),
                  backgroundColor: _getStatusColor(reservation['etat']).withOpacity(0.1),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}