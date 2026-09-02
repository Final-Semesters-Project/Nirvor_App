import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nirbhor/utils/ToastMsg/toast_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/auth_controller.dart';
import '../../../../utils/app_colors/app_colors.dart';
import '../../../../utils/app_images/app_images.dart';
import '../../../components/custom_royel_appbar/custom_royel_appbar.dart';
import '../../../components/custom_text/custom_text.dart';
import '../../../components/custom_button/custom_button.dart';
import '../../../components/custom_image/custom_image.dart';

class SetupDetailsScreen extends StatelessWidget {
  const SetupDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final Map<String, dynamic>? args = Get.arguments;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomRoyelAppbar(
        titleName: 'KajerLok'.tr,
        leftIcon: true,
        centerTitleEnable: false,
        rightOnTap: () async {
          final prefs = await SharedPreferences.getInstance();
          if (Get.locale?.languageCode == 'en') {
            Get.updateLocale(const Locale('bn', 'BD'));
            await prefs.setString('languageCode', 'bn');
            await prefs.setString('countryCode', 'BD');
          } else {
            Get.updateLocale(const Locale('en', 'US'));
            await prefs.setString('languageCode', 'en');
            await prefs.setString('countryCode', 'US');
          }
        },
        rightWidget: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'English'.tr,
                style: TextStyle(
                  color: Get.locale?.languageCode == 'bn'
                      ? Colors.grey
                      : AppColors.primary,
                  fontWeight: Get.locale?.languageCode == 'bn'
                      ? FontWeight.w400
                      : FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
              TextSpan(
                text: '/',
                style: TextStyle(color: Colors.grey, fontSize: 13.sp),
              ),
              TextSpan(
                text: 'বাংলা'.tr,
                style: TextStyle(
                  color: Get.locale?.languageCode == 'bn'
                      ? AppColors.primary
                      : Colors.grey,
                  fontWeight: Get.locale?.languageCode == 'bn'
                      ? FontWeight.w700
                      : FontWeight.w400,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 24.0,
          bottom: 48.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'আপনার তথ্য দিন / Your Details'.tr,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            const SizedBox(height: 4),
            CustomText(
              text: 'Step 2 of 2: Create your service profile'.tr,
              fontSize: 14,
              color: Colors.black54,
            ),
            const SizedBox(height: 24),
            CustomText(
              text: 'আপনার পেশা / Choose Your Category'.tr,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (authController.isCategoryLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (authController.categories.isEmpty) {
                return const CustomText(text: 'No categories found');
              }
              List<Widget> rows = [];
              for (int i = 0; i < authController.categories.length; i += 2) {
                final cat1 = authController.categories[i];
                final String catId1 = cat1['id'].toString();
                final String catName1 = cat1['name'] ?? '';
                final bool isSelected1 = authController.selectedCategories
                    .contains(catId1);

                String? catId2;
                String? catName2;
                bool isSelected2 = false;

                if (i + 1 < authController.categories.length) {
                  final cat2 = authController.categories[i + 1];
                  catId2 = cat2['id'].toString();
                  catName2 = cat2['name'] ?? '';
                  isSelected2 = authController.selectedCategories.contains(
                    catId2,
                  );
                }

                Widget buildCard(String id, String name, bool selected) {
                  return GestureDetector(
                    onTap: () => authController.toggleCategory(id),
                    child: Container(
                      height: 70,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: name,
                            color: selected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                Widget buildSkills(String catId, String catName) {
                  return Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Skills for $catName',
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: 8),
                        (authController.isSkillsLoading.value &&
                                !authController.categorySkills.containsKey(
                                  catId,
                                ))
                            ? const Center(child: CircularProgressIndicator())
                            : (authController.categorySkills[catId] != null &&
                                  authController
                                      .categorySkills[catId]!
                                      .isNotEmpty)
                            ? Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: authController.categorySkills[catId]!
                                    .map((skill) {
                                      final String skillId = skill['id']
                                          .toString();
                                      final String skillName =
                                          skill['name'] ?? '';
                                      final bool isSkillSelected =
                                          authController.selectedSkills
                                              .contains(skillId);

                                      return GestureDetector(
                                        onTap: () =>
                                            authController.toggleSkill(skillId),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSkillSelected
                                                ? AppColors.primary
                                                : Colors.white,
                                            border: Border.all(
                                              color: AppColors.primary,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: CustomText(
                                            text: skillName,
                                            color: isSkillSelected
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      );
                                    })
                                    .toList(),
                              )
                            : const CustomText(
                                text: 'No skills available',
                                color: Colors.black,
                              ),
                      ],
                    ),
                  );
                }

                rows.add(
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: buildCard(catId1, catName1, isSelected1),
                          ),
                          const SizedBox(width: 12),
                          if (catId2 != null)
                            Expanded(
                              child: buildCard(catId2, catName2!, isSelected2),
                            )
                          else
                            const Expanded(child: SizedBox()),
                        ],
                      ),
                      if (isSelected1) buildSkills(catId1, catName1),
                      if (isSelected2) buildSkills(catId2!, catName2!),
                      const SizedBox(height: 12),
                    ],
                  ),
                );
              }
              return Column(children: rows);
            }),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'কাজের এলাকা / Work Radius'.tr,
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text:
                              '৫ কিলোমিটার / ${authController.workRadius.value.toInt()} KM',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => Slider(
                      value: authController.workRadius.value,
                      min: 1,
                      max: 5,
                      activeColor: AppColors.primary,
                      inactiveColor: Colors.grey.shade300,
                      onChanged: (val) {
                        authController.workRadius.value = val;
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: '1 KM',
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      CustomText(
                        text: '5 KM',
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.smartphone, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'আমার স্মার্টফোন আছে'.tr,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        CustomText(
                          text: 'I have a smartphone'.tr,
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => Switch(
                      value: authController.hasSmartphone.value,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) {
                        authController.hasSmartphone.value = val;
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Decorative Image Placeholder
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.hardEdge,
              child: CustomImage(
                imageSrc: AppImages.skills,
                width: double.infinity,
                fit: BoxFit.cover,
                height: 210,
              ),
            ),
            const SizedBox(height: 32),
            Obx(
              () => authController.isAuthLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      onTap: () {
                        if (authController.selectedCategories.isEmpty) {
                          showCustomSnackBar(
                            "Please select a category".tr,
                            isError: true,
                          );
                          return;
                        }
                        if (args != null) {
                          authController.register(
                            phone: args['phone'],
                            nameEn: args['nameEn'],
                            nameBn: args['nameBn'],
                            password: args['password'],
                            role: args['role'],
                          );
                        } else {
                          showCustomSnackBar(
                            "Missing registration info".tr,
                            isError: true,
                          );
                        }
                      },
                      title: 'Complete Registration'.tr,
                      fillColor: AppColors.primary,
                      textColor: Colors.white,
                      fontSize: 16.sp,
                      borderRadius: 8,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
