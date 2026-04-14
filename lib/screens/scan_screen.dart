import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../models/landmark.dart';
import '../services/camera_service.dart';
import '../widgets/landmark_card.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  final CameraService _cameraService = CameraService();

  bool _cameraReady = false;
  bool _isScanning = false;
  Landmark? _detectedLandmark;

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

    _initCamera();
  }

  Future<void> _initCamera() async {
    await _cameraService.initialize();
    if (mounted) {
      setState(() => _cameraReady = _cameraService.isInitialized);
    }
  }

  Future<void> _scan() async {
    if (_isScanning) return;
    setState(() {
      _isScanning = true;
      _detectedLandmark = null;
    });

    await Future.delayed(const Duration(milliseconds: 1800));

    // Mock: gerçekte model çıktısı gelecek
    final result = mockLandmarks[
        DateTime.now().millisecondsSinceEpoch % mockLandmarks.length];

    if (mounted) {
      setState(() {
        _isScanning = false;
        _detectedLandmark = result;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cameraService.dispose();
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
            child: LandmarkCard(
              landmark: _detectedLandmark!,
              onClose: () => setState(() => _detectedLandmark = null),
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
