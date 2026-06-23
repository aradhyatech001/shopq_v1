import 'package:get/get.dart';
import '../controllers/pincode_controller.dart';

class PincodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PincodeController());
  }
}
