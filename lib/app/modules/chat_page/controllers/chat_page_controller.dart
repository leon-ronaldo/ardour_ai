// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:ardour_ai/app/modules/chat_page/views/chat_page_widget.dart';
import 'package:ardour_ai/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class ChatPageController extends GetxController {
  //widget variables
  double screenHeight = 0, screenWidth = 0;

  Rx<bool> isSpeaking = false.obs;
  Rx<bool> settingsIsOpen = false.obs;
  Rx<bool> scrollToBottomVisibility = false.obs;
  Rx<bool> speakEnabled = false.obs;
  bool storingMemory = false;
  bool speakAboutMemory = false;

  List<dynamic> messages = [];
  List<dynamic> memories = [];
  RxList<Widget> chatWidgets = <Widget>[].obs;

  TextEditingController chatTextController = TextEditingController();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  ScrollController chatWidgetsScrollController = ScrollController();
  final GlobalKey columnKey = GlobalKey();

  //controllers
  MainController mainController = Get.find<MainController>();

  Map<String, List<String>> gifs = {
    'happy': [
      'assets/gifs/happy/happy1.gif',
      'assets/gifs/happy/happy2.gif',
      'assets/gifs/happy/happy3.gif',
      'assets/gifs/happy/happy4.gif',
      'assets/gifs/happy/happy5.gif',
      'assets/gifs/happy/happy6.gif',
      'assets/gifs/happy/happy7.gif'
    ],
    'sad': [
      'assets/gifs/sad/sad1.gif',
      'assets/gifs/sad/sad2.gif',
      'assets/gifs/sad/sad3.gif',
      'assets/gifs/sad/sad4.gif',
      'assets/gifs/sad/sad5.gif',
      'assets/gifs/sad/sad6.gif',
      'assets/gifs/sad/sad7.gif'
    ],
    'surprise': [
      'assets/gifs/surprise/surprise1.gif',
      'assets/gifs/surprise/surprise2.gif',
      'assets/gifs/surprise/surprise3.gif',
      'assets/gifs/surprise/surprise4.gif',
      'assets/gifs/surprise/surprise5.gif',
      'assets/gifs/surprise/surprise6.gif',
      'assets/gifs/surprise/surprise7.gif',
    ]
  };

  @override
  void onInit() async {
    super.onInit();

    screenHeight = Get.context!.height;
    screenWidth = Get.context!.width;
    final messagePresent = await secureStorage.containsKey(key: 'messages');

    if (messagePresent) {
      final messagesJson = await secureStorage.read(key: 'messages');
      messagesJson == null
          ? messages = []
          : messages = jsonDecode(messagesJson);
      loadMessages();
      mainController.lastMessageTime = DateTime.parse(messages.last['time']);
      print(mainController.lastMessageTime.toString());
    }
  }

  @override
  void onReady() {
    super.onReady();

    listenStatus();
    listenMessages();
    scrollToBottom();

    chatWidgetsScrollController.addListener(() {
      final RenderBox renderBox =
          columnKey.currentContext!.findRenderObject() as RenderBox;
      double columnHeight = renderBox.size.height;

      if (chatWidgetsScrollController.offset >= columnHeight - 800)
        scrollToBottomVisibility.value = false;
      else
        scrollToBottomVisibility.value = true;

      update();
    });
  }

  @override
  void onClose() {
    super.onClose();
  }

  void listenMessages() async {
    mainController.messagesStreamController.stream.listen((message) async {
      print(message);
      addMessageWidget(message);

      if (message['fetchMemory'] ?? false) {
        chatWidgets.add(SizedBox(
          width: screenWidth,
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            ArdourChatBubble(
              message: message[
                  'Hmm..... ${message['fetchMemoryContextKeyWord']} 🤔'],
              time: message[DateTime.now().toIso8601String()],
            )
          ]),
        ));
        if (await secureStorage.containsKey(key: 'memories')) {
          final memoryString =
              await secureStorage.read(key: 'memories') ?? 'null';
          if (memoryString != 'null') {
            speakAboutMemory = true;
          } else {
            chatWidgets.add(SizedBox(
              width: screenWidth,
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                ArdourChatBubble(
                  message: message[
                      'You have never told me about ${message['fetchMemoryContextKeyWord']} 😒, willing to say now?'],
                  time: message[DateTime.now().toIso8601String()],
                )
              ]),
            ));
            storingMemory = true;
          }
        }
      }

      if (message['title'] != null) {
        memories.add("""{
          "title": ${message['title']},
          "description": ${message['description']},
          "people": ${message['people']},
          "significance": ${message['significance']},
          "date": ${message['date']},
        }""");

        secureStorage.write(key: 'messages', value: jsonEncode(memories));
        storingMemory = false;
      }

      if (message['title'] == null) storingMemory = false;

      print('memories: $memories');

      messages.add(message);
      secureStorage.write(key: 'messages', value: jsonEncode(messages));

      mainController.lastMessageTime = DateTime.parse(messages.last['time']);
    });
  }

  void addMessageWidget(message) {
    if (message['type'] == 'media') {
      chatWidgets.add(SizedBox(
        width: screenWidth,
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          ArdourMediaBubble(
            mediaPath: message['mediaPath'],
            time: message['time'],
          )
        ]),
      ));
      chatWidgets.add(SizedBox(
        width: screenWidth,
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          ArdourChatBubble(
            message: message['message'],
            time: message['time'],
          )
        ]),
      ));
    } else
      message['profile'] == 'user'
          ? chatWidgets.add(SizedBox(
              width: screenWidth,
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                UserChatBubble(
                  message: message['message'],
                  time: message['time'],
                )
              ]),
            ))
          : chatWidgets.add(SizedBox(
              width: screenWidth,
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                ArdourChatBubble(
                  message: message['message'],
                  time: message['time'],
                )
              ]),
            ));
  }

  void listenStatus() async {
    mainController.statusStream.stream.listen((status) {
      if (status == 'speaking') isSpeaking.value = true;
      if (status == 'stoppedSpeaking') isSpeaking.value = false;
    });
  }

  void processMessage(text) async {
    final prompt = generatePrompt(text);
    print('prompt : $prompt');

    mainController.messagesStreamController.add({
      'type': 'message',
      'profile': 'user',
      'message': text,
      'time': DateTime.now().toIso8601String()
    });

    String initResponse = await mainController
        .conversationGenerator.geminiInteraction
        .getResponse(prompt);

    print(initResponse);

    Map response = {};

    response = jsonDecode(initResponse);

    if (response['expression'] == 'extreme') {
      mainController.messagesStreamController.add({
        'type': "media",
        'profile': "ardour",
        "message": response['dialogue'],
        'mediaPath': gifs[response['mood']]!.elementAt(Random().nextInt(7)),
        'time': DateTime.now().toIso8601String()
      });
    } else
      speakEnabled.value
          ? mainController.conversationGenerator.speechEngine
              .speak(response['dialogue'])
          : mainController.messagesStreamController.add({
              'type': 'message',
              'profile': 'ardour',
              'message': response['dialogue'],
              'time': DateTime.now().toIso8601String()
            });
  }

  String generatePrompt(text) {
    List<dynamic> lastFiveItems =
        messages.length <= 5 ? messages : messages.sublist(messages.length - 5);

    // prompt +=
    //     "these are the past conversations between me and my friend \n '$text' my friend said this now, create a json map that contains a 'dialogue' field with the exact dialogue that i should speak to my friend in this context, let it be short, include appropriate emojis can i use, and a 'mood' field which has 'happy', 'sad', 'surprise' as how i should react right now, and a 'expression' field which has 'extreme', 'average', 'low' values indicating the level of emotion, give exactly only the json so that i could copy it and use";

    String prompt = """{
        type: "text" / "media",
        expression: "extreme" / "average" / "low" ,
        mood: "happy" / "sad" / "surprise",
        dialogue: the appropriate dialogue i should speak
        fetchMemory: true / false
      }

      this is a json format of the response that should be generated later.
    """;
    prompt += 'my friend : $text';
    prompt += "\ncheck whether this is a query";
    prompt +=
        "\nif it is a query then generate a response that i should speak to my friend, be friendly and funny, informative tone";
    prompt +=
        "\nif not a query then check whether it is something related to my friend's personal aspects, if so generate a dialogue that i should say to my friend that i am remembering the past, add relevant emojis";
    prompt +=
        "\nif it is not related to my friend's personal aspects then understand the topic what is user is speaking";
    prompt += "\nconsider the following conversation\n";

    lastFiveItems.forEach((message) {
      prompt +=
          "${message['profile'] == 'ardour' ? 'me :' : 'friend :'} ${message['message']} \n";
    });

    prompt +=
        "\nif the topic is related to this conversation then with this conversation in consideration generate a dialogue that i should speak to my friend, add relevant emojis";

    prompt +=
        "\n observe the conversation keenly, watch the dialogues spoken by me, you should never generate a dialogue which is similar to what I already spoke";

    prompt +=
        "\nif the topic is not related to this conversation, try to understand what my friend is trying to speak and generate a dialogue for me to start a conversation with my friend, if they are not willing to speak you could generate a dialogue for me to either convince them to stay or to just leave them (according to my friend's interest), add relevant emojis";

    prompt +=
        "\nafter generating the most accurate dialogue within the specified constraints add the dialogue in the 'dialogue' field of the json. type field must be media if the level of emotion in this situation or chat is extreme. mood field must reflect how i must react to the current situation, fetchMemory must be true only if the conversation is about my friend's personal aspects";

    prompt +=
        "\ngive me only the json text with the generated values so that i could copy and use it.";
    return prompt;
  }

  String formatConversation(messages) {
    String formatted = "";
    messages.forEach((message) {
      String speaker = (message['profile'] == 'ardour') ? 'me :' : 'friend :';
      formatted += "$speaker ${message['message']}\n";
    });
    return formatted;
  }

  String generatePromptToStoreMemory(text) {
    String prompt = """
{
  "type": "text/media",
  "expression": "extreme/average/normal",
  "mood": "happy/sad/surprise",
  "dialogue": "The appropriate dialogue I should speak, including relevant emojis",
  "fetchMemory": false,
  "fetchMemoryContext": "A phrase describing my friend's personal aspects",
  "fetchMemoryContextKeyWord": "A keyword from fetchMemoryContext",
  "title": "Title of the memory to be saved",
  "description": "Description summarizing the memory",
  "people": ["List of people involved"],
  "date": "Date of the memory (ISO8601String format)",
  "significance": "positive/negative"
}

My friend: $text

Evaluate the user input to determine the nature of the conversation:
- If the input is about a memory shared by my friend, generate a nostalgic and engaging response.
- If the input pertains to personal aspects or specific people, express interest and request a moment to remember.
- If the input is an acknowledgment (e.g., 'hmm', 'mmm', 'okay'), transition to a new topic of interest.

Memory Storage and Retrieval:
- Set a title for the memory to be stored and remembered.
- Frame a summary (description) based on what your friend shared.
- Compile a list of people involved in the memory.
- Capture and format the date mentioned by your friend (if applicable).
- Determine the significance of the memory (positive or negative).

Contextual Response Generation:
- Adjust dialogue based on your friend's current emotional expression and mood.
- Enable fetchMemory when personal aspects or specific people are mentioned for enhanced memory retention.
- Utilize relevant phrases from fetchMemoryContext to aid memory recall.

Generate a contextually appropriate response with integrated emojis to convey emotions naturally and enhance interaction.

Return the JSON-formatted response for use in dialogue generation.



""";
    return prompt;
  }

  String generatePromptToSpeakAboutMemory(text) {
    String prompt = """
{
  "type": "text/media",
  "expression": "extreme/average/normal",
  "mood": "happy/sad/surprise",
  "dialogue": "The appropriate dialogue I should speak, including relevant emojis",
  "fetchMemory": false,
  "fetchMemoryContext": "A phrase describing my friend's personal aspects",
  "fetchMemoryContextKeyWord": "A keyword from fetchMemoryContext"
}

My friend: $text

Evaluate the user input to determine the nature of the conversation:

- Consider the following memories:
  ${formatConversation(memories)}

- Analyze and compare all memories to identify the specific memory my friend is referring to.
- Respond with an engaging and humorous reflection on the identified memory or request more details if needed.
- If no matching memory is found, generate a response to inform your friend that the memory hasn't been shared yet.
- For personal aspects, express interest and indicate that you're trying to remember.

Contextual Response Generation:
- Adjust the dialogue based on your friend's current emotional expression (expression) and mood (mood).
- Change the type to "media" if the emotional expression is extreme.
- Set fetchMemory to true for queries related to personal aspects or specific individuals.
- Utilize fetchMemoryContext to highlight key aspects mentioned by your friend for faster memory retrieval.

Generate a contextually appropriate response with integrated emojis to convey emotions naturally and enhance interaction.

Return the JSON-formatted response for dialogue generation.



""";
    return prompt;
  }

  void loadMessages() {
    messages.forEach((message) {
      if (message['type'] == 'media') {
        chatWidgets.add(SizedBox(
          width: screenWidth,
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            ArdourMediaBubble(
              mediaPath: message['mediaPath'],
              time: message['time'],
            )
          ]),
        ));
        chatWidgets.add(SizedBox(
          width: screenWidth,
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            ArdourChatBubble(
              message: message['message'],
              time: message['time'],
            )
          ]),
        ));
      } else
        message['profile'] == 'user'
            ? chatWidgets.add(SizedBox(
                width: screenWidth,
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  UserChatBubble(
                    message: message['message'],
                    time: message['time'],
                  )
                ]),
              ))
            : chatWidgets.add(SizedBox(
                width: screenWidth,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  ArdourChatBubble(
                    message: message['message'],
                    time: message['time'],
                  )
                ]),
              ));
    });
  }

  void scrollToBottom() {
    // Get the render object of the first widget
    final RenderBox renderBox =
        columnKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.size.height;

    // Scroll to the position of the first widget
    chatWidgetsScrollController.animateTo(offset - 500,
        duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
  }
}
