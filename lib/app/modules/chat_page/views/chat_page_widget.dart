import 'package:ardour_ai/app/modules/chat_page/controllers/chat_page_controller.dart';
import 'package:ardour_ai/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class ChatBottomBar extends GetWidget<ChatPageController> {
  const ChatBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: controller.screenHeight * 0.1 + 20,
      width: controller.screenWidth,
      color: Colors.grey.shade100,
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: controller.screenHeight * 0.07,
            width: controller.screenWidth * 0.77,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(color: Colors.grey.shade400, blurRadius: 5).scale(5)
            ]),
            child: TextField(
              controller: controller.chatTextController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  fillColor: Colors.white,
                  hintStyle: const TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.normal),
                  filled: true,
                  hintText: 'Type a message',
                  suffixIcon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    width: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                          () => Visibility(
                            visible: controller.isSpeaking.value,
                            child: InkResponse(
                              onTap: () {
                                controller.mainController.conversationGenerator
                                    .speechEngine
                                    .stopSpeaking();
                              },
                              child: Icon(
                                Icons.speaker_notes_off,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        InkResponse(
                          onTap: () {
                            controller.mainController.speechConversationEnabled
                                    .value =
                                !controller.mainController
                                    .speechConversationEnabled.value;

                            if (controller.mainController
                                .speechConversationEnabled.value) {
                              controller.mainController.recognitionModule
                                  .stopListening();
                              controller.mainController.statusStream
                                  .add('dontRecognizeInfinitely');
                              controller.mainController.recognitionModule
                                  .listenOnce();
                            } else {
                              controller.mainController.statusStream
                                  .add('dontRecognizeInfinitely');
                              controller.mainController
                                  .speechConversationEnabled.value = false;
                            }
                          },
                          child: Obx(
                            () => Icon(
                              controller.mainController
                                      .speechConversationEnabled.value
                                  ? Icons.mic_off
                                  : Icons.mic,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: InkResponse(
                onTap: () {
                  controller.processMessage(controller.chatTextController.text);
                  controller.chatTextController.clear();
                },
                child: Icon(
                  Icons.send,
                  size: 28,
                )),
          )
        ],
      ),
    );
  }
}

class UserChatBubble extends GetWidget<ChatPageController> {
  const UserChatBubble({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(10),
      constraints: BoxConstraints(maxWidth: controller.screenWidth * 0.6),
      decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              topRight: Radius.circular(20))),
      child: Text(message,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.normal)),
    );
  }
}

class ArdourChatBubble extends GetWidget<ChatPageController> {
  const ArdourChatBubble({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 10),
      constraints: BoxConstraints(maxWidth: controller.screenWidth * 0.6),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
              topRight: Radius.circular(20))),
      child: Text(message,
          style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.normal)),
    );
  }
}
