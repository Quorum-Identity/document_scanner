import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/datasources/gpt_source.dart';
import '../../data/repositories/document_scanner_repository_impl.dart';
import '../../presentation/document_scanner_controller.dart';
import '../domain/entities/document_data.dart';
import 'package:camera/camera.dart';

// Widgets que necesitamos crear
class DocumentCameraView extends StatefulWidget {
  final Function(XFile) onImageCaptured;
  
  const DocumentCameraView({
    Key? key,
    required this.onImageCaptured,
  }) : super(key: key);

  @override
  State<DocumentCameraView> createState() => _DocumentCameraViewState();
}

class _DocumentCameraViewState extends State<DocumentCameraView> {
  CameraController? _cameraController;
  bool _isInitialized = false;
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
        _startScanning();
      }
    } catch (e) {
      print('Error al inicializar la cámara: $e');
    }
  }

  void _startScanning() {
    _scanTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_cameraController?.value.isInitialized ?? false) {
        try {
          final image = await _cameraController!.takePicture();
          widget.onImageCaptured(image);
        } catch (e) {
          print('Error al capturar imagen: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _cameraController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // Vista de la cámara
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _cameraController!.value.previewSize?.width ?? 0,
              height: _cameraController!.value.previewSize?.height ?? 0,
              child: CameraPreview(_cameraController!),
            ),
          ),
        ),
        // Marco guía para el documento
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.width * 0.55, // Proporción ID/pasaporte
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class DocumentDataOverlay extends StatelessWidget {
  final DocumentData data;

  const DocumentDataOverlay({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.black54,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${data.documentType}',
                style: const TextStyle(color: Colors.white)),
            Text('Nombre: ${data.fullName}',
                style: const TextStyle(color: Colors.white)),
            Text('Número: ${data.documentNumber}',
                style: const TextStyle(color: Colors.white)),
            if (data.birthDate != null)
              Text('Nacimiento: ${data.birthDate}',
                  style: const TextStyle(color: Colors.white)),
            if (data.expiryDate != null)
              Text('Vencimiento: ${data.expiryDate}',
                  style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class DocumentScanner extends StatefulWidget {
  final String apiKey;
  
  const DocumentScanner({
    Key? key,
    required this.apiKey,
  }) : super(key: key);

  @override
  State<DocumentScanner> createState() => _DocumentScannerState();
}

class _DocumentScannerState extends State<DocumentScanner> {
  late final DocumentScannerController _controller;

  @override
  void initState() {
    super.initState();
    final repository = DocumentScannerRepositoryImpl(
      gptSource: GPTSource(apiKey: widget.apiKey),
    );
    _controller = DocumentScannerController(repository);
    _controller.startScanning();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        if (_controller.error != null) {
          return Center(child: Text('Error: ${_controller.error}'));
        }

        return Stack(
          children: [
            // Vista de la cámara
            DocumentCameraView(onImageCaptured: (image) {
              _controller.processImage(File(image.path));
            }),
            
            // Overlay con los datos extraídos
            if (_controller.documentData != null)
              DocumentDataOverlay(data: _controller.documentData!),
          ],
        );
      },
    );
  }
} 

