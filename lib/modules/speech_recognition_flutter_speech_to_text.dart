// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';

import 'package:ardour_ai/app/modules/home/controllers/home_controller.dart';
import 'package:get/get.dart';
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
  bool isSpeaking = false;
  bool listeningWhileSpeaking = false;

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

        if (status == 'notListening' && listenForQuery)
          homeController.statusStream.add('no query');
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

  Future<void> listenWhileSpeaking() async {
    print('===================listenWhileSpeaking========================');
    await recognitionEngine.listen(
        onResult: (result) {
          print('from listen while query : ${result.recognizedWords}');
          if (result.recognizedWords
              .toLowerCase()
              .split(' ')
              .contains(homeController.callWord)) {
            homeController.conversationGeneratorControlStream
                .add({'action': 'stopSpeakingAndListenQuery'});
            'listen while query : ${result.recognizedWords}';
            homeController.update();
          }
        },
        listenFor: const Duration(seconds: 3),
        localeId: localeId,
        listenOptions: SpeechListenOptions(
            sampleRate: 16000,
            partialResults: true,
            listenMode: ListenMode.dictation,
            cancelOnError: false));
    print('===================xxlistenWhileSpeakingxx========================');
  }

  Future<void> stopListening() async {
    await recognitionEngine.stop();
    print('stopped');
  }

  //stream functions

  void sendRecognitionResult(dynamic result, bool isCallPhrase) {
    if (isCallPhrase)
      result is SpeechRecognitionResult
          ? homeController.recognizedDialogueStream.add({
              'dialogue': result.recognizedWords,
              'confidenceLevel': result.confidence,
              'isCallPhrase': isCallPhrase,
              'isQuery': false,
            })
          : homeController.recognizedDialogueStream.add({
              'dialogue': result,
              'confidenceLevel': .65,
              'isCallPhrase': isCallPhrase,
              'isQuery': false,
            });
    else
      result is SpeechRecognitionResult
          ? homeController.recognizedDialogueStream.add({
              'dialogue': result.recognizedWords,
              'confidenceLevel': result.confidence,
              'isCallPhrase': isCallPhrase,
              'isQuery': true,
            })
          : homeController.recognizedDialogueStream.add({
              'dialogue': result,
              'confidenceLevel': .65,
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

      //set isSpeaking flag
      if (status == 'speaking') isSpeaking = true;
      if (status == 'stoppedSpeaking') {
        isSpeaking = false;
        listeningWhileSpeaking = false;
      }

      //delay to syncronize
      Timer(const Duration(milliseconds: 500), () async {
        //infinite recognition
        if (!listenForQuery && !listeningWhileSpeaking) if (status ==
            'notRecognizing')
          await Future.delayed(
              const Duration(milliseconds: 500), () => startListening());

        //triggerToStartInfiniteRecognition
        if (status == 'startInfiniteRecognition') {
          listenForQuery = false;
          await Future.delayed(
              const Duration(milliseconds: 500), () => startListening());
        }

        //avail listenWhileSpeaking
        if (isSpeaking && listeningWhileSpeaking) {
          await Future.delayed(
              const Duration(milliseconds: 500), () => listenWhileSpeaking());
        }

        // //no result during listen query
        // if (status == 'no query' && listenForQuery) {
        //   listenForQuery = false;
        //   Timer(const Duration(milliseconds: 800), () => startListening());
        // }

        // //got result during listen query
        // if (status == 'got query') {
        //   listenForQuery = true;
        // }
      });
    });
  }

  Future<void> listenForControl() async {
    print('listening for control');
    homeController.recognizerControlStream.stream.listen((control) async {
      print(control);
      print('listenQuery $listenForQuery');

      if (control['action'] == 'listenForQuery') {
        listenQueryTimer =
            Timer(Duration(milliseconds: control['delayFor']), () {
          listenQuery();
        });
      }

      if (control['action'] == 'startListenWhileSpeaking') {
        Timer(const Duration(milliseconds: 1000), () {
          listeningWhileSpeaking = true;
          listenWhileSpeaking();
        });
      }
    });
  }

  void cancelListenQueryTimer() {
    listenQueryTimer?.cancel();
    listenQueryTimer = null;
  }
}
