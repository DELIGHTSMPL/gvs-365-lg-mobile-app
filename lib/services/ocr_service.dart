class OcrResult {
  final int detectedKm;
  final double confidenceScore;
  final bool isHighConfidence;
  final String rawOcrText;
  final String originalPhotoPath;

  OcrResult({
    required this.detectedKm,
    required this.confidenceScore,
    required this.isHighConfidence,
    required this.rawOcrText,
    required this.originalPhotoPath,
  });
}

class OcrService {
  static final OcrService _instance = OcrService._internal();
  factory OcrService() => _instance;
  OcrService._internal();

  /// Processes Speedometer / Odometer Photo & extracts numeric kilometer reading
  Future<OcrResult> processSpeedometerImage(String photoPath, {bool isEvening = false}) async {
    // Simulate AI OCR Model scanning speedometers (digital & analog)
    await Future.delayed(const Duration(milliseconds: 1400));

    final km = isEvening ? 45348 : 45210;
    const confidence = 96.5; // 96.5% High Confidence

    return OcrResult(
      detectedKm: km,
      confidenceScore: confidence,
      isHighConfidence: confidence >= 85.0,
      rawOcrText: 'ODOMETER: 0${km}km [ACCURACY: HIGH]',
      originalPhotoPath: photoPath,
    );
  }
}
