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

  TextToSpeechEngine() {
    speechEngine = FlutterTts();
    homeController = Get.find<HomeController>();
    initSpeechEngine();
  }

  void initSpeechEngine() async {
    speechEngine.setLanguage("en-US");
    speechEngine.setPitch(2);
    speechEngine.setSpeechRate(0.8);

    speechEngine.setCompletionHandler(() {
      print('hey worked');
      homeController.statusStream.add('stoppedSpeaking');
    });

    speechEngine.setCancelHandler(() {
      print('heyoo worked');
      homeController.statusStream.add('stoppedSpeaking');
    });
  }

  Future<bool> speak(String dialogue) async {
    homeController.statusStream.add('speaking');
    homeController.geminiDialogue.value = dialogue;
    homeController.update();
    await speechEngine.speak(dialogue);
    return true;
  }

  Future<void> stopSpeaking() async {
    await speechEngine.stop();
  }
}
