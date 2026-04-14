class TaxiFare {
  // İstanbul 2024 tarifesi (TL)
  static const double openingFee = 16.0;
  static const double perKmFee = 22.0;
  static const double perMinuteFee = 3.5;
  static const double luggageFee = 10.0;

  static double calculate({
    required double distanceKm,
    required int durationMinutes,
    bool hasLuggage = false,
  }) {
    final total = openingFee +
        (distanceKm * perKmFee) +
        (durationMinutes * perMinuteFee) +
        (hasLuggage ? luggageFee : 0);
    return double.parse(total.toStringAsFixed(2));
  }
}

class TripRecord {
  final DateTime startTime;
  final double startLat;
  final double startLng;
  double currentLat;
  double currentLng;
  double totalDistanceMeters;
  double estimatedFare;
  bool deviationWarned;

  TripRecord({
    required this.startTime,
    required this.startLat,
    required this.startLng,
  })  : currentLat = startLat,
        currentLng = startLng,
        totalDistanceMeters = 0,
        estimatedFare = TaxiFare.openingFee,
        deviationWarned = false;

  int get elapsedMinutes =>
      DateTime.now().difference(startTime).inSeconds ~/ 60;

  double get totalDistanceKm => totalDistanceMeters / 1000;

  void update({
    required double newLat,
    required double newLng,
    required double addedMeters,
  }) {
    currentLat = newLat;
    currentLng = newLng;
    totalDistanceMeters += addedMeters;
    estimatedFare = TaxiFare.calculate(
      distanceKm: totalDistanceKm,
      durationMinutes: elapsedMinutes,
    );
  }
}
