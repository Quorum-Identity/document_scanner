import 'dart:async';
import 'package:flutter/services.dart';
import '../../domain/entities/document_data.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/repositories/document_scanner_repository.dart';
import '../datasources/gpt_source.dart';

class DocumentScannerRepositoryImpl implements DocumentScannerRepository {
  final GPTSource gptSource;
  final MethodChannel _channel;
  StreamController<ScanResult>? _scanController;

  DocumentScannerRepositoryImpl({
    required this.gptSource,
    MethodChannel? channel,
  }) : _channel = channel ?? const MethodChannel('document_scanner');

  @override
  Stream<ScanResult> startScanning() {
    _scanController = StreamController<ScanResult>();

    _channel.invokeMethod('startScanning').then((_) {
      // Configurar el stream de la cámara
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'onFrame') {
          final frame = call.arguments as Map<String, dynamic>;
          _scanController?.add(ScanResult(
            image: frame['image'],
            confidence: frame['confidence'] ?? 0.0,
          ));
        }
      });
    });

    return _scanController!.stream;
  }

  @override
  Future<DocumentData?> processDocument(String image) {
    return gptSource.processDocument(image);
  }

  @override
  void stopScanning() {
    _channel.invokeMethod('stopScanning');
    _scanController?.close();
    _scanController = null;
  }
} 