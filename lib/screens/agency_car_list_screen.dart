import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'add_edit_car_screen.dart';

class AgencyCarListScreen extends StatefulWidget {
  const AgencyCarListScreen({super.key});

  @override
  State<AgencyCarListScreen> createState() => _AgencyCarListScreenState();
}

class _AgencyCarListScreenState extends State<AgencyCarListScreen> {
  List<dynamic> _cars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAgencyCars();
  }

  Future<void> _loadAgencyCars() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final apiService = authService.getApiService();

    try {
      final currentUser = authService.currentUser;

      if (currentUser == null || currentUser['id'] == null) {
        throw Exception('Utilisateur non connecté ou ID manquant. Veuillez vous reconnecter.');
      }

      final int userId = currentUser['id'] as int;
      final cars = await apiService.getCar(userId); // Or use a specific agency endpoint
      setState(() {
        _cars = cars;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cars: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteCar(int carId) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final apiService = authService.getApiService();
      await apiService.deleteCar(carId);
      _loadAgencyCars(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete car: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cars'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddEditCarScreen(),
              ),
            ).then((_) => _loadAgencyCars()),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadAgencyCars,
        child: ListView.builder(
          itemCount: _cars.length,
          itemBuilder: (context, index) {
            final car = _cars[index];
            return Dismissible(
              key: Key(car['id'].toString()),
              background: Container(color: Colors.red),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: const Text('Are you sure you want to delete this car?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (direction) => _deleteCar(car['id']),
              child: Card(
                child: ListTile(
                  title: Text('${car['marque']} ${car['modele']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('License: ${car['immatriculation']}'),
                      Text('Price: ${car['prix_par_jour']} TND/day'),
                      Text('Status: ${car['statut']}'),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditCarScreen(car: car),
                    ),
                  ).then((_) => _loadAgencyCars()),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}