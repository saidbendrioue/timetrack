import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timetrack/exceptions/business.exception.dart';
import 'package:timetrack/exceptions/not_found.exception.dart';
import 'package:timetrack/models/employe.model.dart';
import 'package:timetrack/models/pointage.model.dart';
import 'package:timetrack/services/pointage.api.dart';
import 'dart:convert';
import '../providers/auth_provider.dart';
import 'package:one_clock/one_clock.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Employe? _employe;
  Pointage? _pointage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmploye();
  }

  Future<void> _loadEmploye() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeString = prefs.getString('employe');
      if (employeString != null) {
        setState(() {
          _employe = Employe.fromJson(jsonDecode(employeString));
        });

        if (_employe != null) {
          final pointageService = PointageService();
          _pointage = await pointageService.getTodayPointage(_employe!.id);
          print(_pointage);
        }

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading employe: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _employe != null ? "Bonjour, ${_employe!.prenom}!" : "Bonjour!",
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Carte pour le statut de pointage
                    Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child:
                            _pointage != null
                                ? RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: "Pointage d'arrivée enregistré\n",
                                      ),
                                      TextSpan(
                                        text:
                                            "${DateFormat('dd/MM/yyyy').format(_pointage!.date)} ${_pointage!.heureArriveeFormatted}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : const Text(
                                  "Vous n'avez pas encore pointé votre arrivée",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),

                    // Affichage de l'heure et date actuelle
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 30),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          DigitalClock(
                            showSeconds: true,
                            isLive: true,
                            digitalClockColor: Colors.blue[900]!,
                            datetime: DateTime.now(),
                            textScaleFactor: 1.5,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            DateFormat('dd/MM/yyyy').format(DateTime.now()),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue[800],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Boutons d'action
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 250,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => _pointer(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _pointage == null
                                      ? Colors.green
                                      : Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              _pointage == null
                                  ? "Pointer l'arrivée".toUpperCase()
                                  : "Pointer le départ".toUpperCase(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: 250,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                () =>
                                    Navigator.pushNamed(context, '/historique'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.grey[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.grey[300]!),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Historique de présence",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }

  void _pointer(BuildContext context) async {
    final pointageService = PointageService();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final employeConnecte = authProvider.employe;

    if (employeConnecte == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Aucun employé connecté",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final nouveauPointage = Pointage.now(
      employeId: employeConnecte.id,
      type: _pointage == null ? 'PRESENT' : 'ABSENT',
    );

    try {
      final createdPointage = await pointageService.createPointage(
        nouveauPointage,
      );

      setState(() {
        _pointage = createdPointage;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Pointage enregistré à ${DateFormat('HH:mm').format(DateTime.now())}",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      print('Pointage créé avec ID: ${createdPointage.id}');
    } on BusinessException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? "Erreur lors de l'enregistrement",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    } on NotFoundException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Employé non trouvé",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Une erreur technique est survenue",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );

      print('Erreur technique: $e');
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
}
