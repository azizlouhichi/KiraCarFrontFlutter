// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart'; // Pour obtenir les infos utilisateur pour le Drawer
import 'profile_screen.dart';
import 'reservations_screen.dart'; // Utilisé pour "History" dans le Drawer
import 'car_details_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _cars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final apiService = authService.getApiService();

    setState(() => _isLoading = true);
    try {
      final cars = await apiService.getCars();
      setState(() {
        _cars = cars;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load cars: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Widget pour construire chaque carte de voiture
  Widget _buildCarCard(Map<String, dynamic> car) {
    return Card(
      color: Colors.grey[850], // Couleur de fond de carte foncée
      elevation: 5, // Légère ombre
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CarDetailsScreen(car: car),
            ),
          ).then((_) {
            _loadCars();
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image de la voiture
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: car['photo'] != null && car['photo'].isNotEmpty
                  ? Image.network(
                      car['photo'],
                      height: 160, // Taille de l'image augmentée
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 160, // Taille de l'image augmentée
                          color: Colors.grey[700],
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.red,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 160, // Taille de l'image augmentée
                          color: Colors.grey[700],
                          alignment: Alignment.center,
                          child: const Icon(Icons.car_rental,
                              size: 50, color: Colors.grey),
                        );
                      },
                    )
                  : Container(
                      height: 160, // Taille de l'image augmentée
                      color: Colors.grey[700],
                      child: const Icon(Icons.car_rental,
                          size: 50, color: Colors.grey),
                    ),
            ),
            // Détails de la voiture
            Padding(
              padding: const EdgeInsets.all(8), // Padding général
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${car['marque']} ${car['modele']}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    car['immatriculation'],
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white70, fontSize: 10),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Chip de statut
                      Chip(
                        label: Text(
                          car['statut'],
                          style:
                              const TextStyle(color: Colors.white, fontSize: 9),
                        ),
                        backgroundColor: car['statut'] == 'disponible'
                            ? Colors.green[700]
                            : Colors.orange[700],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 0),
                        labelPadding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      // Prix par jour
                      Text(
                        '${car['prix_par_jour']} TND/jour',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: Colors.white, // Fond blanc
      appBar: AppBar(
        backgroundColor: Colors.black, // AppBar noire
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Kira',
              style: TextStyle(
                color: Colors.red,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              'Car',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: Column(
          children: <Widget>[
            Container(
              height: 180,
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.red,
              ),
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authService.currentUser?['username'] ?? 'Utilisateur',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    authService.currentUser?['role'] ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white70),
              title: const Text('Mon Profil',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.white70),
              title: const Text('Mes Réservations',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReservationsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white70),
              title: const Text('Paramètres',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Fonctionnalité Paramètres à implémenter.')),
                );
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Déconnexion',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () async {
                await authService.logout();
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : Column(
              // <--- ENVELOPPE LE CONTENU DANS UNE COLONNE
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // S'étend sur la largeur
              children: [
                // Espace entre l'AppBar et le message
                const SizedBox(height: 20), // Ajustez cet espacement au besoin

                // Message de bienvenue
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Alignement à gauche
                    children: const [
                      Text(
                        'Bienvenue chez KiraCar !', // Titre principal
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Couleur noire
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(
                          height: 8), // Espace entre le titre et le sous-titre
                      Text(
                        'Prenez le volant. On s’roccupe du reste.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey, // Couleur grise
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                    height: 20), // Espace entre le message et la grille

                // Contenu principal (liste des voitures ou message vide)
                Expanded(
                  // <--- NÉCESSAIRE POUR QUE LE GRIDVIEW PRENNE L'ESPACE RESTANT
                  child: _cars.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.car_repair,
                                  size: 60, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune voiture disponible pour le moment.',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 24),
                              if (authService.currentUser?['role'] == 'admin' ||
                                  authService.currentUser?['role'] == 'agence')
                                ElevatedButton.icon(
                                  onPressed: _loadCars,
                                  icon: const Icon(Icons.refresh,
                                      color: Colors.white),
                                  label: const Text('Rafraîchir les voitures',
                                      style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                ),
                            ],
                          ),
                        )
                      : Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3, // 2 colonnes
                                  crossAxisSpacing: 16, // Espacement horizontal
                                  mainAxisSpacing: 16, // Espacement vertical
                                  childAspectRatio:
                                      1.25, // Ratio pour des cartes plus larges et moins hautes
                                ),
                                itemCount: _cars.length,
                                itemBuilder: (context, index) => _buildCarCard(
                                    _cars[index] as Map<String, dynamic>),
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
