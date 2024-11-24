import 'dart:async';
import '../../domain/entities/document_data.dart';
import '../../domain/repositories/document_scanner_repository.dart';
import '../datasources/gpt_source.dart';

class DocumentScannerRepositoryImpl implements DocumentScannerRepository {
  final GPTSource gptSource;
  
  DocumentScannerRepositoryImpl({
    required this.gptSource,
  });

  @override
  Future<DocumentData?> processDocument(String image) {
    return gptSource.processDocument(image);
  }
} 