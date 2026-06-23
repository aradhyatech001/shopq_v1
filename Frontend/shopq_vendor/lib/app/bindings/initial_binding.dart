import 'package:get/get.dart';

/// Registered once at app startup (passed to GetMaterialApp.initialBinding).
/// Screen-level controllers belong in their own module bindings.
/// ApiClient and StorageService are static utilities — no GetX registration needed.
class InitialBinding extends Bindings {
  @override
  void dependencies() {}
}
