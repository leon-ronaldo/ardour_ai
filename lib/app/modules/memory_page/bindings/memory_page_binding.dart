import 'package:get/get.dart';

import '../controllers/memory_page_controller.dart';

class MemoryPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MemoryPageController>(
      () => MemoryPageController(),
    );
  }
}
