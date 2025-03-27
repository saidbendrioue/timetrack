// utils/time_utils.dart

class TimeUtils {
  /// Calculates duration between two time strings in "HH:mm" format
  /// Returns a Duration object or null if invalid input
  static Duration? calculateDuration(String startTime, String endTime) {
    if (startTime == '-' || endTime == '-') return null;

    try {
      final startParts = startTime.split(':');
      final endParts = endTime.split(':');

      final startHour = int.parse(startParts[0]);
      final startMin = int.parse(startParts[1]);
      final endHour = int.parse(endParts[0]);
      final endMin = int.parse(endParts[1]);

      return Duration(hours: endHour - startHour, minutes: endMin - startMin);
    } catch (e) {
      return null;
    }
  }

  /// Formats duration as "XhXX" (e.g., "8h30")
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h${minutes.toString().padLeft(2, '0')}';
  }

  /// Calculates and formats duration between two times
  static String? getFormattedDuration(String startTime, String endTime) {
    final duration = calculateDuration(startTime, endTime);
    return duration != null ? formatDuration(duration) : null;
  }

  static String calculateMonthlyTotal(List<Map<String, dynamic>> pointages) {
    Duration total = Duration.zero;

    for (final pointage in pointages) {
      if (pointage['arrivee'] != '-' && pointage['depart'] != '-') {
        final duration = calculateDuration(
          pointage['arrivee'],
          pointage['depart'],
        );
        if (duration != null) {
          total += duration;
        }
      }
    }

    return formatTotalDuration(total);
  }

  /// Formats total duration for display (X jours Y heures Z minutes)
  static String formatTotalDuration(Duration duration) {
final totalHours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${totalHours}h${minutes.toString().padLeft(2, '0')}min';
  }
}
