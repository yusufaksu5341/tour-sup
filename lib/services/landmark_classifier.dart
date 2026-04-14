import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ClassificationResult {
  final String label;
  final String landmarkId;
  final double confidence;

  const ClassificationResult({
    required this.label,
    required this.landmarkId,
    required this.confidence,
  });
}

class LandmarkClassifier {
  // EfficientNetB0 224×224 giriş bekliyor (YOLOv8'in 320'sinden farklı)
  static const String _modelPath = 'assets/models/landmark_efficientnet.tflite';
  static const String _labelsPath = 'assets/labels/landmark_labels.txt';
  static const String _classMapPath = 'assets/labels/landmark_class_map.json';
  static const int _inputSize = 224;
  static const double _confidenceThreshold = 0.6;

  Interpreter? _interpreter;
  List<String> _labels = [];
  Map<int, String> _classMap = {}; // index → landmark id
  bool _isReady = false;

  bool get isReady => _isReady;

  Future<void> initialize() async {
    await Future.wait([_loadLabels(), _loadClassMap()]);
    await _loadModel();
  }

  Future<void> _loadLabels() async {
    final raw = await rootBundle.loadString(_labelsPath);
    _labels = raw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  Future<void> _loadClassMap() async {
    final raw = await rootBundle.loadString(_classMapPath);
    final Map<String, dynamic> decoded = jsonDecode(raw);
    _classMap = decoded.map((k, v) => MapEntry(int.parse(k), v as String));
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(_modelPath);
      _isReady = true;
    } catch (_) {
      // Model henüz eğitilmemiş — uygulama mock sonuçla çalışmaya devam eder
      _isReady = false;
    }
  }

  Future<ClassificationResult?> classify(File imageFile) async {
    if (!_isReady || _interpreter == null) return _mockResult();

    final rawImage = img.decodeImage(await imageFile.readAsBytes());
    if (rawImage == null) return null;

    final resized =
        img.copyResize(rawImage, width: _inputSize, height: _inputSize);

    // EfficientNetB0 ham piksel bekliyor (0–255), model içinde normalize eder
    final input = _imageToUint8Input(resized);

    // Çıktı: [1, NUM_CLASSES] softmax olasılıkları
    final output = List.generate(1, (_) => List.filled(_labels.length, 0.0));

    _interpreter!.run(input, output);

    return _parseOutput(output[0]);
  }

  /// Görüntüyü [1, 224, 224, 3] uint8 tensörüne çevirir.
  List _imageToUint8Input(img.Image image) {
    return List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) => List.generate(3, (c) {
            final pixel = image.getPixel(x, y);
            return c == 0 ? pixel.r.toInt() : c == 1 ? pixel.g.toInt() : pixel.b.toInt();
          }),
        ),
      ),
    );
  }

  ClassificationResult? _parseOutput(List<double> scores) {
    double maxScore = 0;
    int maxIndex = 0;

    for (int i = 0; i < scores.length; i++) {
      if (scores[i] > maxScore) {
        maxScore = scores[i];
        maxIndex = i;
      }
    }

    if (maxScore < _confidenceThreshold) return null;
    if (maxIndex >= _labels.length) return null;

    return ClassificationResult(
      label: _labels[maxIndex],
      landmarkId: _classMap[maxIndex] ?? 'unknown',
      confidence: maxScore,
    );
  }

  ClassificationResult _mockResult() {
    return const ClassificationResult(
      label: 'Ayasofya',
      landmarkId: 'hagia_sophia',
      confidence: 0.91,
    );
  }

  void dispose() {
    _interpreter?.close();
  }
}
