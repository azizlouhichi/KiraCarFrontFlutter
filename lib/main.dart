// lib/main.dart

import 'package:car_rental/screens/agency_home_screen.dart';
import 'package:car_rental/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // IMPORTANT: Assurez-vous que le package 'provider' est importé
import 'screens/login_screen.dart';
import 'services/auth_service.dart'; // IMPORTANT: Assurez-vous que votre AuthService est importé

void main() {
  // Point d'entrée de l'application.
  // Nous utilisons ChangeNotifierProvider pour rendre AuthService disponible
  // à tous les widgets enfants qui en auront besoin.
  // AuthService DOIT implémenter ou utiliser 'with ChangeNotifier'.
  runApp(
    ChangeNotifierProvider<AuthService>( // Fournit AuthService à toute l'application
      create: (context) => AuthService(), // Crée une instance de AuthService
      child: const MyApp(), // MyApp est l'enfant du Provider
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KIRA CAR',
      theme: ThemeData(
        primaryColor: const Color(0xFF2A3F9D),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2A3F9D),
          secondary: Color(0xFFFF7F50),
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2A3F9D),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 57,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.25,
            fontFamily: 'Poppins',
            color: Color(0xFF333333),
          ),
          displayMedium: TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
            color: Color(0xFF333333),
          ),
          displaySmall: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
            color: Color(0xFF333333),
          ),
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
            color: Color(0xFF333333),
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
            color: Color(0xFF333333),
          ),
          headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
            color: Color(0xFF333333),
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
            color: Color(0xFF333333),
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
            fontFamily: 'Poppins',
            color: Color(0xFF333333),
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            fontFamily: 'Poppins',
            color: Color(0xFF333333),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
            fontFamily: 'OpenSans',
            color: Color(0xFF333333),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
            fontFamily: 'OpenSans',
            color: Color(0xFF333333),
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
            fontFamily: 'OpenSans',
            color: Color(0xFF666666),
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            fontFamily: 'OpenSans',
            color: Color(0xFF333333),
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            fontFamily: 'OpenSans',
            color: Color(0xFF666666),
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            fontFamily: 'OpenSans',
            color: Color(0xFF999999),
          ),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: const Color(0xFFFF7F50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2A3F9D), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthWrapper(), // Le AuthWrapper décide de l'écran initial (Login/Home)
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Dans AuthWrapper, l'accès au AuthService via Provider.of est correct car
    // AuthWrapper est un enfant direct de MyApp, qui est un enfant de ChangeNotifierProvider.
    final authService = Provider.of<AuthService>(context);

    // FutureBuilder est utilisé pour vérifier l'état de connexion de manière asynchrone.
    return FutureBuilder<bool>(
      future: authService.isLoggedIn(),
      builder: (context, snapshot) {
        // Le `context` ici est le BuildContext du builder de FutureBuilder.
        // Tous les widgets retournés ici (HomeScreen ou LoginScreen) sont des enfants de CE contexte.
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == true) {
            final currentUser = authService.currentUser;

            if (currentUser == null || currentUser['id'] == null) {
              throw Exception('Utilisateur non connecté ou ID manquant. Veuillez vous reconnecter.');
            }

            final int role = currentUser['role'] as int;
            if (role == "agency"){
              return const AgencyHomeScreen();
            }
            return const HomeScreen();
          }
          return const LoginScreen();
        }
        // Afficher un indicateur de chargement pendant la vérification de l'état de connexion.
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', height: 120),
                const SizedBox(height: 30),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}