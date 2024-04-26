// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:ardour_ai/app/modules/chat_page/views/chat_page_widget.dart';
import 'package:ardour_ai/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ChatPageController extends GetxController {
  //widget variables
  double screenHeight = 0, screenWidth = 0;

  Rx<bool> isSpeaking = false.obs;

  RxList<Widget> chatWidgets = <Widget>[].obs;
  TextEditingController chatTextController = TextEditingController();

  //controllers
  MainController mainController = Get.find<MainController>();

  @override
  void onInit() async {
    super.onInit();

    screenHeight = Get.context!.height;
    screenWidth = Get.context!.width;
  }

  @override
  void onReady() {
    super.onReady();
    
    listenStatus();
    listenMessages();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void listenMessages() async {
    mainController.messagesStreamController.stream.listen((message) {
      print(message);
      message['profile'] == 'user'
          ? chatWidgets.add(SizedBox(
              width: screenWidth,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [UserChatBubble(message: message['message'])]),
            ))
          : chatWidgets.add(SizedBox(
              width: screenWidth,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [ArdourChatBubble(message: message['message'])]),
            ));
    });
  }

  void listenStatus() async {
    mainController.statusStream.stream.listen((status) {
      if (status == 'speaking') isSpeaking.value = true;
      if (status == 'stoppedSpeaking') isSpeaking.value = false;
    });
  }

  void processMessage(text) async {
    mainController.messagesStreamController
        .add({'profile': 'user', 'message': text, 'time': DateTime.now()});
    mainController.messagesStreamController.add({
      'profile': 'ardour',
      'message': await mainController.conversationGenerator.geminiInteraction
          .getResponse(text),
      'time': DateTime.now()
    });
  }
}
