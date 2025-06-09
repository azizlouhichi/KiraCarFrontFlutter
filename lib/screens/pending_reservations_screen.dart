import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class PendingReservationsScreen extends StatefulWidget {
  const PendingReservationsScreen({super.key});

  @override
  State<PendingReservationsScreen> createState() => _PendingReservationsScreenState();
}

class _PendingReservationsScreenState extends State<PendingReservationsScreen> {
  List<dynamic> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingReservations();
  }

  Future<void> _loadPendingReservations() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final apiService = authService.getApiService();

    try {
      final currentUser = authService.currentUser;

      if (currentUser == null || currentUser['id'] == null) {
        throw Exception('Utilisateur non connecté ou ID manquant. Veuillez vous reconnecter.');
      }

      final int userId = currentUser['id'] as int;
      final reservations = await apiService.getReservation(userId);
      setState(() {
        _reservations = reservations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load reservations: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateReservationStatus(int id, String action) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final apiService = authService.getApiService();

      if (action == 'confirm') {
        await apiService.confirmReservation(id);
      } else {
        await apiService.cancelReservationByAgencyOrAdmin(id);
      }

      _loadPendingReservations(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reservation ${action}ed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update reservation: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Reservations')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadPendingReservations,
        child: _reservations.isEmpty
            ? const Center(child: Text('No pending reservations'))
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
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => _updateReservationStatus(reservation['id'], 'confirm'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _updateReservationStatus(reservation['id'], 'cancel'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}