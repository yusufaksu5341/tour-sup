import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../models/landmark.dart';
import '../services/camera_service.dart';
import '../services/landmark_classifier.dart';
import '../widgets/landmark_card.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  final CameraService _cameraService = CameraService();
  final LandmarkClassifier _classifier = LandmarkClassifier();

  bool _cameraReady = false;
  bool _isScanning = false;
  Landmark? _detectedLandmark;
  double? _confidence;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initServices();
  }

  Future<void> _initServices() async {
    await Future.wait([
      _cameraService.initialize(),
      _classifier.initialize(),
    ]);
    if (mounted) {
      setState(() => _cameraReady = _cameraService.isInitialized);
    }
  }

  Future<void> _scan() async {
    if (_isScanning) return;
    setState(() {
      _isScanning = true;
      _detectedLandmark = null;
      _confidence = null;
    });

    final photo = await _cameraService.takePicture();

    if (photo == null) {
      if (mounted) setState(() => _isScanning = false);
      return;
    }

    final result = await _classifier.classify(File(photo.path));

    if (!mounted) return;

    if (result == null) {
      setState(() => _isScanning = false);
      _showNotFound();
      return;
    }

    final matched = _findLandmarkByLabel(result.label);

    setState(() {
      _isScanning = false;
      _detectedLandmark = matched;
      _confidence = result.confidence;
    });
  }

  Landmark? _findLandmarkByLabel(String label) {
    try {
      return mockLandmarks.firstWhere(
        (l) => l.name.toLowerCase() == label.toLowerCase(),
      );
    } catch (_) {
      return Landmark(
        id: 'unknown',
        name: label,
        description: 'Bu yapı hakkında detaylı bilgi yakında eklenecektir.',
        city: '',
        period: '',
      );
    }
  }

  void _showNotFound() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Yapı tanınamadı. Kamerayı yapıya daha iyi odaklayın.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cameraService.dispose();
    _classifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildCameraPreview(),
        _buildScanOverlay(),
        if (_detectedLandmark != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_confidence != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _ConfidenceBadge(confidence: _confidence!),
                  ),
                LandmarkCard(
                  landmark: _detectedLandmark!,
                  onClose: () => setState(() {
                    _detectedLandmark = null;
                    _confidence = null;
                  }),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCameraPreview() {
    if (!_cameraReady || _cameraService.controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_alt, color: Colors.white54, size: 64),
              SizedBox(height: 12),
              Text(
                'Kamera başlatılıyor...',
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      );
    }
    return SizedBox.expand(
      child: CameraPreview(_cameraService.controller!),
    );
  }

  Widget _buildScanOverlay() {
    return Positioned.fill(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isScanning
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white70,
                  width: 2.5,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _isScanning
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 32),
          if (!_isScanning && _detectedLandmark == null)
            ElevatedButton.icon(
              onPressed: _scan,
              icon: const Icon(Icons.search),
              label: const Text('Yapıyı Tanı'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
        ],
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final double confidence;

  const _ConfidenceBadge({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final percent = (confidence * 100).toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Güven skoru: %$percent',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
