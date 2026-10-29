import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nirbhor/utils/ToastMsg/toast_message.dart';
import 'package:nirbhor/view/components/custom_text_field/custom_text_field.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authController.categories.isEmpty && !authController.isCategoryLoading.value) {
        authController.fetchCategories();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomRoyelAppbar(
        titleName: 'KajerLok'.tr,
        leftIcon: true,
        centerTitleEnable: false,
        showLanguageSwitcher: true,
        onLanguageChanged: () {
          authController.fetchCategories();
          if (authController.locationController.text.isNotEmpty) {
            authController.searchLocation(authController.locationController.text);
          }
        },
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 10.0,
          bottom: 48.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'Step 2 of 2: Create your service profile'.tr,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            const SizedBox(height: 24),
            CustomText(
              text: 'আপনার পেশা / Choose Your Category'.tr,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (authController.isCategoryLoading.value) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }
              if (authController.categories.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      children: [
                        CustomText(
                          text: 'No categories found'.tr,
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => authController.fetchCategories(),
                          icon: const Icon(Icons.refresh, color: AppColors.primary),
                          label: Text(
                            'Retry'.tr,
                            style: const TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
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

            // Location Selection Section
            const SizedBox(height: 16),
            CustomText(
              text: 'Your Location'.tr,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              textEditingController: authController.locationController,
              hintText: 'Search location...'.tr,
              hintStyle: const TextStyle(color: Colors.grey),
              fillColor: Colors.white,
              fieldBorderColor: Colors.grey.shade300,
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                color: AppColors.primary,
              ),
              onChanged: (val) => authController.onLocationChanged(val),
            ),
            Obx(() {
              if (authController.isLocationSearching.value) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }
              if (authController.locationSuggestions.isEmpty) {
                return const SizedBox();
              }
              return Container(
                margin: const EdgeInsets.only(top: 8),
                constraints: const BoxConstraints(maxHeight: 220),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: authController.locationSuggestions.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, thickness: 0.5),
                      itemBuilder: (context, index) {
                        final suggestion =
                            authController.locationSuggestions[index];
                        final String name =
                            suggestion['name']?.toString() ?? '';
                        final String displayName =
                            suggestion['display_name']?.toString() ?? '';
                        final String secondaryText =
                            suggestion['secondary_text']?.toString() ?? '';
                        final String sub = secondaryText.isNotEmpty
                            ? secondaryText
                            : (displayName != name ? displayName : '');
                        return ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            name.isNotEmpty ? name : displayName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: sub.isNotEmpty
                              ? Text(
                                  sub,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          onTap: () {
                            authController.selectLocation(suggestion);
                            FocusScope.of(context).unfocus();
                          },
                        );
                      },
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
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
                          text: '${authController.workRadius.value.toInt()} KM'
                              .tr,
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
                        text: '1 KM'.tr,
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      CustomText(
                        text: '5 KM'.tr,
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
