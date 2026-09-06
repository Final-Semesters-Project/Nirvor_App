import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../utils/app_colors/app_colors.dart';
import '../../../../components/custom_nav_bar/provider_nav_bar.dart';
import '../../../../components/custom_royel_appbar/custom_royel_appbar.dart';
import '../../../../components/custom_text/custom_text.dart' show CustomText;
import '../controller/provider_home_controller.dart';

class ProviderHomeScreen extends StatelessWidget {
  const ProviderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProviderHomeController controller = Get.put(ProviderHomeController());

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: CustomRoyelAppbar(
        titleName: 'KajerLok | কাজেরলোক',
        showLanguageSwitcher: true,
        leftIcon: false,
        centerTitleEnable: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Row(
              children: [
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: NetworkImage(
                          'https://randomuser.me/api/portraits/men/32.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'Md. Rafiqul Islam',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      CustomText(
                        text: 'Professional Technician',
                        fontSize: 13.sp,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Availability Toggle
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: 'I am Available'.tr,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  Obx(
                    () => Switch(
                      value: controller.isAvailable.value,
                      onChanged: controller.toggleAvailability,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.primary,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Verification Card
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_outlined, color: AppColors.primary, size: 20.sp),
                      SizedBox(width: 8.w),
                      CustomText(
                        text: '${'VERIFICATION LEVEL'.tr}: ',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      CustomText(
                        text: 'BASIC'.tr,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  LinearProgressIndicator(
                    value: 0.3,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 8.h,
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CustomText(
                        text: 'Upload NID to get Verified'.tr,
                        color: AppColors.primary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Rating Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha:0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                children: [
                  CustomText(
                    text: 'My Rating'.tr,
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      CustomText(
                        text: '4.6',
                        color: Colors.white,
                        fontSize: 42.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(width: 4.w),
                      Icon(Icons.star, color: Colors.white, size: 36.sp),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  CustomText(
                    text: 'Based on 24 completed jobs'.tr,
                    color: Colors.white70,
                    fontSize: 11.sp,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Customer Feedback Summary
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF757E7E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology_outlined, color: Colors.white, size: 20.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: CustomText(
                          text: 'CUSTOMER FEEDBACK SUMMARY'.tr,
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  CustomText(
                    text: '"${'Customers appreciate this provider\'s punctuality and clean work.'.tr}"',
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Jobs Done
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  CustomText(
                    text: '24',
                    color: AppColors.primary,
                    fontSize: 42.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 4.h),
                  CustomText(
                    text: 'Jobs Done'.tr,
                    color: Colors.black54,
                    fontSize: 13.sp,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Work Radius
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: 'Work Radius'.tr,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Obx(
                          () => CustomText(
                            text: '${controller.workRadius.value.toInt()} KM',
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Obx(
                    () => SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: Colors.grey.shade200,
                        thumbColor: AppColors.primary,
                        overlayColor: AppColors.primary.withValues(alpha:0.2),
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: controller.workRadius.value,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        onChanged: (val) => controller.workRadius.value = val,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(text: '1 KM', fontSize: 11.sp, color: Colors.grey),
                      CustomText(text: '10 KM', fontSize: 11.sp, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // My Skills
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'MY SKILLS'.tr,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  SizedBox(height: 16.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _buildSkillChip('Electrician'),
                      _buildSkillChip('AC Repair'),
                      _buildSkillChip('Wiring'),
                      _buildAddSkillBtn(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ProviderNavBar(currentIndex: 0),
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            text: label,
            color: Colors.white,
            fontSize: 13.sp,
          ),
          SizedBox(width: 6.w),
          Icon(Icons.close, color: Colors.white, size: 14.sp),
        ],
      ),
    );
  }

  Widget _buildAddSkillBtn() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey, style: BorderStyle.solid),
      ),
      child: CustomText(
        text: '+ Add Skill'.tr,
        color: Colors.black54,
        fontSize: 13.sp,
      ),
    );
  }
}
