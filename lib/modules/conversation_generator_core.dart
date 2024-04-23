// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:ffi';

import 'package:ardour_ai/app/modules/home/controllers/home_controller.dart';
import 'package:ardour_ai/modules/geminiInteraction_geminiAPI.dart';
import 'package:ardour_ai/modules/speech_to_text_flutterTTS.dart';
import 'package:get/get.dart';

class ConversationGenerator {
  //engines and controllers
  late TextToSpeechEngine speechEngine;
  late HomeController homeController;
  late GeminiInteraction geminiInteraction;

  //variables and setters
  final String callWord = 'gemini';
  Completer<void>? _speechCompleter;

  //flags
  bool isSpeaking = false;

  //maps
  Map<String, Map> moodsAndActions = {
        'happy': {
          'prompt': (userDialogue) {
            return "user is happy right now, they said '$userDialogue'. generate one dialogue to speak to the user regarding this.";
          }
        },
        'angry': {
          'prompt': (userDialogue) {
            return "user is angry right now, they said '$userDialogue'. generate one dialogue to calm down the user regarding this situation, remember dont be annoying.";
          }
        },
        'sad': {
          'prompt': (userDialogue) {
            return "user is sad right now, they said '$userDialogue'. generate one dialogue to motivate the user";
          }
        },
        'excited': {
          'prompt': (userDialogue) {
            return "user is excited right now, they said '$userDialogue'. generate one dialogue to celebrate with the user";
          }
        },
        'surprised': {
          'prompt': (userDialogue) {
            return "user is surprised right now. generate one dialogue to ask the user what it is about, pretend to be their friend";
          }
        },
        'neutral': {
          'prompt': (userAction) {
            return "user is currently $userAction. generate one dialogue to ask the user how is the day, dont be annoying";
          }
        }
      },
      actions = {
        'salutation': {
          'prompt': (userGreeting) {
            return "user has said $userGreeting, generate a dialogue to greet them back";
          }
        },
        'responding': {
          'prompt': (userQuestion) {
            return "user had asked you about $userQuestion, generate a dialogue to reply them back, be friendly";
          }
        },
        'answering': {
          'prompt': (userRequest) {
            return "$userRequest?, answer me in one short paragraph, be informative";
          }
        },
        'operations': {'actions': () {}}
      };

  ConversationGenerator() {
    speechEngine = TextToSpeechEngine();
    homeController = Get.find<HomeController>();
    geminiInteraction = GeminiInteraction();
    listenForStatus();
    listenForRecognizedText();
    listenForConversationControls();
  }

  //stream listen functions
  Future<void> listenForRecognizedText() async {
    print('listening for recognized texts');
    homeController.recognizedDialogueStream.stream.listen((userDialogue) async {
      print(userDialogue);
      await detectSpeechContext(userDialogue);
    });
  }

  Future<void> listenForConversationControls() async {
    print('listening for conversationGenerator controls');
    homeController.conversationGeneratorControlStream.stream
        .listen((conversationConrol) async {
      if (conversationConrol['action'] == 'speak') {}
      if (conversationConrol['action'] == 'stopSpeakingAndListenQuery')
        stopSpeakingAndListenForQuery();
    });
  }

  Future<void> listenForStatus() async {
    print('listening for status (conversationGenerator)');
    homeController.statusStream.stream.listen((status) {
      print('status (conversationGenerator): $status');

      if (status == 'speaking') isSpeaking = true;
      if (status == 'stoppedSpeaking') isSpeaking = false;
    });
  }

  //stream update functions
  void setStatus(status) {
    homeController.statusStream.add(status);
  }

  void setRecognitionControl(control) {
    homeController.recognizerControlStream.add(control);
  }

  //detect speech context
  Future<void> detectSpeechContext(Map request) async {
    if (request.isNotEmpty) {
      List<String> tokenizedWords =
          request['dialogue'].toLowerCase().split(' ');

      //user said to stop speaking, stop speaking immediately
      if (tokenizedWords.contains('stop') &&
          tokenizedWords.contains('speaking')) {
        await stopSpeakingAndContinueInfiniteRecognition();
      }

      //if ardour is triggered and if something is being spoken, stop speaking immediately
      if (request['isCallPhrase'] &&
          request['dialogue'].toLowerCase() == 'gemini' &&
          isSpeaking) {
        await stopSpeakingAndListenForQuery();
      }

      //if it is not a trigger for ardour and it is a query
      if (!request['isCallPhrase'] && request['isQuery']) {
        print('response generation');

        //if not confident enough come again
        if (request['confidenceLevel'] < 0.6) {
          // await sendMessage({
          //   'actions': ['stopListen'],
          //   'triggerActive': false,
          //   'isRunning': true
          // });

          speechEngine.speak('Sorry that wasnt clear, can you come again?');

          // await sendMessage({
          //   'actions': ['listenQuery'],
          //   'triggerActive': false,
          //   'isRunning': true
          // });
        }

        //if clear proceed to response generation
        else {
          String dialogue = await geminiInteraction.getResponse(
              actions['answering']!['prompt'](request['dialogue']));

          homeController.responseGenerated.value =
              dialogue.split(' ').elementAt(2);
          homeController.update();

          speechEngine.speak(dialogue);

          // debugCheck
          print('im here while speaking');

          Timer(
              const Duration(milliseconds: 1000),
              () => setRecognitionControl({
                    'action': 'startListenWhileSpeaking',
                  }));
        }
      }

      //if ardour is triggered stop continuous recognition and listen query
      //checks if already is called to avoid keyword
      //          appearing in text which could trigger the listening again
      if (request['isCallPhrase'] && tokenizedWords.contains(callWord)) {
        print('inside query');
        await listenForQueryContextWithSpeech();
      }
    }
  }

  //speech context methods
  Future<void> stopSpeakingAndContinueInfiniteRecognition() async {
    await speechEngine.stopSpeaking();
    await waitForSpeechCompletion();
    Timer(const Duration(milliseconds: 800), () => speechEngine.speak('okay!'));
    await waitForSpeechCompletion();
    setStatus('listenedForQuery');
    setStatus('startInfiniteRecognition');
  }

  Future<void> stopSpeakingAndListenForQuery() async {
    print('inside stop speak');
    await speechEngine.stopSpeaking();
      await waitForSpeechCompletion();
    Timer(
        const Duration(milliseconds: 1000), () => speechEngine.speak('what?'));
    await waitForSpeechCompletion();
    Timer(const Duration(milliseconds: 500),
        () => listenForQueryContextWithoutSpeech());
  }

  Future<void> listenForQueryContextWithSpeech() async {
    setStatus('listenForQuery');
    await speechEngine.speak('yes how can I help you?');

    await waitForSpeechCompletion();

    Timer(
        const Duration(milliseconds: 500),
        () =>
            setRecognitionControl({'action': 'listenForQuery', 'delayFor': 0}));
  }

  Future<void> listenForQueryContextWithoutSpeech() async {
    setStatus('listenForQuery');
    Timer(
        const Duration(milliseconds: 1000),
        () =>
            setRecognitionControl({'action': 'listenForQuery', 'delayFor': 0}));
  }

  Future<void> waitForSpeechCompletion() async {
    _speechCompleter = Completer<void>();
    final subscription = homeController.statusStream.stream.listen((event) {
      if (event == 'stoppedSpeaking') {
        _speechCompleter!.complete();
      }
    });

    await _speechCompleter!.future;
    subscription.cancel();
  }
}
