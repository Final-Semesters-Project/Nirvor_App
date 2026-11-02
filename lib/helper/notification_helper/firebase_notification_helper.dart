import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view/screens/Provider/urgent_alert/screen/provider_urgent_alert_screen.dart';

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
        }
      });
    } catch (e) {
      debugPrint("Error initializing FirebaseNotificationHelper: $e");
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

