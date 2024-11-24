class ScanResult {
  final String image;
  final double confidence;
  final DateTime timestamp;

  ScanResult({
    required this.image,
    required this.confidence,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
} 