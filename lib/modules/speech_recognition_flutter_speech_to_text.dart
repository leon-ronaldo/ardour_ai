// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';

import 'package:ardour_ai/app/modules/home/controllers/home_controller.dart';
import 'package:ardour_ai/main.dart';
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
  late MainController mainController;

  //setters
  final String localeId = 'en_IN';
  Timer? listenQueryTimer;

  //flags
  bool listenForQuery = false;
  bool isSpeaking = false;
  bool listeningWhileSpeaking = false;
  bool recognizeInfinitely = true;
  bool cameResultFromListenQuery = false;
  bool waitForListening = false;

  SpeechRecognitionEngine() {
    recognitionEngine = SpeechToText();
    mainController = Get.find<MainController>();
    listenForStatus();
    listenForControl();
  }

  //recognition functions

  Future<void> initEngine() async {
    await recognitionEngine.initialize(
      onStatus: (status) {
        if (status == 'listening')
          mainController.statusStream.add('recognizing');

        if (status == 'notListening')
          mainController.statusStream.add('notRecognizing');

        if (status == 'done') mainController.statusStream.add('recognized');
      },
    );
  }

  Future<void> startListening() async {
    print('===========================================');
    await recognitionEngine.listen(
        onResult: (result) {
          if (result.confidence > 0.6) {
            sendRecognitionResult(result, true);
            mainController.update();
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
    bool recognized = false; // Flag to track if recognition result is received
    Timer
        noRecognitionTimer; // Timer to check if no recognition result is received
    noRecognitionTimer = Timer(const Duration(seconds: 60), () {
      if (!recognized) {
        mainController.statusStream.add('no query');
      }
    });
    print('===================Gemini========================');
    await recognitionEngine.listen(
        onResult: (result) {
          print('from query : ${result.recognizedWords}');
          if (result.confidence > 0.6) {
            sendRecognitionResult(result, false);
            mainController.update();
            recognized = true;
            noRecognitionTimer.cancel();
          }
        },
        listenFor: const Duration(seconds: 60),
        localeId: localeId,
        listenOptions: SpeechListenOptions(
            sampleRate: 16000,
            partialResults: false,
            listenMode: ListenMode.dictation,
            cancelOnError: true));
    print('===================xxGeminixx========================');
  }

  Future<void> listenOnce() async {
    await initEngine();
    await recognitionEngine.listen(
        onResult: (result) {
          print('from query : ${result.recognizedWords}');
          if (result.confidence > 0.6) {
            mainController.recognizedDialogueStream.add({
              'dialogue': result.recognizedWords,
              'confidenceLevel': result.confidence,
              'isCallPhrase': false,
              'isQuery': false,
              'from': 'listenOnce'
            });
            mainController.update();
          }
        },
        listenFor: const Duration(seconds: 60),
        localeId: localeId,
        listenOptions: SpeechListenOptions(
            sampleRate: 16000,
            partialResults: false,
            listenMode: ListenMode.dictation,
            cancelOnError: true));
  }

  Future<void> listenWhileSpeaking() async {
    print('===================listenWhileSpeaking========================');
    await recognitionEngine.listen(
        onResult: (result) {
          print('from listen while query : ${result.recognizedWords}');
          if (result.recognizedWords
              .toLowerCase()
              .split(' ')
              .contains(mainController.callWord)) {
            mainController.conversationGeneratorControlStream
                .add({'action': 'stopSpeakingAndListenQuery'});
            'listen while query : ${result.recognizedWords}';
            mainController.update();
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
    if (isCallPhrase) {
      if (result is SpeechRecognitionResult) {
        String dialogue = result.recognizedWords;
        mainController.recognizedDialogueStream.add({
          'dialogue': dialogue,
          'confidenceLevel': result.confidence,
          'isCallPhrase': isCallPhrase,
          'isQuery': false,
        });

        mainController.messagesStreamController.add({
          'profile': 'user',
          'message': dialogue,
          'time': DateTime.now().toIso8601String()
        });
      } else
        mainController.recognizedDialogueStream.add({
          'dialogue': result,
          'confidenceLevel': .65,
          'isCallPhrase': isCallPhrase,
          'isQuery': false,
        });
    } else {
      if (result is SpeechRecognitionResult) {
        mainController.recognizedDialogueStream.add({
          'dialogue': result.recognizedWords,
          'confidenceLevel': result.confidence,
          'isCallPhrase': isCallPhrase,
          'isQuery': true,
        });

        mainController.messagesStreamController.add({
          'profile': 'user',
          'message': result.recognizedWords,
          'time': DateTime.now().toIso8601String()
        });
      } else
        mainController.recognizedDialogueStream.add({
          'dialogue': result,
          'confidenceLevel': .65,
          'isCallPhrase': isCallPhrase,
          'isQuery': true,
        });
    }
  }

  Future<void> listenForStatus() async {
    print('listening for status');
    mainController.statusStream.stream.listen((status) async {
      print(status);

      //set listenForQuery flag
      if (status == 'listenForQuery') {
        listenForQuery = true;
        recognizeInfinitely = false;
      }
      if (status == 'listenedForQuery') listenForQuery = false;

      //set isSpeaking flag
      if (status == 'speaking') isSpeaking = true;
      if (status == 'stoppedSpeaking') {
        isSpeaking = false;
        listeningWhileSpeaking = false;
      }

      if (status == 'waitForListen') {
        waitForListening = true;
      }

      if (status == 'startListenReply') {
        waitForListening = false;
      }

      //set recognizeInfinitely flag
      if (status == 'recognizeInfinitely') {
        recognizeInfinitely = true;
        listenForQuery = false;
        listeningWhileSpeaking = false;
      }
      if (status == 'dontRecognizeInfinitely') recognizeInfinitely = false;

      //delay to syncronize
      Timer(const Duration(milliseconds: 500), () async {
        //infinite recognition
        if (!listenForQuery &&
            !listeningWhileSpeaking &&
            recognizeInfinitely) if (status == 'notRecognizing')
          await Future.delayed(
              const Duration(milliseconds: 500), () => startListening());

        //infinite listen
        if ((mainController.isInsideApp &&
            !waitForListening &&
            mainController.speechConversationEnabled.value)) {
          waitForListening = false;
          await Future.delayed(
              const Duration(milliseconds: 500), () => listenOnce());
        }

        //triggerToStartInfiniteRecognition
        if (status == 'recognizeInfinitely') {
          await Future.delayed(
              const Duration(milliseconds: 500), () => startListening());
        }

        //avail listenWhileSpeaking
        if (isSpeaking && listeningWhileSpeaking) {
          await Future.delayed(
              const Duration(milliseconds: 500), () => listenWhileSpeaking());
        }

        //no query
        if (status == 'no query') {
          recognizeInfinitely = true;
          listenForQuery = false;
          listeningWhileSpeaking = false;

          await Future.delayed(
              const Duration(milliseconds: 500), () => startListening());
        }

        // //got query
        // if (status == 'got query') {
        //   listenForQuery = false;
        // }
      });
    });
  }

  Future<void> listenForControl() async {
    print('listening for control');
    mainController.recognizerControlStream.stream.listen((control) async {
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
          isSpeaking = true;
          recognizeInfinitely = false;
          listenForQuery = false;
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
