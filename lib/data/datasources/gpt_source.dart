import '../../domain/entities/document_data.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GPTSource {
  final String apiKey;
  
  GPTSource({required this.apiKey});

  Future<DocumentData?> processDocument(String image) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4-vision-preview',
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': '''Analiza esta imagen y extrae:
                    - Tipo de documento
                    - Nombre completo
                    - Número de documento
                    - Fecha de nacimiento
                    - Fecha de vencimiento
                    Responde en JSON.'''
                },
                {
                  'type': 'image_url',
                  'image_url': {'url': image}
                }
              ]
            }
          ]
        }),
      );

      final data = jsonDecode(response.body);
      return _parseGPTResponse(data);
    } catch (e) {
      print('Error en GPT: $e');
      return null;
    }
  }

  DocumentData? _parseGPTResponse(Map<String, dynamic> response) {
    try {
      final content = response['choices'][0]['message']['content'];
      final data = jsonDecode(content);
      
      return DocumentData(
        documentType: data['documentType'],
        fullName: data['fullName'],
        documentNumber: data['documentNumber'],
        birthDate: DateTime.tryParse(data['birthDate'] ?? ''),
        expiryDate: DateTime.tryParse(data['expiryDate'] ?? ''),
      );
    } catch (e) {
      print('Error parseando respuesta: $e');
      return null;
    }
  }
} 