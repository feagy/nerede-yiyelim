import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AISummaryService {
  AISummaryService._(this.baseUrl);
  static AISummaryService? _instance;
  final String baseUrl;

  factory AISummaryService() {
    final baseUrl = dotenv.env['LLM_URL'];

    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception('LLM_URL not found in .env');
    }

    return _instance ??= AISummaryService._(baseUrl);
  }

  Future<String> generateSummary(List<String> reviews, String model) async {
    final uri = Uri.parse(baseUrl);

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'reviews': reviews, 'model': model}),
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final summary = decoded['summary'] as String? ?? '';
    return summary;
  }
}
