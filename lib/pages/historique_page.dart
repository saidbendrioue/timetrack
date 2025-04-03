import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timetrack/models/employe.model.dart';
import 'package:timetrack/models/pointage.model.dart';
import 'package:timetrack/services/pointage.api.dart';
import 'package:timetrack/utils/time_utils.dart';

class HistoriquePage extends StatefulWidget {
  const HistoriquePage({super.key});

  @override
  State<HistoriquePage> createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  final couleurDemiJournee = const Color.fromARGB(255, 255, 232, 197);
  final couleurPresent = const Color.fromARGB(255, 215, 255, 236);
  final couleurAbscent = const Color.fromARGB(255, 253, 223, 223);

  List<Map<String, dynamic>> _pointages = [];
  bool _isLoading = true;
  String? _error;

  Future<void> initPointages() async {
    await initializeDateFormatting('fr_FR');
    try {
      final pointageService = PointageService();
      final prefs = await SharedPreferences.getInstance();
      final employeString = prefs.getString('employe');
      if (employeString != null) {
        final currentEmploye = Employe.fromJson(jsonDecode(employeString));
        final pointages = await pointageService.getPointagesByEmploye(
          currentEmploye.id,
        );

        setState(() {
          _pointages =
              pointages.map((pointage) {
                return {
                  'date': pointage.date,
                  'arrivee': _formatTimeOfDay(pointage.heureArrivee),
                  'depart':
                      pointage.heureDepart != null
                          ? _formatTimeOfDay(pointage.heureDepart!)
                          : '-',
                  'status': _determineStatus(pointage),
                };
              }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Aucun employé connecté';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des pointages';
        _isLoading = false;
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.Hm().format(dt);
  }

  String _determineStatus(Pointage pointage) {
    if (pointage.heureDepart == null) {
      return 'En cours...';
    } else if (pointage.heureDepart!.hour - pointage.heureArrivee.hour < 4) {
      return 'Demi-journée';
    } else if (pointage.type == 'ABSENT') {
      return 'Absent';
    } else {
      return 'Présent';
    }
  }

  @override
  void initState() {
    super.initState();
    initPointages();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historique de présence en ${DateFormat('MMMM', 'fr_FR').format(DateTime.now()).toUpperCase()}',
          style: const TextStyle(fontSize: 14),
        ),
      ),
      body: Column(
        children: [
          Text(
            'Total des heures travaillées : ${TimeUtils.calculateMonthlyTotal(_pointages)}',
            style: const TextStyle(fontSize: 14),
          ),
          _buildCalendarGrid(),
          Expanded(
            child: ListView.builder(
              itemCount: _pointages.length,
              itemBuilder: (context, index) {
                final pointage = _pointages[index];
                return _buildPointageCard(pointage);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startingWeekday = firstDay.weekday;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemCount: daysInMonth + startingWeekday - 1,
      itemBuilder: (context, index) {
        if (index < startingWeekday - 1) {
          return Container();
        }

        final day = index - startingWeekday + 2;
        final currentDate = DateTime(now.year, now.month, day);

        final pointage = _pointages.firstWhere(
          (p) => DateUtils.isSameDay(p['date'] as DateTime, currentDate),
          orElse:
              () => <String, Object>{
                'date': currentDate,
                'arrivee': '-',
                'depart': '-',
                'status': '',
              },
        );
        Color bgColor = Colors.transparent;
        String status = '';
        final displayStatus = pointage['status'] as String;

        switch (displayStatus) {
          case 'Présent':
            bgColor = couleurPresent;
            status = '✓';
            break;
          case 'Absent':
            bgColor = couleurAbscent;
            status = '✗';
            break;
          case 'Demi-journée':
            bgColor = couleurDemiJournee;
            status = '½';
            break;
          case 'En cours...':
            bgColor = Colors.blue.withOpacity(0.2);
            status = '...';
            break;
          default:
            bgColor = Colors.transparent;
            status = '-';
        }

        return InkWell(
          onTap:
              displayStatus.isNotEmpty
                  ? () => _showPointageDetails(context, pointage)
                  : null,
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: day == now.day ? Colors.blue : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          day == now.day ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStatusTextColor(displayStatus),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Présent':
        return Colors.green;
      case 'Absent':
        return Colors.red;
      case 'Demi-journée':
        return Colors.orange;
      case 'En cours...':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Présent':
        return Colors.lightGreen;
      case 'Absent':
        return Colors.red;
      case 'Demi-journée':
        return Colors.orangeAccent;
      case 'En cours...':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Présent':
        return Icons.check;
      case 'Absent':
        return Icons.close;
      case 'Demi-journée':
        return Icons.access_time;
      case 'En cours...':
        return Icons.timer;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildPointageCard(Map<String, dynamic> pointage) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () => _showPointageDetails(context, pointage),
        child: ListTile(
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getStatusColor(pointage['status']),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(pointage['status']),
              color: Colors.white,
            ),
          ),
          title: Text(
            DateFormat('EEEE d MMMM', 'fr_FR').format(pointage['date']),
            style: TextStyle(fontSize: 12),
          ),
          subtitle: Text(
            'Arrivée: ${pointage['arrivee']} | Départ: ${pointage['depart']}',
            style: TextStyle(fontSize: 11),
          ),
          trailing: Text(
            pointage['status'],
            style: TextStyle(
              color: _getStatusColor(pointage['status']),
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  void _showPointageDetails(
    BuildContext context,
    Map<String, dynamic> pointage,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              DateFormat('EEEE d MMMM y', 'fr_FR').format(pointage['date']),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Statut:', pointage['status']),
                SizedBox(height: 8),
                _buildDetailRow('Heure d\'arrivée:', pointage['arrivee']),
                SizedBox(height: 8),
                _buildDetailRow('Heure de départ:', pointage['depart']),
                SizedBox(height: 12),
                if (pointage['arrivee'] != '-' && pointage['depart'] != '-')
                  _buildDurationRow(pointage),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('FERMER', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(width: 8),
        Text(value, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildDurationRow(Map<String, dynamic> pointage) {
    final durationStr = TimeUtils.getFormattedDuration(
      pointage['arrivee'],
      pointage['depart'],
    );

    return durationStr != null
        ? _buildDetailRow('Durée totale:', durationStr)
        : SizedBox();
  }
}
