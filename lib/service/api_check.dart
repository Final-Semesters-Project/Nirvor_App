import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/app_routes/app_routes.dart';
import '../helper/shared_prefe/shared_prefe.dart';
import '../utils/ToastMsg/toast_message.dart';
import '../utils/app_colors/app_colors.dart';
import '../utils/app_const/app_const.dart';
import 'api_client.dart';

class ApiChecker {
  // Prevent duplicate session expired dialogs/actions if multiple API calls fail simultaneously
  static bool isSessionExpiredHandling = false;

  static void checkApi(Response response, {bool getXSnackBar = false}) {
    if (response.statusCode == 401) {
      handleSessionExpired();
    } else {
      String? errorMessage;
      if (response.body is Map && response.body['error'] != null) {
        errorMessage = response.body['error'].toString();
      } else if (response.body is Map && response.body['message'] != null) {
        errorMessage = response.body['message'].toString();
      } else if (response.body is Map && response.body['detail'] != null) {
        errorMessage = response.body['detail'].toString();
      } else {
        errorMessage = response.statusText;
      }

      if (errorMessage != null && errorMessage.isNotEmpty) {
        showCustomSnackBar(errorMessage);
      }
    }
  }

  /// Called whenever a 401 Unauthorized / Token Expired response is received
  static void handleSessionExpired() {
    if (isSessionExpiredHandling) return;
    isSessionExpiredHandling = true;

    debugPrint("===> [ApiChecker] Token expired or 401 received. Handling session expiry...");

    // Show a clean user-friendly dialog (industry standard approach)
    if (Get.context != null) {
      Get.dialog(
        PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.lock_clock_outlined, color: AppColors.primary, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Session Expired".tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              "Your login session has expired. Please log in again to continue.".tr,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () async {
                  await forceLogout();
                },
                child: Text(
                  "Login Again".tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );
    } else {
      // If context is unavailable, immediately force logout
      forceLogout();
    }
  }

  /// Clears stored authentication data and redirects cleanly to the Login screen
  static Future<void> forceLogout() async {
    try {
      await SharePrefsHelper.remove(AppConstants.bearerToken);
      await SharePrefsHelper.remove(AppConstants.refreshToken);
      await SharePrefsHelper.remove(AppConstants.role);
      ApiClient.bearerToken = "";
    } catch (e) {
      debugPrint("Error clearing auth data: $e");
    } finally {
      isSessionExpiredHandling = false;
      // Close any open snackbars/dialogs and route to login
      Get.offAllNamed(AppRoutes.loginScreen);
    }
  }
}
