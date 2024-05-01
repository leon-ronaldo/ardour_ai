import 'package:ardour_ai/app/modules/home/controllers/home_controller.dart';
import 'package:ardour_ai/app/modules/memory_page/controllers/memory_page_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavBar extends GetWidget<MemoryPageController> {
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

class BottomBar extends GetWidget<MemoryPageController> {
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
                  : (index == 1)
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
                              () => Get.toNamed('/home'),
                              () => {},
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

class BreadCrumb extends GetWidget<MemoryPageController> {
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

class GreetingWidget extends GetWidget<MemoryPageController> {
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

class MemoryPageIntro extends GetWidget<MemoryPageController> {
  const MemoryPageIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    image: AssetImage("assets/images/ardourika_think.png"),
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
                        'You and\nMemories',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontFamily: 'antipasto',
                            fontSize: 16,
                            color: Colors.white),
                      ),
                    ),
                    Text(
                      controller.mainController.userName,
                      style: const TextStyle(
                          fontFamily: 'antipasto',
                          fontSize: 28,
                          color: Colors.black54),
                    ),
                  ],
                ),
                ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: controller.screenWidth * 0.4),
                  child: Text(
                    'Rewind your memories... :)',
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

class MemoryTile extends GetWidget<MemoryPageController> {
  MemoryTile(
      {super.key,
      required this.title,
      this.peopleInvolved = const [],
      required this.place});

  List peopleInvolved = [];
  final String title;
  final String place;

  @override
  Widget build(BuildContext context) {
    String peopleInvolvedString = '';
    peopleInvolved.forEach((person) {
      peopleInvolvedString += "$person ";
    });
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: controller.screenHeight * 0.3,
        width: controller.screenWidth,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            // Nested BoxDecoration for background effect
            color: Colors.grey.shade100.withOpacity(0.6)),
        child: Container(
          height: controller.screenHeight * 0.3,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: controller.screenWidth * 0.4),
                child: Text(
                  'Place : $place',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      fontFamily: 'antipasto',
                      fontSize: 14,
                      color: Colors.white),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontFamily: 'antipasto',
                        fontSize: 28,
                        color: Colors.black54),
                  ),
                  ConstrainedBox(
                    constraints:
                        BoxConstraints(maxWidth: controller.screenWidth * 0.4),
                    child: Text(
                      '${peopleInvolvedString} \nare involved',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          fontFamily: 'antipasto',
                          fontSize: 16,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}

class MemoriesSection extends GetWidget<MemoryPageController> {
  const MemoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: List.generate(
            controller.memories.value.length,
            (index) => MemoryTile(
                title: controller.memories.value[index]['title'],
                place: controller.memories.value[index]['location'],
                peopleInvolved: controller.memories.value[index]
                    ['peopleInvolved'])),
      ),
    );
  }
}
