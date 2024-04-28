import 'package:ardour_ai/app/modules/chat_page/controllers/chat_page_controller.dart';
import 'package:ardour_ai/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class ChatAppbar extends GetWidget<ChatPageController> {
  const ChatAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(blurRadius: 5, color: Colors.grey.shade400).scale(5)
          ],
          color: Colors.white,
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30))),
      width: controller.screenWidth,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
      height: controller.screenHeight * .13,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 15),
                child: InkResponse(
                  child: Icon(Icons.arrow_back_sharp),
                ),
              ),
              InkResponse(
                child: CircleAvatar(
                  radius: controller.screenWidth * .07,
                  backgroundImage: AssetImage('assets/images/profile.jpg'),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ardourika',
                      style: const TextStyle(
                        fontFamily: 'antipasto',
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Online',
                      style: TextStyle(
                        fontFamily: 'antipasto',
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          InkResponse(
            onTap: () => controller.settingsIsOpen.value =
                !controller.settingsIsOpen.value,
            child: Icon(Icons.settings),
          )
        ],
      ),
    );
  }
}

class ChatBottomBar extends GetWidget<ChatPageController> {
  const ChatBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: controller.screenHeight * 0.1,
      width: controller.screenWidth,
      color: Colors.grey.shade100,
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
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
                  controller.scrollToBottom();
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

class SettingsWindow extends GetWidget<ChatPageController> {
  const SettingsWindow({super.key});

  Widget _settingButton(text, function) {
    return InkResponse(
      onTap: () => function(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Text(text, style: const TextStyle(fontFamily: 'antipasto'))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Visibility(
        visible: controller.settingsIsOpen.value,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          width: controller.screenWidth * 0.4,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: Colors.grey.shade400, blurRadius: 5).scale(5)
              ],
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.white),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _settingButton('Clear chat', () async {
                controller.chatWidgets.clear();
                controller.messages.clear();
                await controller.secureStorage.delete(key: 'messages');
                await controller.mainController.messagesStreamController.stream
                    .drain();
                controller.update();
              }),
              _settingButton('Ardourika settings', () async {}),
              Row(
                children: [
                  const Text('Speech',
                      style: TextStyle(fontFamily: 'antipasto')),
                  SizedBox(
                    child: CupertinoSwitch(
                      value: controller.speakEnabled.value,
                      onChanged: (value) {
                        controller.speakEnabled.value = value;
                      },
                    ),
                  ),
                ],
              ),
              _settingButton('Preferences', () async {}),
              _settingButton('Memory', () async {})
            ],
          ),
        ),
      ),
    );
  }
}

class UserChatBubble extends GetWidget<ChatPageController> {
  UserChatBubble(
      {super.key,
      required this.message,
      required this.time,
      this.reaction = 'null'});
  String message;
  String time;
  String reaction = 'null';

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.parse(time);
    int hour = dateTime.hour;
    int minute = dateTime.minute;

    return GestureDetector(
        onLongPress: () async {
          await Clipboard.setData(ClipboardData(text: message));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Text copied to clipboard!'),
            ),
          );
        },
        child: Stack(alignment: Alignment.bottomRight, children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 18),
            padding: const EdgeInsets.all(10),
            constraints: BoxConstraints(
              maxWidth: controller.screenWidth * 0.6,
            ),
            decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Text(message,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.normal)),
                ),
                Text('$hour : $minute',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.normal)),
              ],
            ),
          ),
          reaction == 'null' ? Container() : Container(
            margin: const EdgeInsets.only(right: 3, top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(50))),
            child: Text(reaction),
          )
        ]));
  }
}

class ArdourChatBubble extends GetWidget<ChatPageController> {
  const ArdourChatBubble(
      {super.key, required this.message, required this.time});
  final String message;
  final String time;

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.parse(time);
    int hour = dateTime.hour;
    int minute = dateTime.minute;

    return GestureDetector(
        onLongPress: () async {
          await Clipboard.setData(ClipboardData(text: message));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Text copied to clipboard!'),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 10),
          constraints: BoxConstraints(maxWidth: controller.screenWidth * 0.6),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  topRight: Radius.circular(20))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 5),
                child: Text(message,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.normal)),
              ),
              Text('$hour : $minute',
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 9,
                      fontWeight: FontWeight.normal)),
            ],
          ),
        ));
  }
}

class ArdourMediaBubble extends GetWidget<ChatPageController> {
  const ArdourMediaBubble(
      {super.key, required this.mediaPath, required this.time});
  final String mediaPath;
  final String time;

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.parse(time);
    int hour = dateTime.hour;
    int minute = dateTime.minute;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: controller.screenWidth * 0.54,
          height: controller.screenHeight * 0.25,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
              border: Border.all(color: Colors.blueGrey, width: 3),
              image: DecorationImage(
                  image: AssetImage(mediaPath), fit: BoxFit.cover)),
          //child: Image.asset('assets/gifs/happy/happy1.gif'),
        ),
        Container(
          margin: const EdgeInsets.only(top: 5),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5))),
          child: Text('$hour : $minute',
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.normal)),
        ),
      ],
    );
  }
}
