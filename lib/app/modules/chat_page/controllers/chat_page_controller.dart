// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, curly_braces_in_flow_control_structures, prefer_if_null_operators

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

  String username = 'ronaldo';

  List<dynamic> messages = [];
  List<dynamic> memories = [];
  List<dynamic> people = [];
  RxList<Widget> chatWidgets = <Widget>[].obs;

  TextEditingController chatTextController = TextEditingController();
  late FlutterSecureStorage secureStorage;
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
    secureStorage = mainController.secureStorage;

    screenHeight = Get.context!.height;
    screenWidth = Get.context!.width;
    final messagePresent = await secureStorage.containsKey(key: 'messages');

    if (messagePresent) {
      final messagesJson = await secureStorage.read(key: 'messages');
      messagesJson == null
          ? messages = []
          : messages = jsonDecode(messagesJson);
      loadMessages();
    }

    final memoriesIsNotNull = await secureStorage.containsKey(key: 'memories');

    if (memoriesIsNotNull) {
      memories =
          jsonDecode(await secureStorage.read(key: 'memories') ?? 'null');
    }

    final peopleIsNotNull = await secureStorage.containsKey(key: 'people');

    if (peopleIsNotNull) {
      people = jsonDecode(await secureStorage.read(key: 'people') ?? 'null');
    }
  }

  @override
  void onReady() {
    super.onReady();

    listenStatus();
    listenMessages();
    scrollToBottom();

    mainController.recognizedDialogueStream.stream.listen((recognition) {
      if (recognition['from'] != null) processMessage(recognition['dialogue']);
    });

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
      if (status == 'generatingResponse')
        chatWidgets.value.add(Container(
            alignment: Alignment.centerLeft,
            width: screenWidth,
            child: ChatGeneratingBubble()));

      if (status == 'responseGenerated')
        chatWidgets.value.remove(chatWidgets.value.last);
    });
  }

  void processMessage(text) async {
    if (text == "" || text == " ") return;

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

    print('what ' + initResponse);

    Map response = {};

    if (initResponse.indexOf('`') == 0)
      response = jsonDecode(initResponse.substring(
          initResponse.indexOf('{'), initResponse.length - 3));
    else
      try {
        response = jsonDecode(initResponse);
        await processContext(response);
      } catch (ex) {
        mainController.messagesStreamController.add({
              'type': 'message',
              'profile': 'ardour',
              'message': 'hmm.....',
              'time': DateTime.now().toIso8601String()
            });
      }
  }

  Future<void> processContext(response) async {
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

    if (response['memory'] != null) {
      memories.add({
        'title': response['memory']['title'],
        'hero': response['memory']['hero'],
        'peopleInvolved':
            response['memory']['peopleInvolved'] ?? 'not mentioned',
        'date': response['memory']['date'] ?? 'not mentioned',
        'impact': response['memory']['impact'] ?? 'not mentioned',
        'location': response['memory']['location'] ?? 'not mentioned'
      });

      secureStorage.write(key: 'memories', value: jsonEncode(memories));

      print('memories: $memories');
    }

    if (response['person'] != null) {
      people.add({
        "name": response['person']['name'],
        "age": response['person']['age'] ?? 'not mentioned',
        "relation": response['person']['relation'] ?? 'not mentioned',
        "bonding": response['person']['bonding'] ?? 'not mentioned',
        "memory": response['person']['memory'] ?? 'not mentioned',
        "remark": response['person']['remark'] ?? 'not mentioned'
      });

      secureStorage.write(key: 'people', value: jsonEncode(people));
    }

    if (response['reminder'] != null) {
      mainController.reminderStreamController.add({
        "title": response['reminder']['title'],
        "dateTime": response['reminder']['dateTime'] ?? DateTime.now().add(const Duration(minutes: 30)).toIso8601String(),
        "reminderTime": response['reminder']['reminderTime'] ?? DateTime.now().add(const Duration(minutes: 60)).toIso8601String(),
        "description": response['reminder']['description'],
        "reminderDialogue": response['reminder']['reminderDialogue'],
        "dialogue": response['reminder']['dialogue']
      });
    }
  }

  String generatePrompt(text) {
    List<dynamic> lastFiveItems =
        messages.length <= 5 ? messages : messages.sublist(messages.length - 5);

    String prompt = """
      today is ${DateTime.now().day} ${DateTime.now().month}, ${DateTime.now().year}
      hey can you help me with something? I have a friend named $username, i am chatting with him right now.

      ${(lastFiveItems.isEmpty) ? 'my friend said this "$text"' : '${formatConversation(lastFiveItems)} \nnow my friend said this' "$text"}

      these are the conversations we had right now. is my friend speaking about the same topic? if not give me a dialogue so that i could start a conversation about something else,
      if not, Just analyze his mood, the context we are speaking, and generate a dialogue to cope up with the topic, or to stop the topic based on my friend's mood.
      i am a funny person who speak like a mad to my friend, if he sounds strange i too sound strange, if he yells at me, yell at him, even crack jokes at him, so let the dialogue be in a funny and not too formal one, so that i will sound naturally me.
      if my friend has asked me to remind me of something (task or reminder), set the reminder field with only the json string with the specified context, and let the dialogue be just affirmative
      generate json string like this.

      {
        type: "text" / "media",
        expression: "extreme" / "average" / "low" ,
        mood: "happy" / "sad" / "surprise",
        dialogue: only the appropriate dialogue that i should speak (short within 2 lines),
        'reaction': a reaction emoji alone (if expression is extreme),
        'reminder': {
          'title': title of the reminder,
          'dateTime': dart date time (Iso8601String only) of the specified deadline,
          'reminderTime': dart date time (Iso8601String only) that reminds user before the deadline (set 30 minutes prior if not mentioned by user),
          'description': a detailed description of what my friend should do,
          'reminderDialogue': a dialogue that i should say to my friend prior to the deadline (funny tone, questioning)
          'dialogue': a dialogue that i should say to remind my friend at the deadline (funny tone, questioning),
        }
        saveMemory: true if my friend spoke about an incident or event in life else false,
        savePerson: true if my friend spoke about any person related to them else false,
        'memory': {
          'title': catchy phrase about the incident,
          'hero': about what my friend is mainly speaking about, 
          'peopleInvolved', list of the people involved (if none set to null),
          'date': date when the incident occured (Iso8601String only if mentioned, else none),
          'impact': 'positive' / 'negative',
          'location': emotional description of the locations mentioned (null if nothing mentioned)
        },
        'person': {
          'name': name of the person (related to my friend),
          'age': age of the person (null if not mentioned),
          'relation': how they are related to user (null if not mentioned), 
          'bonding': a description how my friend is bonded with them (null if not mentioned),
          'memory': a description of any incident or past with the person (null if not mentioned),
          'remark': "positive" / "negative",
        },
      }

      expression is the level of emotion our chat has,
      type must be set to media if the expression is extreme,
      mood contains how i should react to my friend,
      dialogues must be more friendly with apropriate emojis,
      if my friend is saying something about an incident or some ascpect of their personal life, let the dialogue be phrased in a strategic manner to request time for remembering things,
      if my friend is saying something about an person in their personal life, let the dialogue be phrased in a strategic manner to request time for remembering things about that person,
      if my friend had asked a question, teach him with appropriate answer, in a tone how a friend teaches another friend

      no field must be missing, instead you may set it to null
      remember my friend's name is '$username'
      just give me only the json string alone based on these constraints so that i could use it.
    });

    """;

    // prompt +=
    //     "these are the past conversations between me and my friend \n '$text' my friend said this now, create a json map that contains a 'dialogue' field with the exact dialogue that i should speak to my friend in this context, let it be short, include appropriate emojis can i use, and a 'mood' field which has 'happy', 'sad', 'surprise' as how i should react right now, and a 'expression' field which has 'extreme', 'average', 'low' values indicating the level of emotion, give exactly only the json so that i could copy it and use";

    // String prompt = """{
    //     type: "text" / "media",
    //     expression: "extreme" / "average" / "low" ,
    //     mood: "happy" / "sad" / "surprise",
    //     dialogue: the appropriate dialogue i should speak
    //     fetchMemory: true / false
    //   }

    //   this is a json format of the response that should be generated later.
    // """;
    // prompt += 'my friend : $text';
    // prompt += "\ncheck whether this is a query";
    // prompt +=
    //     "\nif it is a query then generate a response that i should speak to my friend, be friendly and funny, informative tone";
    // prompt +=
    //     "\nif not a query then check whether it is something related to my friend's personal aspects, if so generate a dialogue that i should say to my friend that i am remembering the past, add relevant emojis";
    // prompt +=
    //     "\nif it is not related to my friend's personal aspects then understand the topic what is user is speaking";
    // prompt += "\nconsider the following conversation\n";

    // lastFiveItems.forEach((message) {
    //   prompt +=
    //       "${message['profile'] == 'ardour' ? 'me :' : 'friend :'} ${message['message']} \n";
    // });

    // prompt +=
    //     "\nif the topic is related to this conversation then with this conversation in consideration generate a dialogue that i should speak to my friend, add relevant emojis";

    // prompt +=
    //     "\n observe the conversation keenly, watch the dialogues spoken by me, you should never generate a dialogue which is similar to what I already spoke";

    // prompt +=
    //     "\nif the topic is not related to this conversation, try to understand what my friend is trying to speak and generate a dialogue for me to start a conversation with my friend, if they are not willing to speak you could generate a dialogue for me to either convince them to stay or to just leave them (according to my friend's interest), add relevant emojis";

    // prompt +=
    //     "\nafter generating the most accurate dialogue within the specified constraints add the dialogue in the 'dialogue' field of the json. type field must be media if the level of emotion in this situation or chat is extreme. mood field must reflect how i must react to the current situation, fetchMemory must be true only if the conversation is about my friend's personal aspects";

    // prompt +=
    //     "\ngive me only the json text with the generated values so that i could copy and use it.";
    return prompt;
  }

  String formatConversation(messages) {
    String formatted = "";
    messages.forEach((message) {
      String speaker =
          (message['profile'] == 'ardour') ? 'me :' : '$username :';
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
