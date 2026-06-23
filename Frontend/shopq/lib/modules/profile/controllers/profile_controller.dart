import 'package:get/get.dart';
import '../../../core/storage/storage_service.dart';
class ProfileController extends GetxController {
  final isLoading = false.obs;
  String get userName => StorageService.userName;
  String get userEmail => StorageService.userEmail;
  String get userId => StorageService.userId;
}
