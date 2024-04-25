import 'package:ardour_ai/app/modules/chat_page/views/chat_page_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:get/get.dart';

import '../controllers/chat_page_controller.dart';

class ChatPageView extends GetView<ChatPageController> {
  const ChatPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      height: controller.screenHeight,
      width: controller.screenWidth,
      color: Colors.grey.shade100,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
              padding: const EdgeInsets.only(left: 25, right: 25),
              margin:
                  EdgeInsets.only(bottom: controller.screenHeight * 0.1 + 20),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Obx(
                  () => Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: controller.chatWidgets.value,
                  ),
                ),
              )),
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              height: controller.screenHeight * 0.28,
              width: controller.screenWidth * 0.45,
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade400, blurRadius: 5)
                        .scale(5)
                  ],
                  image: DecorationImage(
                      image: AssetImage("assets/images/hi.png"),
                      fit: BoxFit.cover),
                  borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(80))),
            ),
          ),
          Positioned(
            top: 2,
            child: Container(
              width: controller.screenWidth,
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              height: controller.screenHeight * .08,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkResponse(
                    child: Icon(Icons.arrow_back_sharp),
                  ),
                  InkResponse(
                    child: Icon(Icons.settings),
                  )
                ],
              ),
            ),
          ),
          ChatBottomBar()
        ],
      ),
    ));
  }
}
