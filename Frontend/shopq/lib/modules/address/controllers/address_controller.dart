import 'package:get/get.dart';
import '../../../core/storage/storage_service.dart';
class AddressController extends GetxController {
  final isLoading = false.obs;
  String get selectedAddressId => StorageService.selectedAddressId;
  String get selectedAddressFull => StorageService.selectedAddressFull;
}
