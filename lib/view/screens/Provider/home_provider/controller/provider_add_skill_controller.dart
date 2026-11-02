import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../service/api_check.dart';
import '../../../../../../service/api_client.dart';
import '../../../../../../service/api_url.dart';
import '../../../../../../utils/ToastMsg/toast_message.dart';
import 'provider_home_controller.dart';

class ProviderAddSkillController extends GetxController {
  final isCategoryLoading = false.obs;
  final isSkillsLoading = false.obs;
  final isSubmitting = false.obs;

  final categories = <dynamic>[].obs;
  final selectedCategoryIds = <String>{}.obs;
  final categorySkills = <String, List<dynamic>>{}.obs;

  // Selected new skill IDs
  final selectedSkillIds = <int>{}.obs;

  // IDs of skills already added to the provider's profile
  final existingSkillIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadExistingSkills();
    fetchCategories();
  }

  void _loadExistingSkills() {
    if (Get.isRegistered<ProviderHomeController>()) {
      final homeCtrl = Get.find<ProviderHomeController>();
      final skills = homeCtrl.dashboardData.value?.skills ?? [];
      for (var s in skills) {
        existingSkillIds.add(s.id);
      }
    }
  }

  /// Fetch all categories
  Future<void> fetchCategories() async {
    isCategoryLoading.value = true;
    try {
      final response = await ApiClient.getData(ApiUrl.categoryList);
      if (response.statusCode == 200 && response.body is List) {
        categories.value = response.body;
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    } finally {
      isCategoryLoading.value = false;
    }
  }

  /// Reload data when language is toggled
  Future<void> onLanguageChanged() async {
    categorySkills.clear();
    await fetchCategories();
    // Re-fetch skills for currently expanded categories in new language
    for (var catId in selectedCategoryIds.toList()) {
      await fetchSkills(catId);
    }
  }

  /// Toggle category open/close and fetch skills if not loaded yet
  Future<void> toggleCategory(String categoryId) async {
    if (selectedCategoryIds.contains(categoryId)) {
      selectedCategoryIds.remove(categoryId);
    } else {
      selectedCategoryIds.add(categoryId);
      if (!categorySkills.containsKey(categoryId)) {
        await fetchSkills(categoryId);
      }
    }
  }

  /// Fetch skills for a specific category
  Future<void> fetchSkills(String categoryId) async {
    isSkillsLoading.value = true;
    try {
      final response = await ApiClient.getData(ApiUrl.skillList(categoryId));
      if (response.statusCode == 200 && response.body is List) {
        categorySkills[categoryId] = List<dynamic>.from(response.body);
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      debugPrint("Error fetching skills for category $categoryId: $e");
    } finally {
      isSkillsLoading.value = false;
    }
  }

  /// Toggle selection of a skill
  void toggleSkill(int skillId) {
    if (existingSkillIds.contains(skillId)) {
      showCustomSnackBar("This skill is already added".tr);
      return;
    }
    if (selectedSkillIds.contains(skillId)) {
      selectedSkillIds.remove(skillId);
    } else {
      selectedSkillIds.add(skillId);
    }
  }

  /// Submit newly selected skills to backend
  Future<void> submitSkills() async {
    if (selectedSkillIds.isEmpty) {
      showCustomSnackBar("Please select at least one skill".tr);
      return;
    }

    isSubmitting.value = true;
    try {
      final body = {
        "skill_ids": selectedSkillIds.toList(),
      };

      final response = await ApiClient.postData(
        ApiUrl.providerAddSkill,
        body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showCustomSnackBar("Skills added successfully".tr, isError: false);

        // Refresh provider dashboard
        if (Get.isRegistered<ProviderHomeController>()) {
          Get.find<ProviderHomeController>().getDashboardData(showLoading: false);
        }

        Get.back();
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      debugPrint("Error adding skills: $e");
      showCustomSnackBar("Something went wrong".tr);
    } finally {
      isSubmitting.value = false;
    }
  }
}

