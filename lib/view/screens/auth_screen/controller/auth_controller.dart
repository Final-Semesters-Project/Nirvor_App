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
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  // Category & Skills State
  RxList<dynamic> categories = <dynamic>[].obs;
  RxList<String> selectedCategories = <String>[].obs;
  RxMap<String, List<dynamic>> categorySkills = <String, List<dynamic>>{}.obs;
  RxList<String> selectedSkills = <String>[].obs;

  // Setup Details State
  RxDouble workRadius = 1.0.obs;
  RxBool hasSmartphone = false.obs;

  // Location State
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;
  RxString locationAddress = ''.obs;
  RxList<dynamic> locationSuggestions = <dynamic>[].obs;
  RxBool isLocationSearching = false.obs;
  Timer? _debounce;
  TextEditingController locationController = TextEditingController();

  // Loading States
  RxBool isCategoryLoading = false.obs;
  RxBool isSkillsLoading = false.obs;
  RxBool isAuthLoading = false.obs;

  @override
  void onClose() {
    _debounce?.cancel();
    locationController.dispose();
    super.onClose();
  }

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

  void onLocationChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        searchLocation(query);
      } else {
        locationSuggestions.clear();
      }
    });
  }

  Future<void> searchLocation(String query) async {
    isLocationSearching.value = true;
    try {
      final uri = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5');
      final response = await http.get(uri, headers: {
        'User-Agent': 'NirbhorApp/1.0',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        locationSuggestions.value = data;
      } else {
        locationSuggestions.clear();
      }
    } catch (e) {
      debugPrint("Location search error: $e");
      locationSuggestions.clear();
    }
    isLocationSearching.value = false;
  }

  void selectLocation(Map<String, dynamic> location) {
    latitude.value = double.tryParse(location['lat'].toString()) ?? 0.0;
    longitude.value = double.tryParse(location['lon'].toString()) ?? 0.0;
    locationAddress.value = location['display_name'] ?? '';
    locationController.text = locationAddress.value;
    locationSuggestions.clear();
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
        if (response.body['refresh_token'] != null) {
          await SharePrefsHelper.setString(
            AppConstants.refreshToken,
            response.body['refresh_token'],
          );
        }
        if (response.body['role'] != null) {
          await SharePrefsHelper.setString(
            AppConstants.role,
            response.body['role'],
          );
        }
      }
      showCustomSnackBar("Login successful".tr, isError: false);
      await sendFcmToken();
      // Navigate to home depending on role. Example:
      if(response.body['role'] == 'provider'){
        Get.offAllNamed(AppRoutes.providerHomeScreen);
      }else{
        Get.offAllNamed(AppRoutes.homeSeekerScreen);
      }
    } 
    else {
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
      body["latitude"] = latitude.value;
      body["longitude"] = longitude.value;
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
        if (response.body['refresh_token'] != null) {
          await SharePrefsHelper.setString(
            AppConstants.refreshToken,
            response.body['refresh_token'],
          );
        }
        await SharePrefsHelper.setString(
          AppConstants.role,
          role.toLowerCase(),
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

    String deviceType = "unknown";
    if (Platform.isAndroid) {
      deviceType = "android";
    } else if (Platform.isIOS) {
      deviceType = "ios";
    }

    Map<String, String> body = {"token": finalToken, "device_type": deviceType};
    await ApiClient.postData("${ApiUrl.fcmToken}?token=$finalToken", body);
  }

  Future<void> logout() async {
    isAuthLoading.value = true;

    String refreshToken = await SharePrefsHelper.getString(AppConstants.refreshToken);
    String fcmToken = "";
    try {
      fcmToken = await FirebaseMessaging.instance.getToken() ?? "";
    } catch (e) {
      debugPrint("Error fetching FCM token for logout: $e");
    }

    Map<String, dynamic> body = {
      "refresh_token": refreshToken,
    };
    if (fcmToken.isNotEmpty) {
      body["fcm_token"] = fcmToken;
    }

    try {
      await ApiClient.postData(ApiUrl.signOut, body);
    } catch (e) {
      debugPrint("Logout API error: $e");
    }

    // Clear local data
    await SharePrefsHelper.remove(AppConstants.bearerToken);
    await SharePrefsHelper.remove(AppConstants.refreshToken);
    await SharePrefsHelper.remove(AppConstants.role);

    isAuthLoading.value = false;

    // Route to Welcome screen
    Get.offAllNamed(AppRoutes.welcomeScreen);
    showCustomSnackBar("Logged out successfully".tr, isError: false);
  }
}
