import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'location_service.dart';

final locationServiceProvider = Provider<LocationService>(
  (_) => LocationService(),
);

final currentLocationProvider = FutureProvider<LocationResult?>(
  (ref) => ref.watch(locationServiceProvider).getCurrentLocation(),
);

final locationStreamProvider = StreamProvider<LocationResult>(
  (ref) => ref.watch(locationServiceProvider).getLocationStream(),
);
