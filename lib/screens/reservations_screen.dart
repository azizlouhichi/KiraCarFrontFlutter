// lib/screens/reservations_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'home_screen.dart'; // Pour naviguer vers l'écran d'accueil

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  List<dynamic> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final apiService = authService.getApiService();

    setState(() => _isLoading = true); // Activer l'indicateur de chargement
    try {
      final response = await apiService.getReservations();
      setState(() {
        _reservations = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Échec du chargement des réservations : $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fond noir pour tout l'écran
      appBar: AppBar(
        backgroundColor: Colors.black, // AppBar noire
        elevation: 0, // Pas d'ombre
        iconTheme:
            const IconThemeData(color: Colors.white), // Flèche retour blanche
        title: const Text(
          'Mes Réservations', // Titre de l'AppBar
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Colors.red)) // Indicateur de chargement rouge
          : _reservations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long,
                          size: 60,
                          color: Colors.grey), // Icône pour absence de résa
                      const SizedBox(height: 16),
                      Text(
                        'Aucune réservation trouvée pour le moment.',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: Colors.white70), // Texte clair
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadReservations, // Bouton pour rafraîchir
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text('Rafraîchir les réservations',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding:
                      const EdgeInsets.all(16.0), // Padding autour de la liste
                  child: ListView.builder(
                    itemCount: _reservations.length,
                    itemBuilder: (context, index) {
                      final reservation = _reservations[index];
                      // S'assurer que 'voiture' n'est pas null avant d'y accéder
                      final car =
                          reservation['voiture'] as Map<String, dynamic>?;

                      return Card(
                        color: Colors.grey[850], // Fond de carte sombre
                        elevation: 5, // Légère ombre
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0), // Marge verticale entre les cartes
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(
                              12.0), // Padding interne de la carte
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Image ou placeholder de la voiture
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: (car?['photo'] != null &&
                                            car!['photo'].isNotEmpty)
                                        ? Image.network(
                                            car['photo'],
                                            height: 80,
                                            width: 120,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                height: 80,
                                                width: 120,
                                                color: Colors.grey[700],
                                                alignment: Alignment.center,
                                                child: const Icon(
                                                    Icons.car_rental,
                                                    size: 40,
                                                    color: Colors.grey),
                                              );
                                            },
                                          )
                                        : Container(
                                            height: 80,
                                            width: 120,
                                            color: Colors.grey[700],
                                            alignment: Alignment.center,
                                            child: const Icon(Icons.car_rental,
                                                size: 40, color: Colors.grey),
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${car?['marque'] ?? 'N/A'} ${car?['modele'] ?? 'N/A'}', // Affichage de la marque et du modèle
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${car?['immatriculation'] ?? 'N/A'}', // Affichage de l'immatriculation
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(color: Colors.white70),
                                        ),
                                        const SizedBox(height: 8),
                                        // Dates de réservation
                                        Text(
                                          'Du: ${reservation['date_debut']} au ${reservation['date_fin']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Statut de la réservation et prix (si applicable)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Chip(
                                    label: Text(
                                      reservation[
                                          'etat'], // Statut de la réservation
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                    backgroundColor: reservation['etat'] ==
                                            'Confirmée'
                                        ? Colors.green[700]
                                        : reservation['etat'] == 'En attente'
                                            ? Colors.orange[700]
                                            : Colors.red[
                                                700], // Ex: pour Annulée ou Rejetée
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    labelPadding: EdgeInsets.zero,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  // Le prix total de la réservation (si disponible dans les données de réservation)
                                  if (reservation['prix_total'] != null)
                                    Text(
                                      'Total: ${reservation['prix_total']} TND',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.redAccent,
                                          ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      // Suppression de la BottomNavigationBar car la navigation se fait via le Drawer
      // bottomNavigationBar: BottomNavigationBar(...),
    );
  }
}
