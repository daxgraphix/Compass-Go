import 'dart:math';

class SolarService {
  /// Calculate sunrise and sunset times for given location and date
  /// Returns map with 'sunrise' and 'sunset' as DateTime objects
  static Map<String, DateTime?> calculateSunriseSunset(
    double latitude,
    double longitude,
    DateTime date,
  ) {
    // NOAA solar calculation algorithm
    final n = _dayOfYear(date) - 1; // Days since January 1

    // Calculate solar declination
    final B = (360 / 365.25) * (n + 1);
    final decRad = (0.006918 -
            0.399912 * cos(B * pi / 180) +
            0.070257 * sin(B * pi / 180) -
            0.006758 * cos(2 * B * pi / 180) +
            0.000907 * sin(2 * B * pi / 180) -
            0.002697 * cos(3 * B * pi / 180) +
            0.00111 * sin(3 * B * pi / 180)) *
        180 /
        pi;

    // Calculate equation of time
    final eot = 229.2 *
        (0.000075 +
            0.001868 * cos(B * pi / 180) -
            0.032077 * sin(B * pi / 180) -
            0.014615 * cos(2 * B * pi / 180) -
            0.040849 * sin(2 * B * pi / 180));

    // Calculate solar noon
    final lonStandardMeridian = ((longitude / 15).round() * 15).toDouble();
    final timeOffset = (longitude - lonStandardMeridian) * 4 / 60; // in minutes
    final solarNoonMinutes = 720 - timeOffset - eot;

    // Calculate sunrise and sunset hour angles
    final latRad = latitude * pi / 180;
    final decRad2 = decRad * pi / 180;

    final cosH = -tan(latRad) * tan(decRad2);
    if (cosH > 1) {
      // Sun doesn't rise (polar night)
      return {'sunrise': null, 'sunset': null};
    }
    if (cosH < -1) {
      // Sun doesn't set (polar day)
      return {
        'sunrise': DateTime(date.year, date.month, date.day, 0, 0),
        'sunset': DateTime(date.year, date.month, date.day, 23, 59)
      };
    }

    final h = acos(cosH) * 180 / pi;
    final sunriseMinutes = solarNoonMinutes - h * 4;
    final sunsetMinutes = solarNoonMinutes + h * 4;

    return {
      'sunrise': _minutesToDateTime(date, sunriseMinutes),
      'sunset': _minutesToDateTime(date, sunsetMinutes),
    };
  }

  /// Calculate solar position (azimuth and elevation)
  static Map<String, double> calculateSolarPosition(
    double latitude,
    double longitude,
    DateTime dateTime,
  ) {
    final n = _dayOfYear(dateTime) - 1;

    // Solar declination
    final B = (360 / 365.25) * (n + 1);
    final decRad = (0.006918 -
            0.399912 * cos(B * pi / 180) +
            0.070257 * sin(B * pi / 180) -
            0.006758 * cos(2 * B * pi / 180) +
            0.000907 * sin(2 * B * pi / 180) -
            0.002697 * cos(3 * B * pi / 180) +
            0.00111 * sin(3 * B * pi / 180)) *
        180 /
        pi;

    // Local solar time
    final eotValue = 229.2 *
        (0.000075 +
            0.001868 * cos(B * pi / 180) -
            0.032077 * sin(B * pi / 180) -
            0.014615 * cos(2 * B * pi / 180) -
            0.040849 * sin(2 * B * pi / 180));

    final lonStandardMeridian = ((longitude / 15).round() * 15).toDouble();
    final timeOffset = (longitude - lonStandardMeridian) * 4 / 60;
    final localTime = dateTime.hour + dateTime.minute / 60 + (timeOffset / 60) + (eotValue / 1440);
    final hourAngle = localTime * 15 - 180; // Hour angle in degrees

    // Solar altitude angle
    final latRad = latitude * pi / 180;
    final decRad2 = decRad * pi / 180;
    final hRad = hourAngle * pi / 180;

    final sinElevation = sin(latRad) * sin(decRad2) +
        cos(latRad) * cos(decRad2) * cos(hRad);
    final elevation = asin(sinElevation.clamp(-1, 1)) * 180 / pi;

    // Solar azimuth angle
    final cosAzimuth =
        (sin(decRad2) - sin(latRad) * sinElevation) / (cos(latRad) * cos(asin(sinElevation)));
    final azimuth = acos(cosAzimuth.clamp(-1, 1)) * 180 / pi;

    // Adjust azimuth based on hour angle
    final finalAzimuth = hourAngle > 0 ? 180 - azimuth : azimuth + 180;

    return {
      'azimuth': (finalAzimuth % 360 + 360) % 360,
      'elevation': elevation,
    };
  }

  /// Calculate moon phase (0-1, 0=new, 0.5=full, 1=new again)
  static double calculateMoonPhase(DateTime date) {
    // Known new moon date (January 6, 2000)
    final knownNewMoon = DateTime(2000, 1, 6);
    final lunarCycle = 29.53058867; // Days per lunar cycle

    final daysSinceNewMoon = date.difference(knownNewMoon).inHours / 24.0;
    final phase = (daysSinceNewMoon / lunarCycle) % 1;

    return phase;
  }

  /// Calculate moon illumination percentage (0-100)
  static double calculateMoonIllumination(DateTime date) {
    final phase = calculateMoonPhase(date);
    // Illumination is highest at phase 0.5 (full moon)
    // Follows cosine curve
    return (cos(phase * 2 * pi) + 1) / 2 * 100;
  }

  /// Get moon phase name
  static String getMoonPhaseName(double phase) {
    if (phase < 0.125) return 'New Moon';
    if (phase < 0.25) return 'Waxing Crescent';
    if (phase < 0.375) return 'First Quarter';
    if (phase < 0.5) return 'Waxing Gibbous';
    if (phase < 0.625) return 'Full Moon';
    if (phase < 0.75) return 'Waning Gibbous';
    if (phase < 0.875) return 'Last Quarter';
    return 'Waning Crescent';
  }

  /// Format time for display
  static String formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Helper methods
  static int _dayOfYear(DateTime date) {
    return date.difference(DateTime(date.year, 1, 1)).inDays + 1;
  }

  static DateTime? _minutesToDateTime(DateTime date, double minutes) {
    if (minutes < 0 || minutes >= 1440) {
      return null; // Invalid time
    }
    final hours = (minutes ~/ 60).toInt();
    final mins = (minutes % 60).toInt();
    return DateTime(date.year, date.month, date.day, hours, mins);
  }
}
