import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
        padding: EdgeInsets.all(20.w),
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
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                ),
                itemCount: authController.categories.length,
                itemBuilder: (context, index) {
                  final cat = authController.categories[index];
                  final String catId = cat['_id'] ?? '';
                  final String catName = cat['name'] ?? '';
                  final bool isSelected =
                      authController.selectedCategory.value == catId;

                  return GestureDetector(
                    onTap: () {
                      authController.fetchSkills(catId);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: catName,
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
            const SizedBox(height: 24),
            Obx(() {
              if (authController.isSkillsLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (authController.selectedCategory.value.isNotEmpty &&
                  authController.skills.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'আপনার দক্ষতা / Choose Your Skills'.tr,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: authController.skills.map((skill) {
                        final String skillId = skill['_id'] ?? '';
                        final String skillName = skill['name'] ?? '';
                        final bool isSelected = authController.selectedSkills
                            .contains(skillId);

                        return GestureDetector(
                          onTap: () => authController.toggleSkill(skillId),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white,
                              border: Border.all(color: AppColors.primary),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: CustomText(
                              text: skillName,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }
              return const SizedBox.shrink();
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
                      max: 10,
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
                        text: '10 KM',
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
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.hardEdge,
              child: CustomImage(
                imageSrc:
                    AppImages.loginImg, // Using existing placeholder image
                height: 120,
                width: double.infinity,
                sizeWidth: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 32),
            Obx(
              () => authController.isAuthLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      onTap: () {
                        if (authController.selectedCategory.isEmpty) {
                          Get.snackbar("Error", "Please select a category".tr);
                          return;
                        }
                        if (args != null) {
                          authController.register(
                            phone: args['phone'],
                            nameEn: args['name_en'],
                            nameBn: args['name_bn'],
                            password: args['password'],
                            role: args['role'],
                          );
                        } else {
                          Get.snackbar("Error", "Missing registration info".tr);
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
