import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/app_routes/app_routes.dart';
import '../../../../helper/notification_helper/firebase_notification_helper.dart';
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
      String bearerToken =
          await SharePrefsHelper.getString(AppConstants.bearerToken);
      if (bearerToken.isNotEmpty) {
        // Sync FCM token with backend whenever existing session is restored
        FirebaseNotificationHelper.syncTokenWithBackend();

        String role = await SharePrefsHelper.getString(AppConstants.role);
        final pendingData = FirebaseNotificationHelper.pendingNotificationData;
        FirebaseNotificationHelper.pendingNotificationData = null;

        if (role == 'provider') {
          await Get.offAllNamed(AppRoutes.providerHomeScreen);
          if (pendingData != null && pendingData.isNotEmpty) {
            FirebaseNotificationHelper.handleNotificationRouting(pendingData);
          }
        } else {
          await Get.offAllNamed(AppRoutes.homeSeekerScreen);
          if (pendingData != null && pendingData.isNotEmpty) {
            FirebaseNotificationHelper.handleNotificationRouting(pendingData);
          }
        }
      } else {
        Get.offAllNamed(AppRoutes.welcomeScreen);
      }
    });
  }
}
