import 'package:get/get.dart';
import '../helper/shared_prefe/shared_prefe.dart';
import '../utils/ToastMsg/toast_message.dart';
import '../utils/app_const/app_const.dart';

class ApiChecker {
  static void checkApi(Response response, {bool getXSnackBar = false}) async {
    if (response.statusCode == 401) {
      await SharePrefsHelper.remove(AppConstants.bearerToken);
      //Get.offAllNamed(AppRoutes.loginOnlyScreen);
    } else {
      showCustomSnackBar(response.body['error']);
    }
  }
}
