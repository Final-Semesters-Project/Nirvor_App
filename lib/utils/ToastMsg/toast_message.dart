import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../app_colors/app_colors.dart';

void showCustomSnackBar(String? message, {bool isError = true, Duration? duration}) {
  if (message == null || message.trim().isEmpty) return;

  // Cancel any lingering native toast
  Fluttertoast.cancel();

  try {
    // Close any currently open snackbars so they never stack or freeze
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    // Get.closeAllSnackbars();

    Get.rawSnackbar(
      messageText: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError ? AppColors.red : AppColors.primary,
      borderRadius: 10,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: duration ?? const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 250),
      isDismissible: true,
      dismissDirection: DismissDirection.up,
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.18),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  } on Object catch (e) {
    debugPrint("Snackbar error: $e");
    // Safe fallback to simple bottom toast if overlay context is unavailable
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red.shade700 : AppColors.primary,
      textColor: Colors.white,
    );
  }
}

void toastMessage({required String message}) {
  showCustomSnackBar(message, isError: false);
}
