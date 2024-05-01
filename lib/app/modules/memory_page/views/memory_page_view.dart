// ignore_for_file: prefer_const_constructors

import 'package:ardour_ai/app/modules/memory_page/views/memory_page_widgets.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/memory_page_controller.dart';

class MemoryPageView extends GetView<MemoryPageController> {
  const MemoryPageView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Scaffold(
            bottomNavigationBar: BottomBar(),
            extendBody: true,
            body: Container(
              //later use obx
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

              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  NavBar(),
                  BreadCrumb(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    margin: EdgeInsets.only(top: 10),
                    height: controller.screenHeight * 0.75,
                    child: Container(
                      padding: EdgeInsets.only(
                          bottom: controller.screenHeight * 0.1),
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          children: [MemoryPageIntro(), MemoriesSection()],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )));
  }
}
