import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timetrack/models/employe.model.dart';
import 'package:timetrack/models/pointage.model.dart';
import 'package:timetrack/services/pointage.api.dart';
import 'dart:convert';
import '../providers/auth_provider.dart';
import 'package:one_clock/one_clock.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<Employe?> _loadEmploye() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeString = prefs.getString('employe');
      return employeString != null
          ? Employe.fromJson(jsonDecode(employeString))
          : null;
    } catch (e) {
      print('Error loading employe: $e');
      return null;
    }
  }

  Future<void> handleLogout(BuildContext context) async {
    final confirmLogout = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirmation'),
            content: const Text('Voulez-vous vraiment vous déconnecter?'),
            actions: [
              TextButton(
                child: const Text('Annuler'),
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
              TextButton(
                child: const Text('Déconnecter'),
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
            ],
          ),
    );

    if (confirmLogout == true && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('employe');
        await prefs.setBool('isLoggedIn', false);
        await Provider.of<AuthProvider>(context, listen: false).logout();
      } finally {
        if (context.mounted) {
          Navigator.of(context).pop();
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Employe?>(
      future: _loadEmploye(),
      builder: (context, snapshot) {
        final employeName = snapshot.hasData ? snapshot.data?.prenom : null;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              employeName != null ? "Bonjour, $employeName!" : "Bonjour!",
            ),
            automaticallyImplyLeading: false,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'logout') {
                    handleLogout(context);
                  }
                },
                itemBuilder:
                    (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: ListTile(title: Text('Se déconnecter')),
                      ),
                    ],
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DigitalClock(
                        showSeconds: true,
                        isLive: true,
                        digitalClockColor: Colors.black,
                        datetime: DateTime.now(),
                        // textScaleFactor: 2.5,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        DateFormat('dd/MM/yyyy').format(DateTime.now()),
                        style: TextStyle(fontSize: 17),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 150),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      _pointer(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen,
                    ),
                    child: const Text(
                      "Pointer",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/historique');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                    ),
                    child: const Text(
                      "Historique de présence",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _pointer(BuildContext context) async {
    final pointageService = PointageService();
    // Exemple: Créer un nouveau pointage
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final employeConnecte = authProvider.employe;

    final nouveauPointage = Pointage(
      date: DateTime.now(),
      heureArrivee: TimeOfDay(
        hour: DateTime.now().hour,
        minute: DateTime.now().minute,
      ),
      heureDepart: TimeOfDay(hour: 18, minute: 59),
      type: 'PRESENT',
      employeId: employeConnecte!.id,
    );

    try {
      final createdPointage = await pointageService.createPointage(
        nouveauPointage,
      );
      print('Pointage créé avec ID: ${createdPointage.id}');
    } catch (e) {
      print('Erreur lors de la création: $e');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Pointage saisi à ${DateFormat('HH:mm:ss dd/MM/yyyy').format(DateTime.now())}",
        ),
      ),
    );
  }
}
