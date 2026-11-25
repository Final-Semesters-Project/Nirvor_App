import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../../core/app_routes/app_routes.dart';
import '../../../../helper/notification_helper/firebase_notification_helper.dart';
import '../../../../helper/language_helper/language_helper.dart';
import '../../../../helper/shared_prefe/shared_prefe.dart';
import '../../../../utils/app_const/app_const.dart';
import '../../Provider/urgent_alert/screen/provider_urgent_alert_screen.dart';

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
        // Sync FCM token and preferred language with backend whenever existing session is restored
        FirebaseNotificationHelper.syncTokenWithBackend();
        LanguageHelper.syncPreferredLanguageWithBackend(
          Get.locale?.languageCode ?? 'en',
        );

        String role = await SharePrefsHelper.getString(AppConstants.role);
        final pendingData = FirebaseNotificationHelper.pendingNotificationData ??
            (await FirebaseMessaging.instance.getInitialMessage())?.data;
        FirebaseNotificationHelper.pendingNotificationData = null;

        if (role == 'provider') {
          if (pendingData != null && pendingData.isNotEmpty) {
            final type = pendingData['type']?.toString();
            if (type == 'URGENT_BROADCAST') {
              final broadcastId = pendingData['broadcast_id']?.toString() ?? '';
              final skillName = pendingData['skill_name_bn']?.toString() ??
                  pendingData['skill_name_en']?.toString() ??
                  pendingData['skill_name']?.toString();

              if (broadcastId.isNotEmpty) {
                // Directly show urgent alert screen immediately after splash!
                Get.offAll(
                  () => ProviderUrgentAlertScreen(
                    broadcastId: broadcastId,
                    skillName: skillName,
                  ),
                  routeName: '/ProviderUrgentAlertScreen_$broadcastId',
                );
                return;
              }
            }
          }
          Get.offAllNamed(AppRoutes.providerHomeScreen);
          if (pendingData != null && pendingData.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              FirebaseNotificationHelper.handleNotificationRouting(pendingData);
            });
          }
        } else {
          Get.offAllNamed(AppRoutes.homeSeekerScreen);
          if (pendingData != null && pendingData.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              FirebaseNotificationHelper.handleNotificationRouting(pendingData);
            });
          }
        }
      } else {
        Get.offAllNamed(AppRoutes.welcomeScreen);
      }
    });
  }
}
