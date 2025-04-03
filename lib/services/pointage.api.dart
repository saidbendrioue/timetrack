// pointage_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:timetrack/exceptions/business.exception.dart';
import 'package:timetrack/exceptions/not_found.exception.dart';
import 'package:timetrack/models/pointage.model.dart';

class PointageService {
  static const String baseUrl = "http://10.0.2.2:8080";

  // 🔹 Récupérer tous les pointages
  Future<List<Pointage>> getAllPointages() async {
    final response = await http.get(Uri.parse('$baseUrl/api/pointages'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Pointage.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load pointages');
    }
  }

  // 🔹 Récupérer un pointage par ID
  Future<Pointage?> getPointageById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/pointages/$id'));

    if (response.statusCode == 200) {
      return Pointage.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load pointage');
    }
  }

  // 🔹 Ajouter un nouveau pointage
  Future<Pointage> createPointage(Pointage pointage) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/pointages'),
      body: jsonEncode(pointage.toJson()),
      headers: {'Content-Type': 'application/json'},
    );

    switch (response.statusCode) {
      case 201:
        return Pointage.fromJson(jsonDecode(response.body));
      case 400:
        throw BusinessException(jsonDecode(response.body)['message']);
      case 404:
        throw NotFoundException(jsonDecode(response.body)['message']);
      default:
        throw Exception('Erreur serveur: ${response.statusCode}');
    }
  }

  Future<Pointage> getTodayPointage(int employeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/pointages/employe/$employeId/today'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return Pointage.fromJson(json.decode(response.body));
      }
      switch (response.statusCode) {
        case 201:
          return Pointage.fromJson(jsonDecode(response.body));
        case 400:
          throw BusinessException(jsonDecode(response.body)['message']);
        case 404:
          throw NotFoundException(jsonDecode(response.body)['message']);
        default:
          throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: ${e.toString()}');
    }
  }

  // 🔹 Modifier un pointage existant
  Future<Pointage?> updatePointage(Pointage pointage) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/pointages/${pointage.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(pointage.toJson()),
    );

    if (response.statusCode == 200) {
      return Pointage.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to update pointage');
    }
  }

  // 🔹 Supprimer un pointage
  Future<bool> deletePointage(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/pointages/$id'));

    if (response.statusCode == 204) {
      return true;
    } else if (response.statusCode == 404) {
      return false;
    } else {
      throw Exception('Failed to delete pointage');
    }
  }

  // 🔹 Récupérer les pointages d'un employé spécifique
  Future<List<Pointage>> getPointagesByEmploye(int employeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/pointages/employe/$employeId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Pointage.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load pointages for employe');
    }
  }
}
