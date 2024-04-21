// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';

import 'package:ardour_ai/app/modules/home/controllers/home_controller.dart';
import 'package:ardour_ai/modules/speech_to_text_flutterTTS.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

//recognizedDialogueStream map structure
// {
//   'dialogue' : recognizedWords,
//   'confidenceLevel' : confidenceLevel,
//   'isCallPhrase' : boolean
// }

//tip: user Timers instead of delays

class SpeechRecognitionEngine {
  //engines and controllers
  late SpeechToText recognitionEngine;
  late HomeController homeController;

  //setters
  final String localeId = 'en_IN';
  Timer? listenQueryTimer;

  //flags
  bool listenForQuery = false;
  bool spoke = false;

  SpeechRecognitionEngine() {
    recognitionEngine = SpeechToText();
    homeController = Get.find<HomeController>();
    listenForStatus();
    listenForControl();
  }

  //recognition functions

  Future<void> initEngine() async {
    await recognitionEngine.initialize(
      onStatus: (status) {
        if (status == 'listening')
          homeController.statusStream.add('recognizing');

        if (status == 'notListening')
          homeController.statusStream.add('notRecognizing');

        if (status == 'done') homeController.statusStream.add('recognized');
      },
    );
  }

  Future<void> startListening() async {
    print('===========================================');
    await recognitionEngine.listen(
        onResult: (result) {
          if (result.confidence > 0.6) {
            sendRecognitionResult(result, true);
            homeController.userDialogue.value = result.recognizedWords;
            homeController.update();
          }
        },
        listenFor: const Duration(seconds: 60),
        localeId: localeId,
        listenOptions: SpeechListenOptions(
            partialResults: false,
            listenMode: ListenMode.dictation,
            cancelOnError: true));
    print('==================xxx======================');
  }

  Future<void> listenQuery() async {
    await initEngine();
    print('===================Gemini========================');
    await recognitionEngine.listen(
        onResult: (result) {
          print('from query : ${result.recognizedWords}');
          if (result.confidence > 0.6) {
            sendRecognitionResult(result, false);
            homeController.userDialogue.value =
                'from query : ${result.recognizedWords}';
            homeController.update();
          }
        },
        listenFor: const Duration(seconds: 60),
        localeId: localeId,
        listenOptions: SpeechListenOptions(
            partialResults: false,
            listenMode: ListenMode.dictation,
            cancelOnError: true));
    print('===================xxGeminixx========================');
  }

  Future<void> stopListening() async {
    await recognitionEngine.stop();
    print('stopped');
  }

  //stream functions

  void sendRecognitionResult(
      SpeechRecognitionResult result, bool isCallPhrase) {
    if (isCallPhrase)
      homeController.recognizedDialogueStream.add({
        'dialogue': result.recognizedWords,
        'confidenceLevel': result.confidence,
        'isCallPhrase': isCallPhrase,
        'isQuery': false,
      });
    else
      homeController.recognizedDialogueStream.add({
        'dialogue': result.recognizedWords,
        'confidenceLevel': result.confidence,
        'isCallPhrase': isCallPhrase,
        'isQuery': true,
      });
  }

  Future<void> listenForStatus() async {
    print('listening for status');
    homeController.statusStream.stream.listen((status) async {
      print(status);

      //set listenForQuery flag
      if (status == 'listenForQuery') listenForQuery = true;
      if (status == 'listenedForQuery') listenForQuery = false;

      //set spoke flag
      if (status == 'speaking') spoke = false;
      if (status == 'spoke') spoke = true;

      //delay to syncronize
      await Future.delayed(const Duration(milliseconds: 500));

      //infinite recognition
      if (!listenForQuery) if (status == 'notRecognizing')
        await Future.delayed(
            const Duration(milliseconds: 500), () => startListening());
      
      //triggerToStartInfiniteRecognition
      if (status == 'startListening')
        await Future.delayed(
            const Duration(milliseconds: 500), () => startListening());
    });
  }

  Future<void> listenForControl() async {
    print('listening for control');
    homeController.recognizerControlStream.stream.listen((control) async {
      print(control);
      print('listenQuery $listenForQuery');
      if (control['action'] == 'makeListenForQuery') {
        homeController.conversationGeneratorControlStream
            .add({'action': 'speak', 'context': control['context']});
      }
      if (control['action'] == 'listenForQuery') {
        listenQueryTimer =
            Timer(Duration(milliseconds: control['delayFor']), () {
          listenQuery();
        });
      }
    });
  }

  void cancelListenQueryTimer() {
    listenQueryTimer?.cancel();
    listenQueryTimer = null;
  }
}
