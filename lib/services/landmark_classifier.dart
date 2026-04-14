import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ClassificationResult {
  final String label;
  final double confidence;

  const ClassificationResult({required this.label, required this.confidence});
}

class LandmarkClassifier {
  static const String _modelPath = 'assets/models/landmark_yolov8.tflite';
  static const String _labelsPath = 'assets/labels/landmark_labels.txt';
  static const int _inputSize = 320;
  static const double _confidenceThreshold = 0.6;

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isReady = false;

  bool get isReady => _isReady;

  Future<void> initialize() async {
    await _loadLabels();
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

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(_modelPath);
      _isReady = true;
    } catch (e) {
      // Model henüz eklenmediğinde uygulama çökmez, mock sonuç döner.
      _isReady = false;
    }
  }

  Future<ClassificationResult?> classify(File imageFile) async {
    if (!_isReady || _interpreter == null) {
      return _mockResult();
    }

    final rawImage = img.decodeImage(await imageFile.readAsBytes());
    if (rawImage == null) return null;

    final resized =
        img.copyResize(rawImage, width: _inputSize, height: _inputSize);

    final input = _imageToFloat32List(resized);
    final outputShape = _interpreter!.getOutputTensor(0).shape;
    final output =
        List.filled(outputShape.reduce((a, b) => a * b), 0.0).reshape(outputShape);

    _interpreter!.run(input, output);

    return _parseOutput(output);
  }

  List _imageToFloat32List(img.Image image) {
    final bytes = <double>[];
    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = image.getPixel(x, y);
        bytes.add(pixel.r / 255.0);
        bytes.add(pixel.g / 255.0);
        bytes.add(pixel.b / 255.0);
      }
    }
    final flat = bytes;
    final shaped = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) => List.generate(3, (c) {
            return flat[(y * _inputSize + x) * 3 + c];
          }),
        ),
      ),
    );
    return shaped;
  }

  ClassificationResult? _parseOutput(List output) {
    final scores = (output[0] as List).cast<double>();
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
      confidence: maxScore,
    );
  }

  // Model dosyası henüz yokken demo için
  ClassificationResult _mockResult() {
    return const ClassificationResult(
      label: 'Ayasofya',
      confidence: 0.91,
    );
  }

  void dispose() {
    _interpreter?.close();
  }
}
