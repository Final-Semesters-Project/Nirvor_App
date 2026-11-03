import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../helper/shared_prefe/shared_prefe.dart';
import '../../service/api_client.dart';
import '../../service/api_url.dart';
import '../../utils/app_const/app_const.dart';
import '../../view/screens/Provider/urgent_alert/screen/provider_urgent_alert_screen.dart';
import '../../view/screens/Provider/home_provider/screen/provider_nid_rejection_screen.dart';
import '../../view/screens/Provider/home_provider/controller/provider_home_controller.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling background FCM message: ${message.messageId}");
}

class FirebaseNotificationHelper {
  static Future<void> init() async {
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint(
        "FCM Notification permission status: ${settings.authorizationStatus}",
      );

      // Listen for token refreshes
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        debugPrint("FCM Token refreshed: $newToken");
        syncTokenWithBackend();
      });

      // Sync token if user is already logged in
      syncTokenWithBackend();

      // 1. Background state: When app is running in background and user taps notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint("FCM onMessageOpenedApp data: ${message.data}");
        handleNotificationRouting(message.data);
      });

      // 2. Terminated state: When app is killed and launched by tapping notification
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        if (message != null) {
          debugPrint("FCM getInitialMessage data: ${message.data}");
          Future.delayed(const Duration(milliseconds: 700), () {
            handleNotificationRouting(message.data);
          });
        }
      });

      // 3. Foreground state: When app is open on screen
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint("FCM onMessage (foreground): ${message.data}");
        final data = message.data;
        final type = data['type']?.toString();

        if (type == 'URGENT_BROADCAST') {
          final broadcastId = data['broadcast_id']?.toString() ?? '';
          final skillName = data['skill_name_bn']?.toString() ??
              data['skill_name_en']?.toString() ??
              data['skill_name']?.toString() ??
              'Service';

          // Show prominent alert banner in foreground
          Get.snackbar(
            "জরুরি কাজ! / Urgent Request!",
            "$skillName দরকার। এখনই গ্রহণ করতে ট্যাপ করুন।",
            backgroundColor: const Color(0xFF900C0C),
            colorText: Colors.white,
            icon: const Icon(
              Icons.bolt_rounded,
              color: Colors.amber,
              size: 30,
            ),
            duration: const Duration(seconds: 8),
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(12),
            borderRadius: 12,
            mainButton: TextButton(
              onPressed: () {
                if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
                navigateToUrgentAlert(broadcastId, skillName);
              },
              child: const Text(
                "দেখুন / OPEN",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            onTap: (_) {
              if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
              navigateToUrgentAlert(broadcastId, skillName);
            },
          );
        } else if (type == 'VERIFICATION_REJECTED') {
          // Refresh dashboard data
          if (Get.isRegistered<ProviderHomeController>()) {
            Get.find<ProviderHomeController>().getDashboardData(showLoading: false);
          }

          Get.snackbar(
            "যাচাইকরণ প্রত্যাখ্যাত! / Verification Rejected!",
            "আপনার NID যাচাইকরণ প্রত্যাখ্যান করা হয়েছে। বিস্তারিত দেখতে ট্যাপ করুন।",
            backgroundColor: const Color(0xFFDC2626),
            colorText: Colors.white,
            icon: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 28,
            ),
            duration: const Duration(seconds: 8),
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(12),
            borderRadius: 12,
            mainButton: TextButton(
              onPressed: () {
                if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
                Get.to(() => const ProviderNidRejectionScreen());
              },
              child: const Text(
                "দেখুন / VIEW",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            onTap: (_) {
              if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
              Get.to(() => const ProviderNidRejectionScreen());
            },
          );
        } else if (type == 'VERIFICATION_APPROVED') {
          if (Get.isRegistered<ProviderHomeController>()) {
            Get.find<ProviderHomeController>().getDashboardData(showLoading: false);
          }

          Get.snackbar(
            "অভিনন্দন! / Congratulations!",
            "আপনার অ্যাকাউন্ট সফলভাবে ভেরিফাইড হয়েছে।",
            backgroundColor: const Color(0xFF16A34A),
            colorText: Colors.white,
            icon: const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 28,
            ),
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(12),
            borderRadius: 12,
          );
        }
      });
    } catch (e) {
      debugPrint("Error initializing FirebaseNotificationHelper: $e");
    }
  }

  /// Sync device FCM token with backend /api/v1/auth/fcm/token
  static Future<void> syncTokenWithBackend() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;

      final bearerToken =
          await SharePrefsHelper.getString(AppConstants.bearerToken);
      if (bearerToken.isEmpty) {
        debugPrint(
            "FCM Token obtained ($token), waiting for user login before registering with backend.");
        return;
      }

      final String deviceType =
          Platform.isAndroid ? "android" : (Platform.isIOS ? "ios" : "unknown");

      final body = {
        "token": token,
        "device_type": deviceType,
      };

      final response = await ApiClient.postData(ApiUrl.fcmToken, body);
      debugPrint(
          "====> FCM Token registered to backend [${response.statusCode}]: $token");
    } catch (e) {
      debugPrint("Error syncing FCM token with backend: $e");
    }
  }

  static void handleNotificationRouting(Map<String, dynamic> data) {
    final type = data['type']?.toString();
    debugPrint("Handling notification routing for type: $type");

    if (type == 'URGENT_BROADCAST') {
      final broadcastId = data['broadcast_id']?.toString() ?? '';
      final skillName = data['skill_name_bn']?.toString() ??
          data['skill_name_en']?.toString() ??
          data['skill_name']?.toString();

      if (broadcastId.isNotEmpty) {
        navigateToUrgentAlert(broadcastId, skillName);
      }
    } else if (type == 'VERIFICATION_REJECTED') {
      // Refresh dashboard
      if (Get.isRegistered<ProviderHomeController>()) {
        Get.find<ProviderHomeController>().getDashboardData(showLoading: false);
      }
      Get.to(() => const ProviderNidRejectionScreen());
    } else if (type == 'VERIFICATION_APPROVED') {
      if (Get.isRegistered<ProviderHomeController>()) {
        Get.find<ProviderHomeController>().getDashboardData(showLoading: false);
      }
    }
  }

  static void navigateToUrgentAlert(String broadcastId, String? skillName) {
    if (broadcastId.isEmpty) return;
    Get.to(
      () => ProviderUrgentAlertScreen(
        broadcastId: broadcastId,
        skillName: skillName,
      ),
      preventDuplicates: false,
    );
  }
}
