import 'package:get/get.dart';

class ProviderHomeController extends GetxController {
  RxBool isAvailable = true.obs;
  RxDouble workRadius = 5.0.obs;

  void toggleAvailability(bool value) {
    isAvailable.value = value;
  }
}
