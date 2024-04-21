// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';

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
      if (conversationConrol['action'] == 'speak') {
        if (conversationConrol['context'] == 'query') {
          bool stopped = await speechEngine.speak('yes how can I help you');
          if (stopped) {
            setStatus('spoke');
            Timer(
                const Duration(milliseconds: 500),
                () => setRecognitionControl(
                    {'action': 'listenForQuery', 'delayFor': 1000}));
          }
        }
      }
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
      if (request['dialogue'] == 'stop speaking' && speechEngine.isSpeaking) {
        await stopSpeakingAndContinueInfiniteRecognition();
      }

      //if ardour is triggered and if something is being spoken, stop speaking immediately
      if (request['isCallPhrase'] &&
          tokenizedWords.contains(callWord) &&
          speechEngine.isSpeaking) {
        await stopSpeakingAndListenForQuery();
      }

      //ignore case
      if (request['isCallPhrase'] && !tokenizedWords.contains(callWord)) {}

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
          speechEngine.speak(await geminiInteraction.getResponse(
              actions['answering']!['prompt'](request['dialogue'])));

          // debugCheck
          print('im here while speaking');

          setStatus('listenedForQuery');
          setStatus('startListening');
        }
      }

      //if ardour is triggered stop continuous recognition and listen query
      //checks if already is called to avoid keyword
      //          appearing in text which could trigger the listening again
      if (request['isCallPhrase'] && tokenizedWords.contains(callWord)) {
        print('inside query');
        await listenForQueryContext();
      }
    }
  }

  //speech context methods
  Future<void> stopSpeakingAndContinueInfiniteRecognition() async {
    await speechEngine.stopSpeaking();
    setStatus('listenedForQuery');
    await speechEngine.speak('okay');
  }

  Future<void> stopSpeakingAndListenForQuery() async {
    await speechEngine.stopSpeaking();
    setStatus('listenForQuery');
    speechEngine.speak('what?');
    setRecognitionControl({'action': 'makeListenForQuery'});
  }

  Future<void> listenForQueryContext() async {
    setStatus('listenForQuery');
    Timer(
        const Duration(milliseconds: 500),
        () => setRecognitionControl(
            {'action': 'makeListenForQuery', 'context': 'query'}));
  }
}
