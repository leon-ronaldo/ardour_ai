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

  //module variables
  late SpeechRecognitionEngine recognitionModule;
  late ConversationGenerator conversationGenerator;

  final String callWord = 'gemini';

  //stream variables
  StreamController recognizedDialogueStream = StreamController<Map>.broadcast();
  StreamController recognizerControlStream = StreamController<Map>.broadcast();
  StreamController conversationGeneratorControlStream =
      StreamController<Map>.broadcast();
  StreamController statusStream = StreamController<dynamic>.broadcast();

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
    recognitionModule = SpeechRecognitionEngine();
    conversationGenerator = ConversationGenerator();
    await recognitionModule.initEngine();
    await Future.delayed(const Duration(milliseconds: 1500),
        () => recognitionModule.startListening());
  }

  @override
  void onClose() {
    super.onClose();
    recognizedDialogueStream.close();
    recognizerControlStream.close();
    conversationGeneratorControlStream.close();
    statusStream.close();
  }
}
