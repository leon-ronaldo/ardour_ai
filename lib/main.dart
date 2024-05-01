// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:ardour_ai/modules/conversation_generator_core.dart';
import 'package:ardour_ai/modules/speech_recognition_flutter_speech_to_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  // Initialize plugin
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Rx<bool> speechConversationEnabled = false.obs;
  bool isAtBackround = false;
  bool isInsideApp = true;

  Timer? _randomMessageTimer;
  late DateTime lastMessageTime;
  int minimumGapBetweenRandomMessage = 45;
  List messages = [];
  FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  int missingCount = 0;
  String userName = 'Ronaldo';
  Rx<double> humourLevel = 0.7.obs;
  late Timer currentTimeTimer;
  Rx<String> currentTime =
      '${DateTime.now().hour < 10 ? '0${DateTime.now().hour}' : DateTime.now().hour} : ${DateTime.now().minute < 10 ? '0${DateTime.now().minute}' : DateTime.now().minute}'
          .obs;

  //stream variables
  StreamController recognizedDialogueStream = StreamController<Map>.broadcast();
  StreamController recognizerControlStream = StreamController<Map>.broadcast();
  StreamController conversationGeneratorControlStream =
      StreamController<Map>.broadcast();
  StreamController statusStream = StreamController<dynamic>.broadcast();
  StreamController<Map> messagesStreamController =
      StreamController<Map>.broadcast();
  StreamController<Map> reminderStreamController =
      StreamController<Map>.broadcast();
  StreamController timeStream = StreamController<String>.broadcast();

  @override
  void onInit() async {
    super.onInit();

    WidgetsFlutterBinding.ensureInitialized();

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();
    // Android initialization settings
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    // General initialization settings
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Initialize the plugin
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    WidgetsBinding.instance.addObserver(_AppLifecycleObserver());

    updateTime();
    timeStream.stream.listen((status) {
      if (status == 'update') updateTime();
      print('status');
      update();
    });
  }

  @override
  void onReady() async {
    super.onReady();

    recognitionModule = SpeechRecognitionEngine();
    conversationGenerator = ConversationGenerator();
    await recognitionModule.initEngine();

    randomMessageChannel();
    reminderChannel();
  }

  Future<void> reminderChannel() async {
    reminderStreamController.stream.listen((reminder) {
      print('reminder $reminder');

      print(reminder['dateTime'].difference(DateTime.now()).inMinutes);

      Timer(
          Duration(
              minutes:
                  reminder['dateTime'].difference(DateTime.now()).inMinutes),
          () => remind(reminder['reminderDialogue']));
    });
  }

  Future<void> randomMessageChannel() async {
    messagesStreamController.stream.listen((message) {
      messageRandomly();
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(_AppLifecycleObserver());

    recognizedDialogueStream.close();
    recognizerControlStream.close();
    conversationGeneratorControlStream.close();
    statusStream.close();
    messagesStreamController.close();

    super.onClose();
  }

  Future<void> messageRandomly() async {
    final messagePresent = await secureStorage.containsKey(key: 'messages');

    if (messagePresent) {
      final messagesJson = await secureStorage.read(key: 'messages');
      messagesJson == null
          ? messages = []
          : messages = jsonDecode(messagesJson);
    }

    List<dynamic> lastFiveItems =
        messages.length <= 3 ? messages : messages.sublist(messages.length - 3);

    bool lastThreeIsArdour = false;

    print('last five : ${lastFiveItems}');

    for (var message in lastFiveItems) {
      if (!(message['isRandomMessage'] ?? false)) {
        lastThreeIsArdour = false;
        break;
      } else
        lastThreeIsArdour = true;
    }

    if (_randomMessageTimer != null && _randomMessageTimer!.isActive) {
      // If a timer is already active, cancel it before scheduling a new one
      _randomMessageTimer!.cancel();
    }

    final missingMessages = [
      [
        'Ronaldooo!!! Where are you my friend??',
        'assets/gifs/missing/missing3.gif'
      ],
      ['Dont you wanna talk with me?? 😢', 'assets/gifs/missing/missing1.gif'],
      ['I miss you 😭', 'assets/gifs/missing/missing2.gif'],
      ['Are you angry on me friend ?? 🥺', 'assets/gifs/missing/missing4.gif']
    ];

    final messageAfterMinutes = Random().nextInt(60);

    print(
        'will be messaged after : ${messageAfterMinutes + minimumGapBetweenRandomMessage}');

    _randomMessageTimer =
        Timer(Duration(seconds: minimumGapBetweenRandomMessage), () async {
      String response =
          !lastThreeIsArdour ? generateRandomMessage() : 'Sent a gif';

      !lastThreeIsArdour
          ? messagesStreamController.add({
              'profile': 'ardour',
              'message': response,
              'time': DateTime.now().toIso8601String(),
              'isRandomMessage': true
            })
          : messagesStreamController.add({
              'type': "media",
              'profile': 'ardour',
              'mediaPath': missingMessages.elementAt(missingCount)[1],
              'message': missingMessages.elementAt(missingCount)[0],
              'time': DateTime.now().toIso8601String(),
              'isRandomMessage': true
            });

      isAtBackround
          ? _showNotification(0, response, 'chat_messages', 'Chat messages',
              'Channel for chat messages')
          : null;
      (missingCount == 3) ? missingCount = 0 : missingCount++;
    });
  }

  String generateRandomMessage() {
    List<Function> functions = [
      () async {
        //random message based on generated scenario
        return await conversationGenerator.geminiInteraction.getResponse(
            "hey can you do me a favour?? There is a friend named $userName. Now i wanna start a conversation with them. Can you create a general random scenario that i am in and generate an message only to send to my friend");
      },
      () async {
        //random message based on random calls
        return await conversationGenerator.geminiInteraction.getResponse(
            "i want to text my friend who's name is 'ronaldo', how shall i start, give me only the exact dialogue to be spoken, what emoji can i use? dont put any annotations as i am going to copy and paste the message");
      },
    ];

    return functions[Random().nextInt(functions.length)]();
  }

  Future<void> _showNotification(notificationId, notification, channelId,
      channelName, channelDescription) async {
    var androidDetails = AndroidNotificationDetails(channelId, channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        vibrationPattern: Int64List.fromList(
            [0, 1000, 500, 1000]), // Example vibration pattern
        playSound: true,
        enableVibration: true);

    var platformChannelSpecifics = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
        notificationId, // Notification ID
        'Ardourika : Ardour Ai', // Notification title
        notification, // Notification body
        platformChannelSpecifics,
        payload: 'custom_sound');
  }

  Future<void> remind(dialogue) async {
    _showNotification(1, 'Heyyy $userName you have some reminder', 'reminder',
        'Reminder', 'Channel for reminders');
    conversationGenerator.speechEngine.speak('Hey $userName!!');
    await Future.delayed(const Duration(seconds: 10));
    conversationGenerator.speechEngine.speak(dialogue);
    await Future.delayed(const Duration(seconds: 10));
    conversationGenerator.speechEngine.speak('Heyyyyyy!!!');
    _showNotification(
        1, dialogue, 'reminder', 'Reminder', 'Channel for reminders');
  }

  void updateTime() {
    currentTimeTimer = Timer(const Duration(minutes: 1), () {
      currentTime.value =
          '${DateTime.now().hour < 10 ? '0${DateTime.now().hour}' : DateTime.now().hour} : ${DateTime.now().minute < 10 ? '0${DateTime.now().minute}' : DateTime.now().minute}';
      timeStream.add('update');
    });
  }
}

class _AppLifecycleObserver with WidgetsBindingObserver {
  late MainController mainController;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    mainController = Get.find<MainController>();

    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      mainController.isAtBackround = true;
      print('App is in the background');
    } else if (state == AppLifecycleState.resumed) {
      mainController.isAtBackround = false;
      print('App is in the foreground');
    }
  }
}
