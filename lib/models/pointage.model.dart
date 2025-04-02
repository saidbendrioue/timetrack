// pointage.model.dart
import 'package:flutter/material.dart';

class Pointage {
  final int? id;
  final DateTime date;
  final TimeOfDay heureArrivee;
  final TimeOfDay heureDepart;
  final String type;
  final int employeId;

  Pointage({
    this.id,
    required this.date,
    required this.heureArrivee,
    required this.heureDepart,
    required this.type,
    required this.employeId,
  });

  factory Pointage.fromJson(Map<String, dynamic> json) {
    return Pointage(
      id: json['id'],
      date: DateTime.parse(json['date']),
      heureArrivee: _parseTime(json['heureArrivee']),
      heureDepart: _parseTime(json['heureDepart']),
      type: json['type'],
      employeId: json['employeId'],
    );
  }

  static TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'heureArrivee': '${heureArrivee.hour}:${heureArrivee.minute}:00',
      'heureDepart': '${heureDepart.hour}:${heureDepart.minute}:00',
      'type': type,
      'employeId': employeId,
    };
  }
}
