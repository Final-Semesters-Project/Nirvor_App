import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../service/api_check.dart';
import '../../../../../../service/api_client.dart';
import '../../../../../../service/api_url.dart';
import '../../../../../../utils/ToastMsg/toast_message.dart';
import '../model/provider_dashboard_model.dart';
import '../model/provider_me_model.dart';

class ProviderHomeController extends GetxController {
  var isLoading = false.obs;
  var dashboardData = Rxn<ProviderDashboardModel>();
  var userMeData = Rxn<ProviderMeModel>();

  RxString verificationStatus = 'not_initiated'.obs;
  RxString verificationLevel = 'basic'.obs;
  RxString verificationRejectionReason = ''.obs;

  RxBool isAvailable = true.obs;
  RxDouble workRadius = 5.0.obs;
  double _lastConfirmedRadius = 5.0;

  void onRadiusDragStart() {
    _lastConfirmedRadius = workRadius.value;
  }

  var isUpdatingAvailability = false.obs;
  var isUpdatingRadius = false.obs;

  @override
  void onInit() {
    super.onInit();
    getDashboardData();
  }

  /// Fetch provider dashboard data
  Future<void> getDashboardData({bool showLoading = true}) async {
    if (showLoading) {
      isLoading.value = true;
    }

    try {
      final response = await ApiClient.getData(ApiUrl.providerDashboard);

      if (response.statusCode == 200 && response.body is Map<String, dynamic>) {
        final model = ProviderDashboardModel.fromJson(response.body);
        dashboardData.value = model;
        isAvailable.value = model.isAvailable;
        if (model.workingRadiusKm != null && model.workingRadiusKm! > 0) {
          final clamped = model.workingRadiusKm!.toDouble().clamp(1.0, 5.0);
          workRadius.value = clamped;
          _lastConfirmedRadius = clamped;
        }
      } else {
        ApiChecker.checkApi(response);
      }

      // 2. Fetch /users/me for accurate verification status & rejection reason
      final meResponse = await ApiClient.getData(ApiUrl.userProfile);
      if (meResponse.statusCode == 200 && meResponse.body is Map<String, dynamic>) {
        final meModel = ProviderMeModel.fromJson(meResponse.body);
        userMeData.value = meModel;
        verificationStatus.value = meModel.verificationStatus;
        verificationLevel.value = meModel.verificationLevel;
        verificationRejectionReason.value =
            meModel.verificationRejectionReason ?? '';
      }
    } catch (e) {
      debugPrint("Error fetching provider dashboard: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle availability switch
  Future<void> toggleAvailability(bool value) async {
    final previousValue = isAvailable.value;
    isAvailable.value = value;
    isUpdatingAvailability.value = true;

    try {
      final response = await ApiClient.patchData(
        ApiUrl.updateProviderProfile,
        {"is_available": value},
      );

      if (response.statusCode == 200) {
        showCustomSnackBar(
          value ? "You are now available for work".tr : "You are now offline".tr,
          isError: false,
        );
        // Refresh dashboard data silently
        getDashboardData(showLoading: false);
      } else {
        isAvailable.value = previousValue;
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      debugPrint("Error updating availability: $e");
      isAvailable.value = previousValue;
      showCustomSnackBar("Something went wrong".tr);
    } finally {
      isUpdatingAvailability.value = false;
    }
  }

  /// Update working radius (1 - 5 KM)
  Future<void> updateWorkingRadius(double value) async {
    final int intRadius = value.toInt().clamp(1, 5);
    final previousRadius = _lastConfirmedRadius;

    // If unchanged, do nothing
    if (intRadius.toDouble() == _lastConfirmedRadius) {
      workRadius.value = _lastConfirmedRadius;
      return;
    }

    isUpdatingRadius.value = true;

    try {
      final response = await ApiClient.patchData(
        ApiUrl.updateProviderProfile,
        {"working_radius_km": intRadius},
      );

      if (response.statusCode == 200) {
        _lastConfirmedRadius = intRadius.toDouble();
        workRadius.value = intRadius.toDouble();
        showCustomSnackBar(
          "Work radius updated to @radius KM".trParams({"radius": intRadius.toString()}),
          isError: false,
        );
        getDashboardData(showLoading: false);
      } else {
        // Revert slider immediately back to previous confirmed value
        workRadius.value = previousRadius;
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      debugPrint("Error updating work radius: $e");
      workRadius.value = previousRadius;
      showCustomSnackBar("Something went wrong".tr);
    } finally {
      isUpdatingRadius.value = false;
    }
  }

  var isRemovingSkill = false.obs;

  /// Remove skill from provider profile
  Future<void> removeSkill(int skillId) async {
    isRemovingSkill.value = true;
    try {
      final response = await ApiClient.deleteData(
        ApiUrl.providerRemoveSkill(skillId),
      );

      if (response.statusCode == 200) {
        showCustomSnackBar(
          "Skill removed successfully".tr,
          isError: false,
        );
        // Optimistically update local skills list
        if (dashboardData.value != null) {
          final updatedSkills = dashboardData.value!.skills
              .where((s) => s.id != skillId)
              .toList();
          dashboardData.value = ProviderDashboardModel(
            userId: dashboardData.value!.userId,
            name: dashboardData.value!.name,
            photoUrl: dashboardData.value!.photoUrl,
            isAvailable: dashboardData.value!.isAvailable,
            verificationLevel: dashboardData.value!.verificationLevel,
            averageRating: dashboardData.value!.averageRating,
            totalJobsDone: dashboardData.value!.totalJobsDone,
            aiReviewSummary: dashboardData.value!.aiReviewSummary,
            workingRadiusKm: dashboardData.value!.workingRadiusKm,
            skills: updatedSkills,
          );
        }
        getDashboardData(showLoading: false);
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      debugPrint("Error removing skill: $e");
      showCustomSnackBar("Something went wrong".tr);
    } finally {
      isRemovingSkill.value = false;
    }
  }
}
