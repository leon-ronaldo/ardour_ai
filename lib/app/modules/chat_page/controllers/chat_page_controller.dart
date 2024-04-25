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
  bool speechConversationEnabled = false;

  RxList<Widget> chatWidgets = <Widget>[].obs;
  TextEditingController chatTextController = TextEditingController();

  //controllers
  late MainController mainController;

  @override
  void onInit() async {
    super.onInit();

    screenHeight = Get.context!.height;
    screenWidth = Get.context!.width;
  }

  @override
  void onReady() {
    super.onReady();
    mainController = Get.find<MainController>();

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

  @override
  void onClose() {
    super.onClose();
  }

  void processMessage(text) async {
    mainController.messagesStreamController
        .add({'profile': 'user', 'message': text, 'time': DateTime.now()});
    mainController.messagesStreamController.add({
      'profile': 'ardour',
      'message': await mainController.conversationGenerator.geminiInteraction
          .getResponse(mainController
              .conversationGenerator.actions['answering']!['prompt'](text)),
      'time': DateTime.now()
    });
  }
}
