import 'package:get/get.dart';

import '../../modules/cart/controllers/cart_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CartController>(CartController(), permanent: true);
  }
}
