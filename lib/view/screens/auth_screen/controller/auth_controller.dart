import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nirbhor/utils/ToastMsg/toast_message.dart';
import '../../../../service/api_client.dart';
import '../../../../service/api_url.dart';
import '../../../../core/app_routes/app_routes.dart';
import '../../../../helper/shared_prefe/shared_prefe.dart';
import '../../../../utils/app_const/app_const.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

class AuthController extends GetxController {
  // Category & Skills State
  RxList<dynamic> categories = <dynamic>[].obs;
  RxList<String> selectedCategories = <String>[].obs;
  RxMap<String, List<dynamic>> categorySkills = <String, List<dynamic>>{}.obs;
  RxList<String> selectedSkills = <String>[].obs;

  // Setup Details State
  RxDouble workRadius = 1.0.obs;
  RxBool hasSmartphone = false.obs;

  // Loading States
  RxBool isCategoryLoading = false.obs;
  RxBool isSkillsLoading = false.obs;
  RxBool isAuthLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    isCategoryLoading.value = true;
    final response = await ApiClient.getData(ApiUrl.categoryList);
    if (response.statusCode == 200) {
      if (response.body != null && response.body is List) {
        categories.value = response.body;
      }
    } else {
      debugPrint("Failed to fetch categories: ${response.statusText}");
    }
    isCategoryLoading.value = false;
  }

  Future<void> fetchSkills(String categoryId) async {
    if (categorySkills.containsKey(categoryId)) return;
    
    isSkillsLoading.value = true;
    final response = await ApiClient.getData(ApiUrl.skillList(categoryId));
    if (response.statusCode == 200) {
      if (response.body != null && response.body is List) {
        categorySkills[categoryId] = response.body;
      }
    } else {
      debugPrint("Failed to fetch skills for $categoryId: ${response.statusText}");
    }
    isSkillsLoading.value = false;
  }

  Future<void> toggleCategory(String categoryId) async {
    if (selectedCategories.contains(categoryId)) {
      selectedCategories.remove(categoryId);
      // Optional: remove selected skills for this category
      if (categorySkills.containsKey(categoryId)) {
        for (var skill in categorySkills[categoryId]!) {
          selectedSkills.remove(skill['id'].toString());
        }
      }
    } else {
      selectedCategories.add(categoryId);
      await fetchSkills(categoryId);
    }
  }

  void toggleSkill(String skillId) {
    if (selectedSkills.contains(skillId)) {
      selectedSkills.remove(skillId);
    } else {
      selectedSkills.add(skillId);
    }
  }

  Future<void> login(String phone, String password) async {
    isAuthLoading.value = true;
    Map<String, String> body = {"username": phone, "password": password};
    final response = await ApiClient.postData(
      ApiUrl.signIn,
      body,
      isContentType: false,
    );

    if (response.statusCode == 200) {
      if (response.body != null && response.body['access_token'] != null) {
        await SharePrefsHelper.setString(
          AppConstants.bearerToken,
          "Bearer ${response.body['access_token']}",
        );
      }
      showCustomSnackBar("Login successful".tr, isError: false);
      await sendFcmToken();
      // Navigate to home depending on role. Example:
      Get.offAllNamed(AppRoutes.homeSeekerScreen);
    } else {
      String errorMsg = "Login failed".tr;
      if (response.body != null && response.body is Map) {
        if (response.body['message'] != null) {
          errorMsg = response.body['message'];
        } else if (response.body['detail'] != null) {
          var detail = response.body['detail'];
          if (detail is String) {
            errorMsg = detail;
          } else if (detail is List && detail.isNotEmpty) {
            if (detail[0] is Map && detail[0]['msg'] != null) {
              errorMsg = detail[0]['msg'];
            } else {
              errorMsg = detail[0].toString();
            }
          } else {
            errorMsg = detail.toString();
          }
        }
      } else if (response.statusText != null) {
        errorMsg = response.statusText!;
      }
      showCustomSnackBar(errorMsg, isError: true);
    }
    isAuthLoading.value = false;
  }

  Future<void> register({
    required String phone,
    required String nameEn,
    required String nameBn,
    required String password,
    required String role,
  }) async {
    isAuthLoading.value = true;

    Map<String, dynamic> body = {
      "phone": phone,
      "name_en": nameEn,
      "name_bn": nameBn,
      "password": password,
      "preferred_lang": Get.locale?.languageCode ?? 'en',
    };

    String endpoint = ApiUrl.signUpSeeker;

    if (role.toLowerCase() == "provider") {
      endpoint = ApiUrl.signUpProvider;
      body["skill_ids"] = selectedSkills.map((e) => int.parse(e)).toList();
      body["latitude"] = 0.0;
      body["longitude"] = 0.0;
      body["working_radius_km"] = workRadius.value.toInt();
      body["has_smartphone"] = hasSmartphone.value;
    }

    final response = await ApiClient.postData(endpoint, body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body != null && response.body['access_token'] != null) {
        await SharePrefsHelper.setString(
          AppConstants.bearerToken,
          "Bearer ${response.body['access_token']}",
        );
      }
      showCustomSnackBar("Registration successful".tr, isError: false);
      await sendFcmToken();
      if (role.toLowerCase() == 'seeker') {
        Get.offAllNamed(AppRoutes.homeSeekerScreen);
      } else {
        Get.offAllNamed(AppRoutes.loginScreen); // Or provider home
      }
    } else {
      String errorMsg = "Registration failed".tr;
      if (response.body != null && response.body is Map) {
        if (response.body['message'] != null) {
          errorMsg = response.body['message'];
        } else if (response.body['detail'] != null) {
          var detail = response.body['detail'];
          if (detail is String) {
            errorMsg = detail;
          } else if (detail is List && detail.isNotEmpty) {
            if (detail[0] is Map && detail[0]['msg'] != null) {
              errorMsg = detail[0]['msg'];
            } else {
              errorMsg = detail[0].toString();
            }
          } else {
            errorMsg = detail.toString();
          }
        }
      } else if (response.statusText != null) {
        errorMsg = response.statusText!;
      }
      showCustomSnackBar(errorMsg, isError: true);
    }
    isAuthLoading.value = false;
  }

  Future<void> sendFcmToken() async {
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint("Error fetching FCM token: $e");
    }
    
    // Fallback if token is null for any reason
    String finalToken = fcmToken ?? "dummy_token_fallback";

    String deviceType = "UNKNOWN";
    if (Platform.isAndroid) {
      deviceType = "ANDROID";
    } else if (Platform.isIOS) {
      deviceType = "IOS";
    }

    Map<String, String> body = {"token": finalToken, "device_type": deviceType};
    await ApiClient.postData("${ApiUrl.fcmToken}?token=$finalToken", body);
  }
}
