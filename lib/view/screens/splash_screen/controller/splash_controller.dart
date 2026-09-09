import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/app_routes/app_routes.dart';
import '../../../../helper/shared_prefe/shared_prefe.dart';
import '../../../../utils/app_const/app_const.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    Timer(const Duration(seconds: 2), () async {
      String bearerToken = await SharePrefsHelper.getString(AppConstants.bearerToken);
      if (bearerToken.isNotEmpty) {
        String role = await SharePrefsHelper.getString(AppConstants.role);
        if (role == 'provider') {
          Get.offAllNamed(AppRoutes.providerHomeScreen);
        } else {
          Get.offAllNamed(AppRoutes.homeSeekerScreen);
        }
      } else {
        Get.offAllNamed(AppRoutes.welcomeScreen);
      }
    });
  }
}
