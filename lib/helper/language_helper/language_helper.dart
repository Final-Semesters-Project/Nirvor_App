import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../service/api_client.dart';
import '../../service/api_url.dart';
import '../../utils/app_const/app_const.dart';
import '../shared_prefe/shared_prefe.dart';

class LanguageHelper {
  /// Changes language locally and syncs preferred_language with backend if user is logged in
  static Future<void> changeLanguage(String langCode) async {
    final isBn = langCode == 'bn';
    final locale = isBn ? const Locale('bn', 'BD') : const Locale('en', 'US');

    // 1. Update GetX active locale
    await Get.updateLocale(locale);

    // 2. Persist in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', isBn ? 'bn' : 'en');
    await prefs.setString('countryCode', isBn ? 'BD' : 'US');

    // 3. Sync with backend /api/v1/users/me/toggle_preferred_language if logged in
    await syncPreferredLanguageWithBackend(isBn ? 'bn' : 'en');
  }

  /// Sends PATCH /api/v1/users/me/toggle_preferred_language with {"preferred_language": "en" | "bn"}
  static Future<void> syncPreferredLanguageWithBackend(String langCode) async {
    try {
      final bearerToken =
          await SharePrefsHelper.getString(AppConstants.bearerToken);
      if (bearerToken.isEmpty) {
        debugPrint(
            "User not logged in; skipping backend preferred language sync.");
        return;
      }

      final preferredLang = langCode == 'bn' ? 'bn' : 'en';
      final body = {
        "preferred_language": preferredLang,
      };

      final response = await ApiClient.patchData(
        ApiUrl.togglePreferredLanguage,
        body,
      );

      debugPrint(
        "====> Sync preferred language [${response.statusCode}]: $body",
      );
    } catch (e) {
      debugPrint("Error syncing preferred language with backend: $e");
    }
  }
}
