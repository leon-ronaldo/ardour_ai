// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Obx(
      () => Container(
        height: controller.screenHeight,
        width: controller.screenWidth,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('User : ${controller.userDialogue.value}',
                style: TextStyle(fontSize: 16)),
            Container(height: 20),
            Text('Gemini : ${controller.geminiDialogue.value}',
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    ));
  }
}
