// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:ardour_ai/app/modules/chat_page/views/chat_page_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:get/get.dart';

import '../controllers/chat_page_controller.dart';

class ChatPageView extends GetView<ChatPageController> {
  const ChatPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
      onTap: () => controller.settingsIsOpen.value = false,
      child: Container(
        height: controller.screenHeight,
        width: controller.screenWidth,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: const [
              Color.fromARGB(255, 79, 177, 205),
              Color.fromARGB(255, 124, 129, 197),
              Color.fromARGB(255, 178, 89, 133)
            ])),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            GestureDetector(
              onTap: () => controller.settingsIsOpen.value = false,
              onVerticalDragDown: (onvat) =>
                  controller.settingsIsOpen.value = false,
              child: Container(
                  padding: EdgeInsets.only(
                      left: 25, right: 25, top: controller.screenHeight * 0.13),
                  margin: EdgeInsets.only(
                      bottom: controller.screenHeight * 0.1 + 20),
                  child: SingleChildScrollView(
                    controller: controller.chatWidgetsScrollController,
                    physics: const BouncingScrollPhysics(
                        decelerationRate: ScrollDecelerationRate.fast),
                    child: Obx(
                      () => Column(
                        key: controller.columnKey,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: controller.chatWidgets.value,
                      ),
                    ),
                  )),
            ),
            Positioned(
                top: 2,
                child: GestureDetector(
                    onVerticalDragDown: (onvat) =>
                        controller.settingsIsOpen.value = false,
                    onTap: () => controller.settingsIsOpen.value = false,
                    child: ChatAppbar())),
            Positioned(
                left: controller.screenWidth * 0.55,
                top: controller.screenHeight * 0.1,
                child: SettingsWindow()),
            ChatBottomBar(),
            Positioned(
              bottom: controller.screenHeight * 0.12,
              left: controller.screenWidth * .85,
              child: Obx(
                () => AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity:
                      controller.scrollToBottomVisibility.value ? 1.0 : 0.0,
                  child: InkResponse(
                    onTap: () => controller.scrollToBottom(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.black38, blurRadius: 5)
                                .scale(5)
                          ]),
                      child: const Icon(Icons.keyboard_double_arrow_down),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
