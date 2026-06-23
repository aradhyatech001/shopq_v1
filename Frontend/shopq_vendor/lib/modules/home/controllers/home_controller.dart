import 'package:get/get.dart';

class HomeController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxBool sidebarExpanded = true.obs;

  void navigateTo(int index) => selectedIndex.value = index;
  void toggleSidebar() => sidebarExpanded.value = !sidebarExpanded.value;
}
