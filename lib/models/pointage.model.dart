// pointage.model.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Pointage {
  final int? id;
  final DateTime date;
  final TimeOfDay heureArrivee;
  TimeOfDay? heureDepart;
  final String type;
  final int employeId;

  Pointage({
    this.id,
    required this.date,
    required this.heureArrivee,
    this.heureDepart,
    required this.type,
    required this.employeId,
  });

  // Format constant pour les heures
  static const timeFormat = 'HH:mm:ss';

  factory Pointage.fromJson(Map<String, dynamic> json) {
    try {
      return Pointage(
        id: json['id'],
        date: DateTime.parse(json['date']),
        heureArrivee: _parseTime(json['heureArrivee']),
        heureDepart:
            json['heureDepart'] != null
                ? _parseTime(json['heureDepart'])
                : null,
        type: json['type'],
        employeId: json['employeId'],
      );
    } catch (e) {
      throw FormatException('Erreur de parsing Pointage: $e');
    }
  }

  static TimeOfDay _parseTime(String timeString) {
    try {
      final format = DateFormat(timeFormat);
      final date = format.parse(timeString);
      return TimeOfDay.fromDateTime(date);
    } catch (e) {
      // Fallback pour l'ancien format "HH:mm"
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
      throw FormatException('Format de temps invalide: $timeString');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'heureArrivee': _formatTime(heureArrivee),
      'heureDepart': heureDepart != null ? _formatTime(heureDepart!) : null,
      'type': type,
      'employeId': employeId,
    };
  }

  static String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:00';
  }

  // Méthode utilitaire pour créer un Pointage à partir de l'heure actuelle
  factory Pointage.now({
    int? id,
    required int employeId,
    String type = 'PRESENT',
  }) {
    final now = DateTime.now();
    return Pointage(
      id: id,
      date: now,
      heureArrivee: TimeOfDay.fromDateTime(now),
      type: type,
      employeId: employeId,
    );
  }

  // Convertit en String pour l'affichage
  String get heureArriveeFormatted => _formatTime(heureArrivee);
  String? get heureDepartFormatted =>
      heureDepart != null ? _formatTime(heureDepart!) : null;
}
