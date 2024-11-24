import '../entities/document_data.dart';

abstract class DocumentScannerRepository {
  Future<DocumentData?> processDocument(String image);
} 