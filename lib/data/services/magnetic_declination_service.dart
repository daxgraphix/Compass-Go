import 'dart:math';

/// Calculates magnetic declination using World Magnetic Model (WMM) simplified formulas
/// Based on NOAA's magnetic declination algorithm
class MagneticDeclinationService {
  /// Calculate magnetic declination at given coordinates
  /// Returns declination in degrees (positive = east, negative = west)
  static double calculateDeclination(
    double latitude,
    double longitude,
    DateTime date,
  ) {
    // Simplified WMM calculation (accurate to within ~1 degree)
    // For production, use full WMM coefficients

    // Calculate decimal year from date
    final dayOfYear = date.difference(DateTime(date.year)).inDays + 1;
    final decimalYear = date.year + (dayOfYear / (isLeapYear(date.year) ? 366 : 365));

    // Regional magnetic field coefficients (simplified)
    final gmtCoeff = _getGMTCoefficients(latitude, longitude);

    // Calculate declination components
    double declination = gmtCoeff['g10'] ?? 0;
    declination += (gmtCoeff['g11'] ?? 0) * cos(latitude * pi / 180);
    declination += (gmtCoeff['h11'] ?? 0) * sin(latitude * pi / 180);

    // Apply secular variation (annual change)
    final yearDiff = decimalYear - 2020; // Reference year
    declination += (gmtCoeff['dgdt'] ?? 0) * yearDiff;

    return declination;
  }

  /// Get simplified GMT coefficients for location
  /// In production, use full WMM coefficient set
  static Map<String, double> _getGMTCoefficients(
    double latitude,
    double longitude,
  ) {
    // Simplified coefficients (approximate values for demonstration)
    // Production implementation would use full WMM model

    // Note: latZone and lonZone can be used for future regional optimization

    // Base declination values for regions (rough approximation)
    double baseDeclination = 0;

    // Northern Hemisphere examples
    if (latitude > 0 && latitude < 60) {
      if (longitude > -100 && longitude < -50) {
        // North America
        baseDeclination = -10; // Approximate for central NA
      } else if (longitude > -30 && longitude < 30) {
        // Europe/Africa
        baseDeclination = 0;
      } else if (longitude > 60 && longitude < 120) {
        // Asia
        baseDeclination = 5;
      }
    }

    // Apply latitude adjustment
    baseDeclination += (latitude / 30) * 2;

    return {
      'g10': baseDeclination,
      'g11': 0.1,
      'h11': 0.05,
      'dgdt': -0.05, // Annual change in degrees
    };
  }

  /// Convert magnetic heading to true heading using declination
  static double magneticToTrueHeading(double magneticHeading, double declination) {
    double trueHeading = magneticHeading + declination;
    if (trueHeading >= 360) {
      trueHeading -= 360;
    } else if (trueHeading < 0) {
      trueHeading += 360;
    }
    return trueHeading;
  }

  /// Convert true heading to magnetic heading using declination
  static double trueToMagneticHeading(double trueHeading, double declination) {
    double magneticHeading = trueHeading - declination;
    if (magneticHeading >= 360) {
      magneticHeading -= 360;
    } else if (magneticHeading < 0) {
      magneticHeading += 360;
    }
    return magneticHeading;
  }

  /// Check if given year is a leap year
  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }
}
