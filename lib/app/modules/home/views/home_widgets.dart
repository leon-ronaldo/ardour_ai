// ignore_for_file: prefer_const_constructors

import 'package:ardour_ai/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavBar extends GetWidget<HomeController> {
  const NavBar({super.key});

  String formatDate() {
    final now = DateTime.now();
    final weekday = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday"
    ][now.weekday - 1];
    final month = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ][now.month - 1];
    final day = now.day;
    final year = now.year;

    return '$weekday - $month $day / $year';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        height: controller.screenHeight * 0.16,
        width: controller.screenWidth,
        decoration: const BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              controller.mainController.currentTime.value,
              style: const TextStyle(
                  fontFamily: 'antipasto', fontSize: 28, color: Colors.white),
            ),
            Text(
              formatDate(),
              style: const TextStyle(
                  fontFamily: 'antipasto', fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomBar extends GetWidget<HomeController> {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: controller.screenHeight * 0.08,
      width: controller.screenWidth,
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(500)),
          // Nested BoxDecoration for background effect
          color: Colors.grey.shade100.withOpacity(0.9)),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
              4,
              (index) => (index == 3)
                  ? InkResponse(
                      onTap: () => Get.toNamed('/chat-page'),
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundImage:
                            AssetImage('assets/images/ardourika_looking.png'),
                      ),
                    )
                  : (index == 0)
                      ? InkResponse(
                          child: Icon(
                              [
                                CupertinoIcons.home,
                                CupertinoIcons.memories,
                                CupertinoIcons.group_solid
                              ][index],
                              color: Colors.blueAccent))
                      : InkResponse(
                          onTap: () {
                            [
                              () => {},
                              () => Get.toNamed('/memory-page'),
                              () => Get.toNamed('page'),
                              () => Get.toNamed('/chat-page')
                            ][index]();
                          },
                          child: Icon(
                              [
                                CupertinoIcons.home,
                                CupertinoIcons.memories,
                                CupertinoIcons.group_solid
                              ][index],
                              color: Colors.grey),
                        ))),
    );
  }
}

class BreadCrumb extends GetWidget<HomeController> {
  BreadCrumb({super.key});

  List<String> breadCrumbTexts = [
    'To do',
    'Reminders',
    'Calendar Events',
    'People',
    'Memories',
    'User Report',
    'Ardour Settings'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      height: controller.screenHeight * 0.05,
      width: controller.screenWidth,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.fast),
        itemCount: breadCrumbTexts.length,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(right: 15),
          child: InkResponse(
            onTap: () {},
            child: Text(
              breadCrumbTexts[index],
              style: const TextStyle(
                  fontFamily: 'antipasto', fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class GreetingWidget extends GetWidget<HomeController> {
  const GreetingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: controller.screenHeight * 0.2,
      width: controller.screenWidth,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.black45),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: controller.screenWidth * 0.3,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/ardourika_hey.png"),
                    fit: BoxFit.cover)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                          maxHeight: controller.screenWidth * 0.3),
                      child: Text(
                        'Good Moringing',
                        style: const TextStyle(
                            fontFamily: 'antipasto',
                            fontSize: 18,
                            color: Colors.white),
                      ),
                    ),
                    Text(
                      controller.mainController.userName,
                      style: const TextStyle(
                          fontFamily: 'antipasto',
                          fontSize: 28,
                          color: Colors.white),
                    ),
                  ],
                ),
                ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: controller.screenWidth * 0.4),
                  child: Text(
                    'The librarian whispers, "They are right behind you!"',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontFamily: 'antipasto',
                        fontSize: 14,
                        color: Colors.white),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ToDo extends GetWidget<HomeController> {
  ToDo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(top: 20),
      width: controller.screenWidth,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          // Nested BoxDecoration for background effect
          color: Colors.grey.shade100.withOpacity(0.6)),
      child: Column(
          children: List.generate(
              controller.toDos.length + 1,
              (index) => index == 0
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'To do list:',
                            style: TextStyle(
                                fontFamily: 'antipasto',
                                fontSize: 22,
                                color: Colors.black87),
                          ),
                          InkResponse(
                            onTap: () {},
                            child: Icon(
                              Icons.add,
                              size: 18,
                            ),
                          )
                        ],
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          controller.toDos[index - 1],
                          style: const TextStyle(
                              fontFamily: 'antipasto',
                              fontSize: 16,
                              color: Colors.white),
                        ),
                        InkResponse(
                          onTap: () {},
                          child: Icon(
                            Icons.close,
                            size: 18,
                          ),
                        )
                      ],
                    ))),
    );
  }
}

