class AltitudeService {
  const AltitudeService();

  Future<double> getAltitudeMeters() async {
    await Future.delayed(const Duration(milliseconds: 80));
    return 1132.0;
  }

  Future<String> getAltitudeSource() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return 'Barometer';
  }
}
