import 'package:get/get.dart';
import '../controllers/payout_controller.dart';

class PayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PayoutController());
  }
}
