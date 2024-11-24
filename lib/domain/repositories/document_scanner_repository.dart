import '../entities/document_data.dart';
import '../entities/scan_result.dart';

abstract class DocumentScannerRepository {
  Stream<ScanResult> startScanning();
  Future<DocumentData?> processDocument(String image);
  void stopScanning();
} 