class Reminders extends GetWidget<HomeController> {
  const Reminders({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(top: 20),
        width: controller.screenWidth,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            // Nested BoxDecoration for background effect
            color: Colors.grey.shade100.withOpacity(0.6)),
        child: Column(
            children: controller.mainController.reminders.value.isEmpty
                ? List.generate(
                    2,
                    (index) => index == 0
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Upcomind Reminders:',
                                  style: TextStyle(
                                      fontFamily: 'antipasto',
                                      fontSize: 22,
                                      color: Colors.black87),
                                ),
                                InkResponse(
                                  onTap: () {},
                                  child: Icon(
                                    Icons.add,
                                    size: 18,
                                  ),
                                )
                              ],
                            ),
                          )
                        : Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            width: controller.screenWidth,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            height: controller.screenHeight * 0.15,
                            child: const Text(
                              'You have not set any reminders',
                              style: TextStyle(
                                  fontFamily: 'antipasto',
                                  fontSize: 16,
                                  color: Colors.black54),
                            ),
                          ))
                : List.generate(
                    controller.mainController.reminders.value.length + 1,
                    (index) => index == 0
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Upcomind Reminders:',
                                  style: TextStyle(
                                      fontFamily: 'antipasto',
                                      fontSize: 22,
                                      color: Colors.black87),
                                ),
                                InkResponse(
                                  onTap: () {},
                                  child: Icon(
                                    Icons.add,
                                    size: 18,
                                  ),
                                )
                              ],
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.mainController.reminders
                                          .value[index - 1]['title'],
                                      style: const TextStyle(
                                          fontFamily: 'antipasto',
                                          fontSize: 16,
                                          color: Colors.white),
                                    ),
                                    Text(
                                      'Reminds you at : ${DateTime.parse(controller.mainController.reminders.value[index - 1]['dateTime']).toUtc().hour} : ${DateTime.parse(controller.mainController.reminders.value[index - 1]['dateTime']).toUtc().minute}',
                                      style: const TextStyle(
                                          fontFamily: 'antipasto',
                                          fontSize: 16,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                                InkResponse(
                                  onTap: () {},
                                  child: Icon(
                                    Icons.close,
                                    size: 18,
                                  ),
                                )
                              ],
                            ),
                          ))),
      ),
    );
  }
}

class ComponentBreadCrumb extends GetWidget<HomeController> {
  const ComponentBreadCrumb({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: controller.screenHeight * 0.46,
        width: controller.screenWidth,
        child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 10),
            itemCount: controller.componentBreadCrumbs.length,
            itemBuilder: (context, index) => InkResponse(
                  onTap: () => controller.componentBreadCrumbs[index][2](),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                              controller.componentBreadCrumbs[index][1]),
                          opacity: 0.8,
                          fit: BoxFit.cover),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      controller.componentBreadCrumbs[index][0],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'antipasto'),
                    ),
                  ),
                )));
  }
}

class ArdourikaSettings extends GetWidget<HomeController> {
  const ArdourikaSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final voices = [];
    return Container(
      padding: const EdgeInsets.all(20),
      margin: EdgeInsets.only(top: 20, bottom: controller.screenHeight * 0.12),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          color: Colors.grey.shade100.withOpacity(0.6)),
      width: controller.screenWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                // Nested BoxDecoration for background effect
                color: Colors.grey.shade100.withOpacity(0.6)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: controller.screenWidth * 0.25,
                  height: controller.screenHeight * 0.2,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                              "assets/images/ardourika_hands_folded.png"),
                          fit: BoxFit.cover)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth: controller.screenWidth * 0.4),
                            child: Text(
                              'Settings and\nBehaviour',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontFamily: 'antipasto',
                                  fontSize: 16,
                                  color: Colors.white),
                            ),
                          ),
                          Text(
                            'Ardourika',
                            style: const TextStyle(
                                fontFamily: 'antipasto',
                                fontSize: 28,
                                color: Colors.black54),
                          ),
                        ],
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: controller.screenWidth * 0.4),
                        child: Text(
                          'tweak her as per you wish :)',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontFamily: 'antipasto',
                              fontSize: 14,
                              color: Colors.white),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Obx(
            () => Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: const [
                        Color.fromARGB(255, 184, 142, 189),
                        Color.fromARGB(255, 236, 175, 147)
                      ])),
              width: controller.screenWidth,
              padding: const EdgeInsets.only(
                  top: 20, left: 20, bottom: 20, right: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Humour level',
                          style: const TextStyle(
                              fontFamily: 'antipasto',
                              fontSize: 16,
                              color: Colors.white),
                        ),
                        SizedBox(
                            width: controller.screenWidth * 0.4,
                            child: SliderTheme(
                                data: SliderThemeData(
                                  trackHeight:
                                      1.5, // Adjust track height as needed
                                  thumbShape: RoundSliderThumbShape(
                                      disabledThumbRadius:
                                          10.0), // Adjust size as needed
                                  overlayShape: RoundSliderOverlayShape(
                                      overlayRadius:
                                          8.0), // Adjust size as needed
                                ),
                                child: Slider(
                                    value: controller
                                        .mainController.humourLevel.value,
                                    onChanged: ((value) {
                                      controller.mainController.humourLevel
                                          .value = value;
                                    }))))
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 5, bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Relation',
                          style: const TextStyle(
                              fontFamily: 'antipasto',
                              fontSize: 16,
                              color: Colors.white),
                        ),
                        DropdownMenu(
                          dropdownMenuEntries: controller.relationDropDown,
                          width: controller.screenWidth * 0.38,
                          initialSelection: controller.relationDropDown[0],
                          textStyle: const TextStyle(fontSize: 14),
                          inputDecorationTheme: InputDecorationTheme(
                              contentPadding: const EdgeInsets.only(left: 10),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)))),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 5, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Voice',
                          style: const TextStyle(
                              fontFamily: 'antipasto',
                              fontSize: 16,
                              color: Colors.white),
                        ),
                        DropdownMenu(
                          dropdownMenuEntries: [],
                          width: controller.screenWidth * 0.38,
                          textStyle: const TextStyle(fontSize: 14),
                          leadingIcon:
                              InkResponse(onTap: () {}, child: Icon(Icons.mic)),
                          inputDecorationTheme: InputDecorationTheme(
                              contentPadding: const EdgeInsets.only(left: 10),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)))),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    width: controller.screenWidth,
                    margin: const EdgeInsets.only(top: 10, right: 0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(500)),
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: const [
                              Color.fromARGB(255, 36, 58, 159),
                              Color.fromARGB(255, 122, 137, 218),
                            ])),
                    child: Text(
                      'Change Settings',
                      style: const TextStyle(
                          fontFamily: 'antipasto',
                          fontSize: 16,
                          color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
