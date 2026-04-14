import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? speed;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.speed,
  });
}

class LocationService {
  static const _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
  );

  Stream<LocationResult>? _positionStream;

  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  Future<LocationResult?> getCurrentLocation() async {
    final granted = await requestPermission();
    if (!granted) return null;

    final position = await Geolocator.getCurrentPosition(
      locationSettings: _locationSettings,
    );

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      speed: position.speed,
    );
  }

  Stream<LocationResult> getLocationStream() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: _locationSettings,
    ).map(
      (pos) => LocationResult(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        speed: pos.speed,
      ),
    );
    return _positionStream!;
  }

  Future<double> distanceBetween(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}
