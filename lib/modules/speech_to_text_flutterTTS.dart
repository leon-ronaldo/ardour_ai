import 'package:ardour_ai/app/modules/home/controllers/home_controller.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

// *** NOTE ***
// if targeting android 11 add these before proceding

// <queries>
//   <intent>
//     <action android:name="android.intent.action.TTS_SERVICE" />
//   </intent>
// </queries>

// reference : https://pub.dev/packages/flutter_tts

class TextToSpeechEngine {
  //objects
  late FlutterTts speechEngine;
  late HomeController homeController;

  //flags
  bool isSpeaking = false;

  TextToSpeechEngine() {
    speechEngine = FlutterTts();
    homeController = Get.find<HomeController>();
    initSpeecEngine();
  }

  void initSpeecEngine() async {
    speechEngine.setLanguage("en-US");
    speechEngine.setPitch(2);
    speechEngine.setSpeechRate(0.8);
  }

  Future<bool> speak(String dialogue) async {
    isSpeaking = true;
    homeController.geminiDialogue.value = dialogue;
    homeController.update();
    await speechEngine.speak(dialogue);
    isSpeaking = false;
    return true;
  }

  Future<void> pauseSpeaking() async {
    await speechEngine.pause();
    isSpeaking = false;
  }

  Future<void> stopSpeaking() async {
    await speechEngine.stop();
    isSpeaking = false;
  }
}
