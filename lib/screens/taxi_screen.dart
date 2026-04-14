import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/taxi_fare.dart';
import '../services/location_service.dart';
import '../services/providers.dart';

class TaxiScreen extends ConsumerStatefulWidget {
  const TaxiScreen({super.key});

  @override
  ConsumerState<TaxiScreen> createState() => _TaxiScreenState();
}

class _TaxiScreenState extends ConsumerState<TaxiScreen> {
  TripRecord? _trip;
  StreamSubscription<LocationResult>? _locationSub;
  LocationResult? _lastLocation;
  bool _isTracking = false;

  static const double _deviationThresholdMeters = 500;

  Future<void> _startTrip() async {
    final locationService = ref.read(locationServiceProvider);
    final granted = await locationService.requestPermission();

    if (!granted) {
      _showPermissionDenied();
      return;
    }

    final current = await locationService.getCurrentLocation();
    if (current == null) return;

    setState(() {
      _trip = TripRecord(
        startTime: DateTime.now(),
        startLat: current.latitude,
        startLng: current.longitude,
      );
      _lastLocation = current;
      _isTracking = true;
    });

    _locationSub = locationService.getLocationStream().listen((loc) async {
      if (_trip == null) return;

      final added = await locationService.distanceBetween(
        _lastLocation!.latitude,
        _lastLocation!.longitude,
        loc.latitude,
        loc.longitude,
      );

      final totalDeviation = await locationService.distanceBetween(
        _trip!.startLat,
        _trip!.startLng,
        loc.latitude,
        loc.longitude,
      );

      setState(() {
        _trip!.update(
          newLat: loc.latitude,
          newLng: loc.longitude,
          addedMeters: added,
        );
        _lastLocation = loc;
      });

      if (!_trip!.deviationWarned &&
          totalDeviation > _deviationThresholdMeters &&
          _trip!.totalDistanceKm > 1.0) {
        _trip!.deviationWarned = true;
        _showDeviationWarning();
      }
    });
  }

  void _stopTrip() {
    _locationSub?.cancel();
    setState(() => _isTracking = false);
  }

  void _resetTrip() {
    _locationSub?.cancel();
    setState(() {
      _trip = null;
      _isTracking = false;
      _lastLocation = null;
    });
  }

  void _showPermissionDenied() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Konum izni verilmedi. Lütfen ayarlardan izin verin.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showDeviationWarning() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded,
            color: Colors.orange, size: 40),
        title: const Text('Güzergah Uyarısı'),
        content: const Text(
          'Taksi başlangıç noktanızdan beklenenden fazla uzaklaştı. '
          'Güzergahı şoföre teyit ettirmeniz önerilir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TariffCard(),
          const SizedBox(height: 20),
          if (_trip == null) _buildStartCard() else _buildTripCard(),
        ],
      ),
    );
  }

  Widget _buildStartCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.local_taxi, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              'Taksi yolculuğunuzu başlatın',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'GPS ile mesafe takibi yapılır ve güncel İstanbul tarifesine göre '
              'tahmini ücret hesaplanır.',
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _startTrip,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Yolculuğu Başlat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard() {
    final trip = _trip!;
    return Column(
      children: [
        _StatusBanner(isTracking: _isTracking),
        const SizedBox(height: 12),
        _MetricGrid(trip: trip),
        const SizedBox(height: 20),
        _FareDisplay(fare: trip.estimatedFare),
        const SizedBox(height: 24),
        if (_isTracking)
          ElevatedButton.icon(
            onPressed: _stopTrip,
            icon: const Icon(Icons.stop),
            label: const Text('Yolculuğu Durdur'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          )
        else
          Column(
            children: [
              ElevatedButton.icon(
                onPressed: _startTrip,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Devam Et'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _resetTrip,
                icon: const Icon(Icons.refresh),
                label: const Text('Yeni Yolculuk'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _TariffCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.info_outline,
                color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'İstanbul tarifesi: Açılış ₺${TaxiFare.openingFee}  '
                '· km başı ₺${TaxiFare.perKmFee}  '
                '· dk başı ₺${TaxiFare.perMinuteFee}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final bool isTracking;
  const _StatusBanner({required this.isTracking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isTracking ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTracking ? Colors.green : Colors.orange,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isTracking ? Icons.gps_fixed : Icons.pause_circle_outline,
            color: isTracking ? Colors.green : Colors.orange,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            isTracking ? 'Takip aktif' : 'Takip duraklatıldı',
            style: TextStyle(
              color: isTracking ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final TripRecord trip;
  const _MetricGrid({required this.trip});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _MetricTile(
          label: 'Mesafe',
          value: '${trip.totalDistanceKm.toStringAsFixed(2)} km',
          icon: Icons.straighten,
        ),
        _MetricTile(
          label: 'Süre',
          value: '${trip.elapsedMinutes} dk',
          icon: Icons.timer,
        ),
        _MetricTile(
          label: 'Başlangıç',
          value:
              '${trip.startTime.hour.toString().padLeft(2, '0')}:'
              '${trip.startTime.minute.toString().padLeft(2, '0')}',
          icon: Icons.access_time,
        ),
        _MetricTile(
          label: 'Ortalama Hız',
          value: trip.elapsedMinutes > 0
              ? '${(trip.totalDistanceKm / (trip.elapsedMinutes / 60)).toStringAsFixed(0)} km/s'
              : '—',
          icon: Icons.speed,
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _MetricTile(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FareDisplay extends StatelessWidget {
  final double fare;
  const _FareDisplay({required this.fare});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Tahmini Ücret',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            '₺${fare.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'İstanbul tarifesine göre hesaplanmıştır',
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
