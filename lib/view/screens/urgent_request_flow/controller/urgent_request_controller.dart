import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nirbhor/helper/shared_prefe/shared_prefe.dart';
import 'package:nirbhor/model/category_model.dart';
import 'package:nirbhor/model/skill_model.dart';
import 'package:nirbhor/service/api_client.dart';
import 'package:nirbhor/service/api_url.dart';
import 'package:nirbhor/utils/ToastMsg/toast_message.dart';
import 'package:nirbhor/view/screens/Seeker/seeker_profile/controller/seeker_profile_controller.dart';
import 'package:nirbhor/view/screens/Seeker/home_seeker/controller/home_seeker_controller.dart';
import 'package:nirbhor/view/screens/urgent_request_flow/urgent_request_flow_screen.dart';

enum UrgentFlowState {
  configuring, // State 1: Select skill & location
  broadcasting, // State 2: Radar countdown, waiting for provider
  claimed, // State 3: Claimed by a provider
  expired, // State 4: 5 minutes elapsed, no response
}

class UrgentRequestController extends GetxController {
  // Current state of the flow
  var flowState = UrgentFlowState.configuring.obs;

  // Categories & Skills
  var categories = <CategoryModel>[].obs;
  var skills = <SkillModel>[].obs;
  var selectedCategory = Rxn<CategoryModel>();
  var selectedSkill = Rxn<SkillModel>();

  var isLoadingCategories = false.obs;
  var isLoadingSkills = false.obs;
  var isSubmitting = false.obs;

  // Location details
  var selectedLocationMode = 'current'.obs; // 'current' or 'home'
  var currentLatitude = 0.0.obs;
  var currentLongitude = 0.0.obs;
  var currentAddress = ''.obs;

  var homeLatitude = 0.0.obs;
  var homeLongitude = 0.0.obs;
  var homeAddress = ''.obs;

  var isDetectingLocation = false.obs;

  // Broadcast results
  var broadcastId = ''.obs;
  var secondsRemaining = 300.obs; // 5 minutes default
  var claimedByName = ''.obs;
  var broadcastMessage = ''.obs;

  Timer? _countdownTimer;
  Timer? _statusPollTimer;

  double get targetLatitude {
    if (selectedLocationMode.value == 'home' && homeLatitude.value != 0.0) {
      return homeLatitude.value;
    }
    return currentLatitude.value;
  }

  double get targetLongitude {
    if (selectedLocationMode.value == 'home' && homeLongitude.value != 0.0) {
      return homeLongitude.value;
    }
    return currentLongitude.value;
  }

  String get effectiveAddress {
    if (selectedLocationMode.value == 'home' && homeAddress.value.isNotEmpty) {
      return homeAddress.value;
    }
    if (currentAddress.value.isNotEmpty) {
      return currentAddress.value;
    }
    if (currentLatitude.value != 0.0 && currentLongitude.value != 0.0) {
      return "${currentLatitude.value.toStringAsFixed(4)}, ${currentLongitude.value.toStringAsFixed(4)}";
    }
    return 'Current GPS Location'.tr;
  }

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  @override
  void onClose() {
    _stopTimers();
    super.onClose();
  }

