import 'dart:io';

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
  bool get isReady => false;

  Future<void> initialize() async {}

  Future<ClassificationResult?> classify(File imageFile) async {
    return null;
  }

  void dispose() {}
}
