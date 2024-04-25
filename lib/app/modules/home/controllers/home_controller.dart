import 'dart:async';
import 'package:ardour_ai/modules/conversation_generator_core.dart';
import 'package:ardour_ai/modules/speech_recognition_flutter_speech_to_text.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  //widget variables
  double screenHeight = 0, screenWidth = 0;

  Rx<String> geminiDialogue = ''.obs;
  Rx<String> userDialogue = ''.obs;
  Rx<String> responseGenerated = ''.obs;
  

  //recognizedDialogueStream map structure
  // {
  //   'dialogue' : recognizedWords,
  //   'confidenceLevel' : confidenceLevel,
  //   'isCallPhrase' : boolean
  // }

  //recognizerControlStream map structure
  // {
  //   'action' : command,
  // }

  @override
  void onInit() {
    super.onInit();

    screenHeight = Get.context!.height;
    screenWidth = Get.context!.width;
  }

  @override
  void onReady() async {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
