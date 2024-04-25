import 'package:ardour_ai/app/modules/home/controllers/home_controller.dart';
import 'package:ardour_ai/main.dart';
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
  late MainController mainController;

  //flags

  TextToSpeechEngine() {
    speechEngine = FlutterTts();
    mainController = Get.find<MainController>();
    initSpeechEngine();
  }

  void initSpeechEngine() async {
    speechEngine.setLanguage("en-US");
    speechEngine.setPitch(2);
    speechEngine.setSpeechRate(0.8);

    speechEngine.setCompletionHandler(() {
      print('hey worked');
      mainController.statusStream.add('stoppedSpeaking');
    });

    speechEngine.setCancelHandler(() {
      print('heyoo worked');
      mainController.statusStream.add('stoppedSpeaking');
    });
  }

  Future<bool> speak(String dialogue) async {
    mainController.statusStream.add('speaking');
    mainController.messagesStreamController.add({
      'profile': 'ardour',
      'message': dialogue,
      'time': DateTime.now()
    });
    mainController.update();
    await speechEngine.speak(dialogue);
    return true;
  }

  Future<void> stopSpeaking() async {
    await speechEngine.stop();
  }
}
