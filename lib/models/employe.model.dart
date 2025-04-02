import 'package:timetrack/enums/statut.enum.dart';
import 'package:timetrack/enums/type_contrat.enum.dart';
import 'package:timetrack/models/pointage.model.dart';

class Employe {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String poste;
  final String password;
  final int? manager;
  final DateTime dateEmbauche;
  final TypeContrat typeContrat;
  final Statut statut;
  final DateTime? dateFinContrat;
  final List<Pointage> pointages;

  Employe({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.poste,
    required this.password,
    this.manager,
    required this.dateEmbauche,
    required this.typeContrat,
    required this.statut,
    this.dateFinContrat,
    this.pointages = const [],
  });

  factory Employe.fromJson(Map<String, dynamic> json) {
    final pointagesJson = json['pointages'] as List<dynamic>? ?? [];

    return Employe(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      poste: json['poste'],
      password: json['password'],
      manager: json['manager'],
      dateEmbauche: DateTime.parse(json['dateEmbauche']),
      typeContrat: TypeContrat.values.firstWhere(
        (e) => e.toString().split('.').last == json['typeContrat'],
      ),
      statut: Statut.values.firstWhere(
        (e) => e.toString().split('.').last == json['statut'],
      ),
      dateFinContrat:
          json['dateFinContrat'] != null
              ? DateTime.parse(json['dateFinContrat'])
              : null,
      pointages: pointagesJson.map((p) => Pointage.fromJson(p)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'poste': poste,
      'password': password,
      'manager': manager,
      'dateEmbauche': dateEmbauche.toIso8601String(),
      'typeContrat': typeContrat.toString().split('.').last,
      'statut': statut.toString().split('.').last,
      'dateFinContrat': dateFinContrat?.toIso8601String(),
      'pointages': pointages.map((p) => p.toJson()).toList(),
    };
  }

  Employe copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? email,
    String? poste,
    String? password,
    int? manager,
    DateTime? dateEmbauche,
    TypeContrat? typeContrat,
    Statut? statut,
    DateTime? dateFinContrat,
    List<Pointage>? pointages,
  }) {
    return Employe(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      poste: poste ?? this.poste,
      password: password ?? this.password,
      manager: manager ?? this.manager,
      dateEmbauche: dateEmbauche ?? this.dateEmbauche,
      typeContrat: typeContrat ?? this.typeContrat,
      statut: statut ?? this.statut,
      dateFinContrat: dateFinContrat ?? this.dateFinContrat,
      pointages: pointages ?? this.pointages,
    );
  }

  // Méthodes utilitaires pour les pointages
  Employe addPointage(Pointage pointage) {
    return copyWith(pointages: [...pointages, pointage]);
  }

  Employe removePointage(int pointageId) {
    return copyWith(
      pointages: pointages.where((p) => p.id != pointageId).toList(),
    );
  }

  // Calcul du total des heures travaillées
  Duration get totalHeuresTravaillees {
    return pointages.fold(Duration.zero, (total, p) {
      final arrivee = DateTime(
        0,
        0,
        0,
        p.heureArrivee.hour,
        p.heureArrivee.minute,
      );
      final depart = DateTime(
        0,
        0,
        0,
        p.heureDepart.hour,
        p.heureDepart.minute,
      );
      return total + depart.difference(arrivee);
    });
  }

  // Filtrage des pointages par mois
  List<Pointage> getPointagesByMonth(int year, int month) {
    return pointages
        .where((p) => p.date.year == year && p.date.month == month)
        .toList();
  }
}
