import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timetrack/utils/time_utils.dart';

class HistoriquePage extends StatefulWidget {
  const HistoriquePage({Key? key}) : super(key: key);
  @override
  _HistoriquePageState createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  final couleurDemiJournee = const Color.fromARGB(255, 255, 232, 197);
  final couleurPresent = const Color.fromARGB(255, 215, 255, 236);
  final couleurAbscent = const Color.fromARGB(255, 253, 223, 223);

  // Données bidon pour le mois en cours
  final List<Map<String, dynamic>> _pointages = [
    {
      'date': DateTime.now().subtract(Duration(days: 5)),
      'arrivee': '08:30',
      'depart': '17:15',
      'status': 'Présent',
    },
    {
      'date': DateTime.now().subtract(Duration(days: 4)),
      'arrivee': '09:00',
      'depart': '17:30',
      'status': 'Présent',
    },
    {
      'date': DateTime.now().subtract(Duration(days: 3)),
      'arrivee': '08:45',
      'depart': '12:30',
      'status': 'Demi-journée',
    },
    {
      'date': DateTime.now().subtract(Duration(days: 2)),
      'arrivee': '-',
      'depart': '-',
      'status': 'Absent',
    },
    {
      'date': DateTime.now().subtract(Duration(days: 1)),
      'arrivee': '08:50',
      'depart': '17:20',
      'status': 'Présent',
    },
    {
      'date': DateTime.now(),
      'arrivee': '08:35',
      'depart': '-',
      'status': 'En cours...',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeDateFormatting('fr_FR'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Historique de présence en ${DateFormat('MMMM', 'fr_FR').format(DateTime.now()).toUpperCase()}',
              style: TextStyle(fontSize: 14),
            ),
          ),
          body: Column(
            children: [
              Text(
                'Total des heures travaillées : ${TimeUtils.calculateMonthlyTotal(_pointages)}',
                style: TextStyle(fontSize: 14),
              ),
              // Calendrier du mois
              _buildCalendarGrid(),
              // Liste des pointages
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
      },
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
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemCount: daysInMonth + startingWeekday - 1,
      itemBuilder: (context, index) {
        if (index < startingWeekday - 1) {
          return Container(); // Jours vides avant le 1er du mois
        }

        final day = index - startingWeekday + 2;
        final currentDate = DateTime(now.year, now.month, day);
        final pointage = _pointages.firstWhere(
          (p) => DateUtils.isSameDay(p['date'], currentDate),
          orElse: () => {},
        );

        Color bgColor = Colors.green;
        String status = '';

        if (pointage['status'] == 'Présent') {
          bgColor = couleurPresent;
          status = '✓';
        } else if (pointage['status'] == 'Absent') {
          bgColor = couleurAbscent;
          status = '✗';
        } else if (pointage['status'] == 'Demi-journée') {
          bgColor = couleurDemiJournee;
          status = '½';
        } else {
          bgColor = const Color.fromARGB(0, 255, 255, 255);
          status = '-';
        }

        return InkWell(
          onTap: () => _showPointageDetails(context, pointage),
          child: Container(
            margin: EdgeInsets.all(4),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$day', style: TextStyle(fontSize: 12)),
                  Text(status),
                ],
              ),
            ),
          ),
        );
      },
    );
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
