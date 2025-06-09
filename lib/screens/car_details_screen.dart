// lib/screens/car_details_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class CarDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> car;

  const CarDetailsScreen({super.key, required this.car});

  @override
  _CarDetailsScreenState createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.red,
              onPrimary: Colors.white,
              surface: Colors.grey[800]!, // Rend le fond du calendrier plus foncé
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[900], // Fond du dialogue du DatePicker
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _makeReservation() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner les dates de début et de fin.')),
      );
      return;
    }

    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La date de début doit être antérieure à la date de fin.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final apiService = authService.getApiService();

    try {
      final currentUser = authService.currentUser;

      if (currentUser == null || currentUser['id'] == null) {
        throw Exception('Utilisateur non connecté ou ID manquant. Veuillez vous reconnecter.');
      }
      
      final int userId = currentUser['id'] as int;
      final int carId = widget.car['id'] as int;

      final String formattedStartDate = DateFormat('yyyy-MM-dd').format(_startDate!);
      final String formattedEndDate = DateFormat('yyyy-MM-dd').format(_endDate!);

      final Map<String, dynamic> reservationData = {
        'utilisateur_id': userId,
        'voiture_id': carId,
        'date_debut': formattedStartDate,
        'date_fin': formattedEndDate,
      };

      await apiService.createReservation(reservationData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réservation créée avec succès ! La confirmation est en attente.')),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Erreur lors de la création de la réservation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Échec de la réservation: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fond noir pour tout l'écran
      appBar: AppBar(
        backgroundColor: Colors.black, // AppBar noire
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Flèche retour blanche
        title: const Text(
          'Détails de la Voiture',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView( // Permet le défilement vertical si le contenu dépasse
        padding: const EdgeInsets.all(16.0),
        child: Center( // Centre le contenu principal sur les grands écrans
          child: ConstrainedBox( // Limite la largeur du contenu principal
            // Removed maxWidth constraint to allow it to be as big as possible
            // constraints: const BoxConstraints(maxWidth: 1000), 
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.95), // Still a little margin
            child: Row( // <-- Utilise une Row pour mettre l'image et les détails côte à côte
              crossAxisAlignment: CrossAxisAlignment.start, // Aligne les enfants en haut
              children: [
                // Section de l'image (à gauche)
                Expanded(
                  flex: 3, // <--- AUGMENTÉ : L'image prend 3 parts (était 2)
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: (widget.car['photo'] != null && widget.car['photo'].isNotEmpty)
                        ? Image.network(
                            widget.car['photo'],
                            height: 450, // <--- AUGMENTÉ : Hauteur de l'image encore plus grande (était 350)
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 450, // <--- AUGMENTÉ
                                color: Colors.grey[700],
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(
                                  color: Colors.red,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 450, // <--- AUGMENTÉ
                                color: Colors.grey[700],
                                alignment: Alignment.center,
                                child: const Icon(Icons.broken_image, size: 100, color: Colors.grey), // Icône plus grande
                              );
                            },
                          )
                        : Container(
                            height: 450, // <--- AUGMENTÉ
                            color: Colors.grey[700],
                            alignment: Alignment.center,
                            child: const Text('No Image Available', style: TextStyle(color: Colors.grey)),
                          ),
                  ),
                ),
                const SizedBox(width: 32), // Espace entre l'image et la colonne de détails

                // Section des détails et boutons (à droite)
                Expanded(
                  flex: 2, // <--- RÉDUIT : Les détails et boutons prennent 2 parts (était 3)
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.car['marque']} ${widget.car['modele']}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Plaque d\'immatriculation: ${widget.car['immatriculation']}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Statut: ${widget.car['statut']}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Prix par jour: ${widget.car['prix_par_jour']} TND',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Sélectionnez les dates de réservation :',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _selectDate(context, true),
                              icon: const Icon(Icons.calendar_today, size: 20, color: Colors.white),
                              label: Text(
                                _startDate == null
                                    ? 'Date de début'
                                    : DateFormat('yyyy-MM-dd').format(_startDate!),
                                style: const TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _selectDate(context, false),
                              icon: const Icon(Icons.calendar_today, size: 20, color: Colors.white),
                              label: Text(
                                _endDate == null
                                    ? 'Date de fin'
                                    : DateFormat('yyyy-MM-dd').format(_endDate!),
                                style: const TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.red))
                          : Center(
                              child: SizedBox(
                                width: 250,
                                child: ElevatedButton(
                                  onPressed: _makeReservation,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Réserver cette voiture',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
