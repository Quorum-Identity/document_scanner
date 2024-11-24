abstract class Failure implements Exception {
  final String message;
  const Failure(this.message);
}

class DocumentScannerFailure extends Failure {
  const DocumentScannerFailure(String message) : super(message);
}

class GPTFailure extends Failure {
  const GPTFailure(String message) : super(message);
} 