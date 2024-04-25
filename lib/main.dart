import 'dart:async';

import 'package:ardour_ai/modules/conversation_generator_core.dart';
import 'package:ardour_ai/modules/speech_recognition_flutter_speech_to_text.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

void main() {
  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: BindingsBuilder(() {
        Get.put(MainController());
      }),
    ),
  );
}

class MainController extends GetxController {
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

  //module variables
  late SpeechRecognitionEngine recognitionModule;
  late ConversationGenerator conversationGenerator;

  //variables and setters
  final String callWord = 'gemini';

  //stream variables
  StreamController recognizedDialogueStream = StreamController<Map>.broadcast();
  StreamController recognizerControlStream = StreamController<Map>.broadcast();
  StreamController conversationGeneratorControlStream =
      StreamController<Map>.broadcast();
  StreamController statusStream = StreamController<dynamic>.broadcast();
  StreamController<Map> messagesStreamController =
      StreamController<Map>.broadcast();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() async {
    super.onReady();

    recognitionModule = SpeechRecognitionEngine();
    conversationGenerator = ConversationGenerator();
    await recognitionModule.initEngine();
  }

  @override
  void onClose() {
    super.onClose();

    recognizedDialogueStream.close();
    recognizerControlStream.close();
    conversationGeneratorControlStream.close();
    statusStream.close();
    messagesStreamController.close();
  }
}