  void _stopTimers() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _statusPollTimer?.cancel();
    _statusPollTimer = null;
  }

  Future<void> initData() async {
    await Future.wait([
      fetchCategories(),
      loadSavedHomeLocation(),
      detectCurrentLocation(),
    ]);
  }

  /// Load categories from backend or inherit from HomeSeekerController
  Future<void> fetchCategories() async {
    // If HomeSeekerController already has categories, reuse them instantly
    if (Get.isRegistered<HomeSeekerController>()) {
      final homeCtrl = Get.find<HomeSeekerController>();
      if (homeCtrl.categories.isNotEmpty) {
        categories.value = List.from(homeCtrl.categories);
        if (selectedCategory.value == null && categories.isNotEmpty) {
          selectCategory(categories.first);
        }
        return;
      }
    }

    try {
      isLoadingCategories.value = true;
      final response = await ApiClient.getData(ApiUrl.categoryList);
      if (response.statusCode == 200 && response.body is List) {
        List data = response.body;
        categories.value = data.map((e) => CategoryModel.fromJson(e)).toList();
        if (categories.isNotEmpty) {
          selectCategory(categories.first);
        }
      }
    } catch (e) {
      debugPrint("Error fetching categories for urgent broadcast: $e");
    } finally {
      isLoadingCategories.value = false;
    }
  }

  /// Select a category and fetch its skills
  void selectCategory(CategoryModel category) {
    selectedCategory.value = category;
    selectedSkill.value = null;
    fetchSkills(category.id);
  }

  /// Fetch skills for a selected category
  Future<void> fetchSkills(int categoryId) async {
    try {
      isLoadingSkills.value = true;
      final response = await ApiClient.getData(ApiUrl.skillList(categoryId.toString()));
      if (response.statusCode == 200 && response.body is List) {
        List data = response.body;
        skills.value = data.map((e) => SkillModel.fromJson(e)).toList();
        if (skills.isNotEmpty) {
          selectedSkill.value = skills.first;
        }
      } else {
        skills.clear();
      }
    } catch (e) {
      debugPrint("Error fetching skills: $e");
    } finally {
      isLoadingSkills.value = false;
    }
  }

  void selectSkill(SkillModel skill) {
    selectedSkill.value = skill;
  }

  void setLocationMode(String mode) {
    selectedLocationMode.value = mode;
    if (mode == 'current' && currentLatitude.value == 0.0) {
      detectCurrentLocation();
    }
  }

  /// Load home address from shared prefs or SeekerProfileController
  Future<void> loadSavedHomeLocation() async {
    try {
      String addr = await SharePrefsHelper.getString("seeker_home_address");
      String latStr = await SharePrefsHelper.getString("seeker_home_lat");
      String lngStr = await SharePrefsHelper.getString("seeker_home_lng");

      if (addr.isNotEmpty) homeAddress.value = addr;
      if (latStr.isNotEmpty) homeLatitude.value = double.tryParse(latStr) ?? 0.0;
      if (lngStr.isNotEmpty) homeLongitude.value = double.tryParse(lngStr) ?? 0.0;

      if (Get.isRegistered<SeekerProfileController>()) {
        final profileCtrl = Get.find<SeekerProfileController>();
        final user = profileCtrl.user.value;
        if (user != null && user.homeAddress.isNotEmpty) {
          if (homeAddress.value.isEmpty) homeAddress.value = user.homeAddress;
          if (homeLatitude.value == 0.0 && user.homeLatitude != null) {
            homeLatitude.value = user.homeLatitude!;
          }
          if (homeLongitude.value == 0.0 && user.homeLongitude != null) {
            homeLongitude.value = user.homeLongitude!;
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading home location: $e");
    }
  }

  /// Detect seeker's real-time GPS location
  Future<void> detectCurrentLocation() async {
    try {
      isDetectingLocation.value = true;
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        isDetectingLocation.value = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          isDetectingLocation.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        isDetectingLocation.value = false;
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentLatitude.value = position.latitude;
      currentLongitude.value = position.longitude;
      currentAddress.value = 'Current GPS Location'.tr;
    } catch (e) {
      debugPrint("Error detecting current location: $e");
    } finally {
      isDetectingLocation.value = false;
    }
  }

  /// Trigger POST /api/v1/urgentBroadcast/broadcast
  Future<void> triggerUrgentBroadcast() async {
    if (selectedSkill.value == null) {
      showCustomSnackBar('Please select a skill first'.tr, isError: true);
      return;
    }

    double lat = targetLatitude;
    double lng = targetLongitude;

    if (lat == 0.0 || lng == 0.0) {
      await detectCurrentLocation();
      lat = targetLatitude;
      lng = targetLongitude;
      if (lat == 0.0 || lng == 0.0) {
        // Fallback default coordinates if GPS unavailable
        lat = 23.7510;
        lng = 90.3930;
      }
    }

    try {
      isSubmitting.value = true;
      final body = {
        "skill_id": selectedSkill.value!.id,
        "latitude": lat,
        "longitude": lng,
      };

      final response = await ApiClient.postData(ApiUrl.urgentBroadcast, body);
      isSubmitting.value = false;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.body != null) {
        final resData = response.body;
        broadcastId.value = resData['broadcast_id']?.toString() ?? '';
        broadcastMessage.value = resData['message']?.toString() ?? 'Urgent request sent'.tr;
        secondsRemaining.value = 300; // 5 minutes

        // Switch to broadcasting state
        flowState.value = UrgentFlowState.broadcasting;

        // Start countdown & status polling
        _startCountdownAndPolling();
      } else {
        String errMsg = response.body?['detail'] ??
            response.body?['message'] ??
            'Failed to send urgent request'.tr;
        showCustomSnackBar(errMsg, isError: true);
      }
    } catch (e) {
      isSubmitting.value = false;
      showCustomSnackBar('Something went wrong. Please try again.'.tr, isError: true);
      debugPrint("Urgent broadcast error: $e");
    }
  }

  void _startCountdownAndPolling() {
    _stopTimers();

    // 1-second countdown timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        // Time expired
        timer.cancel();
        _statusPollTimer?.cancel();
        flowState.value = UrgentFlowState.expired;
      }
    });

    // Poll status every 5 seconds
    _statusPollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      checkBroadcastStatus();
    });

    // Run first check immediately after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (flowState.value == UrgentFlowState.broadcasting) {
        checkBroadcastStatus();
      }
    });
  }

  /// GET /api/v1/urgentBroadcast/broadcast/{broadcast_id}/status
  Future<void> checkBroadcastStatus() async {
    if (broadcastId.value.isEmpty) return;

    try {
      final response = await ApiClient.getData(
        ApiUrl.urgentBroadcastStatus(broadcastId.value),
      );

      if (response.statusCode == 200 && response.body != null) {
        final data = response.body;
        final status = (data['status'] ?? '').toString().toLowerCase();

        if (data['seconds_remaining'] != null) {
          int remaining = data['seconds_remaining'];
          if (remaining >= 0) {
            secondsRemaining.value = remaining;
          }
        }

        if (status == 'claimed') {
          _stopTimers();
          claimedByName.value = data['claimed_by_name'] ?? 'Verified Provider'.tr;
          flowState.value = UrgentFlowState.claimed;

          // If HomeSeekerController is active, refresh active booking
          if (Get.isRegistered<HomeSeekerController>()) {
            Get.find<HomeSeekerController>().checkActiveBooking();
          }

          // If user is currently on home screen or outside, open UrgentRequestFlowScreen
          Get.to(() => const UrgentRequestFlowScreen());
        } else if (status == 'expired' || secondsRemaining.value <= 0) {
          _stopTimers();
          flowState.value = UrgentFlowState.expired;
        }
      }
    } catch (e) {
      debugPrint("Error polling broadcast status: $e");
    }
  }

  /// Seeker manually cancels current broadcast
  void cancelBroadcast() {
    _stopTimers();
    broadcastId.value = '';
    secondsRemaining.value = 300;
    flowState.value = UrgentFlowState.configuring;
    showCustomSnackBar('Request cancelled'.tr, isError: false);
  }

  /// Retry sending urgent broadcast
  void retryBroadcast() {
    _stopTimers();
    flowState.value = UrgentFlowState.configuring;
    triggerUrgentBroadcast();
  }

  /// Reset form back to configuration state
  void resetToConfig() {
    _stopTimers();
    broadcastId.value = '';
    secondsRemaining.value = 300;
    flowState.value = UrgentFlowState.configuring;
  }

  /// Formatted timer MM:SS
  String get formattedTime {
    int minutes = secondsRemaining.value ~/ 60;
    int seconds = secondsRemaining.value % 60;
    String minStr = minutes.toString().padLeft(2, '0');
    String secStr = seconds.toString().padLeft(2, '0');
    return '$minStr:$secStr';
  }

  /// Localized formatted timer (Bengali digits if locale is 'bn')
  String get localizedFormattedTime {
    final time = formattedTime;
    if (Get.locale?.languageCode == 'bn') {
      const enDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      const bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
      String result = time;
      for (int i = 0; i < 10; i++) {
        result = result.replaceAll(enDigits[i], bnDigits[i]);
      }
      return result;
    }
    return time;
  }
}

