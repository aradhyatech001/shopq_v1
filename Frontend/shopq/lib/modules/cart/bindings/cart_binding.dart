import 'package:get/get.dart';
class CartBinding extends Bindings {
  @override
  void dependencies() {
    // CartController is already registered as permanent in InitialBinding
    // No-op: just ensures the binding exists for route structure
  }
}
