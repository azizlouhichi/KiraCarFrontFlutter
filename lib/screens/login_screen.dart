// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.login(
      _usernameController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      // Navigue vers l'écran d'accueil en remplaçant l'écran actuel
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(), // Assurez-vous que HomeScreen est const
        ),
      );
    } else {
      // Affiche un message d'erreur si la connexion échoue
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Échec de la connexion. Veuillez réessayer.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating, // La SnackBar flotte au-dessus du contenu
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Bords arrondis pour la SnackBar
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fond noir pour correspondre au design
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Les enfants s'étirent horizontalement
            children: [
              const SizedBox(height: 40), // Espacement en haut
              Center(
                // Remplacement du logo Image.asset par du texte stylisé
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Centre les mots dans la ligne
                  children: const [
                    Text(
                      'Kira',
                      style: TextStyle(
                        color: Colors.red, // Couleur rouge pour "Kira"
                        fontSize: 50, // Grande taille de police
                        fontWeight: FontWeight.bold, // Texte en gras
                        fontFamily: 'Poppins', // Utilise la police Poppins pour le titre
                      ),
                    ),
                    Text(
                      'Car',
                      style: TextStyle(
                        color: Colors.white, // Couleur blanche pour "Car"
                        fontSize: 50, // Même grande taille de police
                        fontWeight: FontWeight.bold, // Texte en gras
                        fontFamily: 'Poppins', // Utilise la police Poppins
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80), // Espacement après le logo textuel

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Champ Email
                    TextFormField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.white), // Texte entré en blanc
                      decoration: InputDecoration(
                        labelText: 'Email', // Libellé
                        labelStyle: const TextStyle(color: Colors.grey), // Couleur du libellé
                        filled: true,
                        fillColor: Colors.grey[800], // Couleur de fond du champ
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none, // Pas de bordure par défaut
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red, width: 2), // Bordure rouge au focus
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Veuillez entrer votre email.' : null,
                    ),
                    const SizedBox(height: 20),
                    // Champ Mot de passe
                    TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(color: Colors.white), // Texte entré en blanc
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        labelStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.red, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey, // Icône visible/invisible
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword, // Masque le texte du mot de passe
                      validator: (value) =>
                          value!.isEmpty ? 'Veuillez entrer votre mot de passe.' : null,
                    ),
                    const SizedBox(height: 24),
                    // Bouton Login
                    _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.red)) // Indicateur de chargement
                        : Center( // Centre le bouton et contrôle sa taille
                            child: SizedBox( // Utilise SizedBox pour la taille fixe
                              width: 250, // Largeur fixe pour le bouton (ajustez si nécessaire)
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red, // Fond rouge
                                  foregroundColor: Colors.white, // Texte blanc
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0, // Pas d'ombre
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 24),
                    // Texte et bouton Sign Up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Vous n\'avez pas de compte ?',
                          style: TextStyle(color: Colors.white70), // Texte gris clair
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(), // Assurez-vous que SignupScreen est const
                              ),
                            );
                          },
                          child: const Text(
                            'S\'inscrire',
                            style: TextStyle(
                              color: Colors.white, // Texte blanc pour le bouton S'inscrire
                              fontWeight: FontWeight.bold,
                            ),
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
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
