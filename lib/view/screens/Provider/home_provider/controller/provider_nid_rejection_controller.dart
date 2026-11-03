import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../service/api_client.dart';
import '../../../../../../service/api_url.dart';
import '../model/provider_me_model.dart';
import 'provider_home_controller.dart';

class ProviderNidRejectionController extends GetxController {
  var isLoading = false.obs;
  var rejectionReason = ''.obs;
  var nidUrlFront = ''.obs;
  var nidUrlBack = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromExistingData();
    fetchMe();
  }

  void _loadFromExistingData() {
    if (Get.isRegistered<ProviderHomeController>()) {
      final homeCtrl = Get.find<ProviderHomeController>();
      if (homeCtrl.verificationRejectionReason.value.isNotEmpty) {
        rejectionReason.value = homeCtrl.verificationRejectionReason.value;
      }
      final me = homeCtrl.userMeData.value;
      if (me != null) {
        if (me.nidUrlFront != null && me.nidUrlFront!.isNotEmpty) {
          nidUrlFront.value = me.nidUrlFront!;
        }
        if (me.nidUrlBack != null && me.nidUrlBack!.isNotEmpty) {
          nidUrlBack.value = me.nidUrlBack!;
        }
        if (me.verificationRejectionReason != null &&
            me.verificationRejectionReason!.isNotEmpty) {
          rejectionReason.value = me.verificationRejectionReason!;
        }
      }
    }
  }

  Future<void> fetchMe() async {
    // Only show loading spinner if we don't have data already
    if (rejectionReason.value.isEmpty && nidUrlFront.value.isEmpty) {
      isLoading.value = true;
    }
    try {
      final response = await ApiClient.getData(ApiUrl.userProfile);
      if (response.statusCode == 200 && response.body is Map<String, dynamic>) {
        final me = ProviderMeModel.fromJson(response.body);
        if (me.verificationRejectionReason != null &&
            me.verificationRejectionReason!.isNotEmpty) {
          rejectionReason.value = me.verificationRejectionReason!;
        }
        if (me.nidUrlFront != null && me.nidUrlFront!.isNotEmpty) {
          nidUrlFront.value = me.nidUrlFront!;
        }
        if (me.nidUrlBack != null && me.nidUrlBack!.isNotEmpty) {
          nidUrlBack.value = me.nidUrlBack!;
        }

        // Also update ProviderHomeController if registered
        if (Get.isRegistered<ProviderHomeController>()) {
          final homeCtrl = Get.find<ProviderHomeController>();
          homeCtrl.userMeData.value = me;
          homeCtrl.verificationStatus.value = me.verificationStatus;
          homeCtrl.verificationLevel.value = me.verificationLevel;
          homeCtrl.verificationRejectionReason.value =
              me.verificationRejectionReason ?? '';
        }
      }
    } catch (e) {
      debugPrint("Error fetching me for rejection screen: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

