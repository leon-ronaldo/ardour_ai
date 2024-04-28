import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:ardour_ai/modules/conversation_generator_core.dart';
import 'package:ardour_ai/modules/speech_recognition_flutter_speech_to_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  int minimumGapBetweenRandomMessage = 15;

  //stream variables
  StreamController recognizedDialogueStream = StreamController<Map>.broadcast();
  StreamController recognizerControlStream = StreamController<Map>.broadcast();
  StreamController conversationGeneratorControlStream =
      StreamController<Map>.broadcast();
  StreamController statusStream = StreamController<dynamic>.broadcast();
  StreamController<Map> messagesStreamController =
      StreamController<Map>.broadcast();

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
  }

  @override
  void onReady() async {
    super.onReady();

    recognitionModule = SpeechRecognitionEngine();
    conversationGenerator = ConversationGenerator();
    await recognitionModule.initEngine();

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
    if (_randomMessageTimer != null && _randomMessageTimer!.isActive) {
      // If a timer is already active, cancel it before scheduling a new one
      _randomMessageTimer!.cancel();
    }
    final messageAfterMinutes = Random().nextInt(60);
    print(
        'will be messaged after : ${messageAfterMinutes + minimumGapBetweenRandomMessage}');
    _randomMessageTimer = Timer(
        Duration(minutes: messageAfterMinutes + minimumGapBetweenRandomMessage),
        () async {
      final response = await conversationGenerator.geminiInteraction.getResponse(
          "i want to text my friend who's name is 'ronaldo', how shall i start, give me only the exact dialogue to be spoken, what emoji can i use? dont put any annotations as i am going to copy and paste the message");

      messagesStreamController.add({
        'profile': 'ardour',
        'message': response,
        'time': DateTime.now().toIso8601String()
      });

      isAtBackround ? _showNotification(response) : null;
    });
  }

  Future<void> _showNotification(notification) async {
    var androidDetails = AndroidNotificationDetails(
        'chat_messages', 'Chat Messages',
        channelDescription: 'Channel for chat notifications',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        vibrationPattern: Int64List.fromList(
            [0, 1000, 500, 1000]), // Example vibration pattern
        playSound: true,
        enableVibration: true);

    var platformChannelSpecifics = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
        1, // Notification ID
        'Ardourika : Ardour Ai', // Notification title
        notification, // Notification body
        platformChannelSpecifics,
        payload: 'custom_sound');
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
