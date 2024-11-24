import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../domain/entities/document_data.dart';
import '../domain/entities/scan_result.dart';
import '../domain/repositories/document_scanner_repository.dart';

class DocumentScannerController extends ChangeNotifier {
  final DocumentScannerRepository _repository;
  StreamSubscription? _scanSubscription;
  DocumentData? documentData;
  bool isScanning = false;
  String? error;
  bool _processing = false;

  DocumentScannerController(this._repository);

  void startScanning() {
    isScanning = true;
    error = null;
    notifyListeners();

    _scanSubscription = _repository
        .startScanning()
        .where((result) => result.confidence > 0.8)
        .asyncMap((result) => Future.delayed(Duration(seconds: 1), () => result))
        .listen(
          _processFrame,
          onError: _handleError,
        );
  }

  Future<void> _processFrame(ScanResult frame) async {
    try {
      final result = await _repository.processDocument(frame.image);
      if (result != null) {
        documentData = result;
        notifyListeners();
      }
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(dynamic error) {
    this.error = error.toString();
    notifyListeners();
  }

  void stopScanning() {
    _scanSubscription?.cancel();
    _repository.stopScanning();
    isScanning = false;
    notifyListeners();
  }

  Future<void> processImage(File image) async {
    if (_processing) return;
    
    try {
      _processing = true;
      final result = await _repository.processDocument(image.path);
      documentData = result;
      error = null;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    } finally {
      _processing = false;
    }
  }

  @override
  void dispose() {
    stopScanning();
    super.dispose();
  }
} 