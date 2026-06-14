class GetSolarData {
  const GetSolarData();

  Map<String, dynamic> execute({required String sunrise, required String sunset, required String moonPhase, required int azimuth}) {
    return {
      'sunrise': sunrise,
      'sunset': sunset,
      'moonPhase': moonPhase,
      'azimuth': azimuth,
    };
  }
}
