import 'dart:convert';
import 'package:ardour_ai/main.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class GeminiInteraction {
  MainController mainController = Get.find<MainController>();
  Future<String> getResponse(requestText) async {
    mainController.statusStream.add('generatingResponse');
    mainController.generatingText.value = true;
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
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyBHrfMTin4JQkIY9VfC6VAFR1UXug27uok'),
        headers: {'Content-Type': 'application/json'},
        body: body);

    final decodedResponse = jsonDecode(response.body.toString());
    print(decodedResponse);
    String text = '';
    try {
      text = decodedResponse['candidates'][0]['content']['parts'][0]['text'];
    } catch (e) {
      text = """{
        "type": "text",
        "expression": "low" ,
        "mood": "happy",
        "dialogue": "❤️",
        "fetchMemory": false
      }""";
    }

    mainController.generatingText.value = false;
    mainController.statusStream.add('responseGenerated');
    return text;
  }
}

// "reminder": {
// I/flutter (28850):     "title": "Take Medicines",
// I/flutter (28850):     "dateTime": "2023-03-08T20:10:00.000Z",
// I/flutter (28850):     "reminderTime": "2023-03-08T19:40:00.000Z",
// I/flutter (28850):     "description": "Please take your medicines at 8:10 p.m.",
// I/flutter (28850):     "reminderDialogue": "Hey, don't forget to take your medicines in 30 minutes!",
// I/flutter (28850):     "dialogue": "Hey, it's time to take your medicines!"
// I/flutter (28850):   }
