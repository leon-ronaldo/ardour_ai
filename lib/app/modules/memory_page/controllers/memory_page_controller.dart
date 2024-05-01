import 'dart:convert';
import 'dart:io';

import 'package:ardour_ai/main.dart';
import 'package:get/get.dart';

class MemoryPageController extends GetxController {
  //widget variables
  double screenHeight = 0, screenWidth = 0;
  MainController mainController = Get.find<MainController>();
  RxList memories = [].obs;
  bool isAvailable = false;

  @override
  void onInit() {
    super.onInit();

    screenHeight = Get.context!.height;
    screenWidth = Get.context!.width;
  }

  @override
  void onReady() async{
    super.onReady();

    isAvailable =
        await mainController.secureStorage.containsKey(key: 'memories');

    isAvailable
        ? memories.value = jsonDecode(
            await mainController.secureStorage.read(key: 'memories') ?? 'null')
        : null;

    print(memories);
  }

  @override
  void onClose() {
    super.onClose();
  }
}
