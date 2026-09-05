import 'package:get/get.dart';

class HomeSeekerController extends GetxController {
  var selectedCategoryIndex = 0.obs;

  void selectCategory(int index) {
    selectedCategoryIndex.value = index;
  }
}
