import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiInteraction {
  Future<String> getResponse(requestText) async {
    final prompt = {
      "contents": [
        {
          "parts": [
            {"text": requestText}
          ]
        }
      ]
    };

    final body = jsonEncode(prompt);

    final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyAOZmLW1t75VFsI4zF1FHUTAEqavtxqi0U'),
        headers: {'Content-Type': 'application/json'},
        body: body);

    final decodedResponse = jsonDecode(response.body.toString());
    final text =
        decodedResponse['candidates'][0]['content']['parts'][0]['text'];
    return text;
  }
}
