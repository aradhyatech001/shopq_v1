import 'package:get/get.dart';

import 'package:shopq_delivery/app/routes/app_routes.dart';

/// Routes a notification payload to the right delivery screen. The rider app's
/// main screen is the tasks list (home), so most notifications land there.
class DeepLinkRouter {
  static void open(Map<String, dynamic> data) {
    // All delivery notifications (new assignment, pickup/delivery/COD reminders,
    // route updates) lead to the rider's task list.
    Get.toNamed(AppRoutes.home);
  }
}
