import 'dart:convert';
import 'package:http/http.dart' as http;

// Gestisce il recupero di citazioni motivazionali.
class MotivationService {
  static const _endpoint = 'https://zenquotes.io/api/random';

  // Restituisce una citazione motivazionale casuale.
  static Future<String> fetchMotivationalQuote() async {
    final response = await http.get(Uri.parse(_endpoint));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty && data[0]['q'] != null && data[0]['a'] != null) {
        return '"${data[0]['q']}"\n- ${data[0]['a']}';
      }
      return 'Quote not found.';
    } else {
      return 'Error fetching quote.';
    }
  }
} 