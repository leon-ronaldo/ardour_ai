// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';
import 'package:device_calendar/device_calendar.dart';
import 'package:ardour_ai/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  //widget variables
  double screenHeight = 0, screenWidth = 0;

  MainController mainController = Get.find<MainController>();
  DeviceCalendarPlugin deviceCalendarPlugin = DeviceCalendarPlugin();

  //data

  List<String> toDos = [
    'Call Hans Landa',
    'Meet the cafe',
    'Shower',
    'Buy medicines',
    'Buy hatchet'
  ];

  List<List> reminders = [
    [
      'Call Hans Landa',
      '${DateTime.now().hour < 10 ? '0${DateTime.now().hour}' : DateTime.now().hour} : ${DateTime.now().minute < 10 ? '0${DateTime.now().minute}' : DateTime.now().minute}'
    ],
    [
      'Meet the cafe',
      '${DateTime.now().hour < 10 ? '0${DateTime.now().hour}' : DateTime.now().hour} : ${DateTime.now().minute < 10 ? '0${DateTime.now().minute}' : DateTime.now().minute}'
    ],
    [
      'Shower',
      '${DateTime.now().hour < 10 ? '0${DateTime.now().hour}' : DateTime.now().hour} : ${DateTime.now().minute < 10 ? '0${DateTime.now().minute}' : DateTime.now().minute}'
    ],
    [
      'Buy medicines',
      '${DateTime.now().hour < 10 ? '0${DateTime.now().hour}' : DateTime.now().hour} : ${DateTime.now().minute < 10 ? '0${DateTime.now().minute}' : DateTime.now().minute}'
    ],
    [
      'Buy hatchet',
      '${DateTime.now().hour < 10 ? '0${DateTime.now().hour}' : DateTime.now().hour} : ${DateTime.now().minute < 10 ? '0${DateTime.now().minute}' : DateTime.now().minute}'
    ]
  ];

  List componentBreadCrumbs = [
    [
      'Calendar',
      'assets/images/calendar_illustration.png',
      () {},
    ],
    [
      'Events',
      'assets/images/memories_illustration.png',
      () {
        Get.toNamed('/memory-page');
      },
    ],
    [
      'People',
      'assets/images/contacts_illustration.png',
      () {},
    ],
    [
      'Profile',
      'assets/images/profile_illustration.png',
      () {
        Get.toNamed('/chat-page');
      },
    ],
  ];

  List<DropdownMenuEntry> relationDropDown = [
    DropdownMenuEntry(value: 'Friend', label: 'Friend'),
    DropdownMenuEntry(value: 'GirlFriend', label: 'Girl Friend'),
    DropdownMenuEntry(value: 'Sister', label: 'Sister')
  ];

  List<DropdownMenuEntry> voicesDropDown = [];

  @override
  void onInit() async {
    super.onInit();

    screenHeight = Get.context!.height;
    screenWidth = Get.context!.width;

    final granted = await deviceCalendarPlugin.requestPermissions();
    if (!granted.isSuccess) {
      // Handle permission denied scenario (e.g., show a message)
      return;
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  String formatDate(DateTime date) {
    final weekday = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday"
    ][date.weekday - 1];
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
    ][date.month - 1];
    final day = date.day;
    final year = date.year;

    return '$weekday - $month $day / $year';
  }

  void retrieveCalendarEvents() async {
    final calendar =
        (await deviceCalendarPlugin.retrieveCalendars()).data!.first;
    final events = await deviceCalendarPlugin.retrieveEvents(
        calendar.id,
        RetrieveEventsParams(
            startDate: DateTime.now().subtract(const Duration(days: 15)),
            endDate: DateTime.now().add(const Duration(days: 15))));
    print(calendar);
    print(events.data);
    if (events.data != null)
      for (var data in events.data!) {
        print("""
        title : ${data.title}
        description : ${data.description}
        start: ${formatDate(data.start!.toUtc())}
        status: ${data.status}
        """);
      }
  }
}
