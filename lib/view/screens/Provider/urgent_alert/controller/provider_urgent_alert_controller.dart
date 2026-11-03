import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../../core/app_routes/app_routes.dart';
import '../../../../../service/api_client.dart';
import '../../../../../service/api_url.dart';
import '../../../../../utils/ToastMsg/toast_message.dart';
import '../../home_provider/controller/provider_home_controller.dart';
import '../model/urgent_broadcast_model.dart';
import '../screen/provider_active_urgent_job_screen.dart';

class ProviderUrgentAlertController extends GetxController {
  final String broadcastId;
  final String? initialSkillName;

  ProviderUrgentAlertController({
    required this.broadcastId,
    this.initialSkillName,
  });

  var isLoadingDetail = true.obs;
  var isClaiming = false.obs;
  var broadcastDetail = Rxn<UrgentBroadcastDetailModel>();
  var remainingSeconds = 0.obs;
  var distanceKm = Rxn<double>();
  var isExpiredOrClaimed = false.obs;
  var statusMessage = "".obs;

  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();
    fetchDetail();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  String get skillName {
    if (broadcastDetail.value != null &&
        broadcastDetail.value!.skillName.isNotEmpty) {
      return broadcastDetail.value!.skillName;
    }
    return initialSkillName ?? "Service";
  }

  String get formattedTimer {
    if (remainingSeconds.value <= 0) {
      return "0:00";
    }
    final minutes = remainingSeconds.value ~/ 60;
    final seconds = remainingSeconds.value % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  String get distanceText {
    if (distanceKm.value != null && distanceKm.value! > 0) {
      return "${distanceKm.value!.toStringAsFixed(1)} km away";
    }
    return "Nearby";
  }

  Future<void> fetchDetail() async {
    isLoadingDetail.value = true;
    try {
      final response = await ApiClient.getData(
        ApiUrl.urgentBroadcastDetail(broadcastId),
      );

      if (response.statusCode == 200 && response.body != null) {
        final data = UrgentBroadcastDetailModel.fromJson(response.body);
        broadcastDetail.value = data;

        if (data.isClaimed) {
          isExpiredOrClaimed.value = true;
          statusMessage.value =
              "This request has already been claimed by another provider.";
        } else if (data.isExpired) {
          isExpiredOrClaimed.value = true;
          statusMessage.value = "This urgent request has expired.";
        } else {
          _startTimer(data.expiresAt);
          _calculateDistance(data.seekerLatitude, data.seekerLongitude);
        }
      } else {
        // Fallback timer for 5 minutes if detail fails
        _startTimer(DateTime.now().add(const Duration(minutes: 5)));
        final msg = response.body is Map && response.body['detail'] != null
            ? response.body['detail'].toString()
            : "Could not load broadcast details";
        debugPrint("UrgentBroadcast fetchDetail error: $msg");
      }
    } catch (e) {
      debugPrint("Error fetching urgent broadcast details: $e");
      _startTimer(DateTime.now().add(const Duration(minutes: 5)));
    } finally {
      isLoadingDetail.value = false;
    }
  }

  void _startTimer(DateTime expiresAt) {
    _countdownTimer?.cancel();
    final diff = expiresAt.difference(DateTime.now()).inSeconds;
    if (diff <= 0) {
      remainingSeconds.value = 0;
      isExpiredOrClaimed.value = true;
      statusMessage.value = "This urgent request has expired.";
      return;
    }

    remainingSeconds.value = diff;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        timer.cancel();
        isExpiredOrClaimed.value = true;
        statusMessage.value = "This urgent request has expired.";
      }
    });
  }

  Future<void> _calculateDistance(double seekerLat, double seekerLng) async {
    if (seekerLat == 0.0 && seekerLng == 0.0) return;
    try {
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition()
          .timeout(const Duration(seconds: 4));

      final meters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        seekerLat,
        seekerLng,
      );
      distanceKm.value = meters / 1000.0;
    } catch (e) {
      debugPrint("UrgentAlert: error calculating distance: $e");
    }
  }

  Future<void> claimBroadcast() async {
    if (isClaiming.value) return;

    if (isExpiredOrClaimed.value) {
      showCustomSnackBar(
        statusMessage.value.isNotEmpty
            ? statusMessage.value
            : "This urgent request is no longer available.",
        isError: true,
      );
      return;
    }

    isClaiming.value = true;
    try {
      final response = await ApiClient.postData(
        ApiUrl.claimUrgentBroadcast(broadcastId),
        {},
      );

      debugPrint(
        "Claim urgent broadcast response: [${response.statusCode}] ${response.body}",
      );

      if (response.statusCode == 200) {
        _countdownTimer?.cancel();

        final body = response.body is Map
            ? Map<String, dynamic>.from(response.body)
            : <String, dynamic>{};

        final activeJob = ActiveUrgentJobModel(
          broadcastId: broadcastId,
          status: body['status']?.toString() ?? 'claimed',
          seekerName: body['seeker_name']?.toString() ?? 'Seeker',
          seekerPhone: body['seeker_phone']?.toString() ?? '',
          skillName: skillName,
          seekerLatitude: broadcastDetail.value?.seekerLatitude ?? 0.0,
          seekerLongitude: broadcastDetail.value?.seekerLongitude ?? 0.0,
          distanceKm: distanceKm.value ?? 0.0,
          claimedAt: DateTime.now(),
        );

        // Save active job in local storage
        await saveActiveUrgentJob(activeJob);

        // Notify ProviderHomeController
        if (Get.isRegistered<ProviderHomeController>()) {
          Get.find<ProviderHomeController>().setActiveUrgentJob(activeJob);
        }

        showCustomSnackBar(
          "কাজটি সফলভাবে গ্রহণ করা হয়েছে! / Urgent request accepted successfully!",
          isError: false,
          duration: const Duration(seconds: 3),
        );

        // Navigate directly to the Active Urgent Job tracking screen!
        Get.off(() => ProviderActiveUrgentJobScreen(job: activeJob));
      } else if (response.statusCode == 409) {
        // Already claimed by another provider
        isExpiredOrClaimed.value = true;
        final errMsg = response.body is Map && response.body['detail'] != null
            ? response.body['detail'].toString()
            : "দুঃখিত, অন্য একজন প্রোভাইডার আগেই এটি গ্রহণ করেছেন। / Another provider has already claimed this.";
        statusMessage.value = errMsg;
        showCustomSnackBar(errMsg, isError: true);
      } else {
        final errMsg = response.body is Map && response.body['detail'] != null
            ? response.body['detail'].toString()
            : "Failed to claim request. Please try again.";
        showCustomSnackBar(errMsg, isError: true);
      }
    } catch (e) {
      debugPrint("Error claiming urgent broadcast: $e");
      showCustomSnackBar("Network error occurred. Please try again.", isError: true);
    } finally {
      isClaiming.value = false;
    }
  }

  void decline() {
    _countdownTimer?.cancel();
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      Get.offAllNamed(AppRoutes.providerHomeScreen);
    }
  }
}

