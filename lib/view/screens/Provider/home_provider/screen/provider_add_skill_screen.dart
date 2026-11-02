import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../../utils/app_colors/app_colors.dart';
import '../../../../components/custom_button/custom_button.dart';
import '../../../../components/custom_royel_appbar/custom_royel_appbar.dart';
import '../../../../components/custom_text/custom_text.dart';
import '../controller/provider_add_skill_controller.dart';

class ProviderAddSkillScreen extends StatelessWidget {
  const ProviderAddSkillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderAddSkillController());

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: CustomRoyelAppbar(
        titleName: 'Add Skills'.tr,
        leftIcon: true,
        leftOnTap: () => Get.back(),
        showLanguageSwitcher: true,
        onLanguageChanged: controller.onLanguageChanged,
      ),
      body: Obx(() {
        if (controller.isCategoryLoading.value && controller.categories.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category_outlined, size: 50.sp, color: Colors.grey),
                SizedBox(height: 12.h),
                Text(
                  'No categories available'.tr,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: controller.fetchCategories,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: Text('Retry'.tr, style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: 'Select Categories & Skills'.tr,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 6.h),
              CustomText(
                text: 'Tap on a category to view and select available skills.'.tr,
                fontSize: 12.5.sp,
                color: Colors.black54,
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 16.h),

              // Categories & Sub-Skills list
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.categories.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final cat = controller.categories[index];
                  final String catId = cat['id'].toString();
                  final String catName = cat['name']?.toString() ??
                      cat['name_bn']?.toString() ??
                      cat['name_en']?.toString() ??
                      '';

                  return Obx(() {
                    final isExpanded = controller.selectedCategoryIds.contains(catId);
                    final skills = controller.categorySkills[catId] ?? [];
                    final isSkillsLoading = controller.isSkillsLoading.value &&
                        !controller.categorySkills.containsKey(catId);

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isExpanded ? AppColors.primary : Colors.grey.shade200,
                          width: isExpanded ? 1.5 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Header Card
                          InkWell(
                            onTap: () => controller.toggleCategory(catId),
                            borderRadius: BorderRadius.circular(12.r),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 14.h,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36.w,
                                    height: 36.w,
                                    decoration: BoxDecoration(
                                      color: isExpanded
                                          ? AppColors.primary.withValues(alpha: 0.12)
                                          : Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.handyman_rounded,
                                      color: isExpanded
                                          ? AppColors.primary
                                          : Colors.grey.shade600,
                                      size: 18.sp,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      catName,
                                      style: TextStyle(
                                        fontSize: 14.5.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: isExpanded
                                        ? AppColors.primary
                                        : Colors.grey.shade500,
                                    size: 24.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Expandable Skills Section
                          if (isExpanded) ...[
                            const Divider(height: 1),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(14.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12.r),
                                  bottomRight: Radius.circular(12.r),
                                ),
                              ),
                              child: isSkillsLoading
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    )
                                  : skills.isEmpty
                                      ? Padding(
                                          padding: EdgeInsets.symmetric(vertical: 8.h),
                                          child: Text(
                                            'No skills available for this category'.tr,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        )
                                      : Wrap(
                                          spacing: 8.w,
                                          runSpacing: 8.h,
                                          children: skills.map((skill) {
                                            final int skillId = skill['id'] is int
                                                ? skill['id']
                                                : int.tryParse(skill['id'].toString()) ?? 0;
                                            final String skillName = skill['name']?.toString() ??
                                                skill['name_bn']?.toString() ??
                                                skill['name_en']?.toString() ??
                                                '';

                                            final bool isAlreadyAdded = controller
                                                .existingSkillIds
                                                .contains(skillId);
                                            final bool isSelected = controller
                                                .selectedSkillIds
                                                .contains(skillId);

                                            return GestureDetector(
                                              onTap: () => controller.toggleSkill(skillId),
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 200),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 14.w,
                                                  vertical: 8.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isAlreadyAdded
                                                      ? Colors.grey.shade200
                                                      : isSelected
                                                          ? AppColors.primary
                                                          : Colors.white,
                                                  borderRadius: BorderRadius.circular(20.r),
                                                  border: Border.all(
                                                    color: isAlreadyAdded
                                                        ? Colors.grey.shade300
                                                        : isSelected
                                                            ? AppColors.primary
                                                            : Colors.grey.shade300,
                                                    width: 1.2,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    if (isAlreadyAdded) ...[
                                                      Icon(
                                                        Icons.check_circle,
                                                        size: 14.sp,
                                                        color: Colors.grey.shade600,
                                                      ),
                                                      SizedBox(width: 4.w),
                                                    ] else if (isSelected) ...[
                                                      Icon(
                                                        Icons.check,
                                                        size: 14.sp,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(width: 4.w),
                                                    ],
                                                    Text(
                                                      skillName +
                                                          (isAlreadyAdded
                                                              ? ' (${'Already Added'.tr})'
                                                              : ''),
                                                      style: TextStyle(
                                                        fontSize: 12.5.sp,
                                                        fontWeight: (isSelected || isAlreadyAdded)
                                                            ? FontWeight.w600
                                                            : FontWeight.w400,
                                                        color: isAlreadyAdded
                                                            ? Colors.grey.shade600
                                                            : isSelected
                                                                ? Colors.white
                                                                : const Color(0xFF1E293B),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                            ),
                          ],
                        ],
                      ),
                    );
                  });
                },
              ),
              SizedBox(height: 80.h),
            ],
          ),
        );
      }),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Obx(
            () => CustomButton(
              onTap: controller.isSubmitting.value ? () {} : controller.submitSkills,
              title: controller.isSubmitting.value
                  ? 'Saving...'.tr
                  : controller.selectedSkillIds.isNotEmpty
                      ? '${'Save Skills'.tr} (${controller.selectedSkillIds.length})'
                      : 'Save Skills'.tr,
              fillColor: controller.selectedSkillIds.isNotEmpty
                  ? AppColors.primary
                  : Colors.grey.shade300,
              textColor: controller.selectedSkillIds.isNotEmpty
                  ? Colors.white
                  : Colors.grey.shade600,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

