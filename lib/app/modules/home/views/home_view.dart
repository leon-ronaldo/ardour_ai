// ignore_for_file: prefer_const_constructors

import 'dart:ui';

import 'package:ardour_ai/app/modules/home/views/home_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                margin: const EdgeInsets.only(top: 15),
                height: controller.screenHeight * 0.75,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      GreetingWidget(),
                      ToDo(),
                      Reminders(),
                      ComponentBreadCrumb(),
                      ArdourikaSettings(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
