import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../utils/app_colors/app_colors.dart';
import '../../../../../../utils/app_const/app_const.dart';
import '../../../../components/custom_nav_bar/provider_nav_bar.dart';
import '../../../../components/custom_netwrok_image/custom_network_image.dart';
import '../../../../components/custom_text/custom_text.dart' show CustomText;
import '../controller/provider_home_controller.dart';
import '../model/provider_dashboard_model.dart';
import 'provider_add_skill_screen.dart';
import 'provider_nid_upload_screen.dart';
import 'provider_nid_rejection_screen.dart';
import '../../../../../../model/review_model.dart';
import '../../../../../../utils/ToastMsg/toast_message.dart';
import 'provider_all_reviews_screen.dart';

class ProviderHomeScreen extends StatelessWidget {
  const ProviderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProviderHomeController controller = Get.put(ProviderHomeController());

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.dashboardData.value == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          final data = controller.dashboardData.value;
          final status = controller.verificationStatus.value.toLowerCase();
          final level = controller.verificationLevel.value.toLowerCase();

          String levelText;
          double progressVal;
          Color statusColor;

          if (status == 'approved' || level == 'verified' || level == 'trusted') {
            levelText = (level == 'trusted') ? 'TRUSTED'.tr : 'VERIFIED'.tr;
            progressVal = 1.0;
            statusColor = AppColors.primary;
          } else if (status == 'pending') {
            levelText = 'Verification Pending'.tr;
            progressVal = 0.66;
            statusColor = Colors.amber.shade700;
          } else if (status == 'rejected') {
            levelText = 'Verification Rejected'.tr;
            progressVal = 0.25;
            statusColor = Colors.redAccent;
          } else {
            levelText = 'UNVERIFIED'.tr;
            progressVal = 0.25;
            statusColor = AppColors.primary;
          }

          final ratingStr = data?.averageRating != null
              ? data!.averageRating!.toStringAsFixed(1)
              : '0.0';
          final totalJobs = data?.totalJobsDone ?? 0;

          final isBn = Get.locale?.languageCode == 'bn';

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => controller.getDashboardData(showLoading: false),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Profile Header (aligned to start)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomNetworkImage(
                        imageUrl: (data?.photoUrl != null &&
                                data!.photoUrl!.isNotEmpty)
                            ? data.photoUrl!
                            : AppConstants.profileImage,
                        width: 60.w,
                        height: 60.w,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: (data?.name != null && data!.name.isNotEmpty)
                                  ? data.name
                                  : 'Service Provider'.tr,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            CustomText(
                              text: (data?.skills != null &&
                                      data!.skills.isNotEmpty)
                                  ? data.skills.map((s) => s.name).join(', ')
                                  : 'Service Provider'.tr,
                              fontSize: 13.sp,
                              color: Colors.black54,
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // 2. Availability Toggle (Beautiful, clear black text, dynamic status)
                  Obx(
                    () {
                      final isOnline = controller.isAvailable.value;
                      return GestureDetector(
                        onTap: controller.isUpdatingAvailability.value
                            ? null
                            : () => controller.toggleAvailability(!isOnline),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: isOnline
                                ? AppColors.primary.withValues(alpha: 0.35)
                                : Colors.grey.shade300,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isOnline
                                  ? AppColors.primary.withValues(alpha: 0.06)
                                  : Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 10.w,
                                    height: 10.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isOnline
                                          ? const Color(0xFF10B981)
                                          : Colors.grey.shade400,
                                      boxShadow: isOnline
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF10B981)
                                                    .withValues(alpha: 0.45),
                                                blurRadius: 6,
                                                spreadRadius: 1.5,
                                              )
                                            ]
                                          : null,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CustomText(
                                          text: isOnline
                                              ? 'I am Available'.tr
                                              : 'I am Offline'.tr,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF111827),
                                          textAlign: TextAlign.start,
                                        ),
                                        SizedBox(height: 2.h),
                                        CustomText(
                                          text: isOnline
                                              ? 'Ready to accept jobs'.tr
                                              : 'Not accepting jobs right now'.tr,
                                          fontSize: 11.5.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black54,
                                          textAlign: TextAlign.start,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            controller.isUpdatingAvailability.value
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  )
                                : Transform.scale(
                                    scale: 0.9,
                                    child: Switch(
                                      value: isOnline,
                                      onChanged: controller.toggleAvailability,
                                      activeThumbColor: Colors.white,
                                      activeTrackColor: AppColors.primary,
                                      inactiveThumbColor: Colors.white,
                                      inactiveTrackColor: Colors.grey.shade300,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                  ),
                  SizedBox(height: 16.h),

                  // 3. Verification Card (Dynamic with users/me status, progressbar, and NID upload)
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
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
                            Icon(
                              (status == 'approved' || level == 'verified' || level == 'trusted')
                                  ? Icons.verified
                                  : (status == 'pending')
                                      ? Icons.hourglass_top_rounded
                                      : (status == 'rejected')
                                          ? Icons.error_outline_rounded
                                          : Icons.shield_outlined,
                              color: statusColor,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            CustomText(
                              text: '${'VERIFICATION LEVEL'.tr}: ',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              textAlign: TextAlign.start,
                            ),
                            CustomText(
                              text: levelText,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        // Primary colored progress bar
                        LinearProgressIndicator(
                          value: progressVal,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 8.h,
                        ),
                        SizedBox(height: 16.h),

                        // Rejection Reason Banner if rejected
                        if (status == 'rejected') ...[
                          InkWell(
                            onTap: () => Get.to(() => const ProviderNidRejectionScreen()),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(bottom: 12.h),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          'আপনার NID যাচাই প্রত্যাখ্যান করা হয়েছে / NID Verification Rejected',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.red.shade900,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 13,
                                        color: Colors.red,
                                      ),
                                    ],
                                  ),
                                  if (controller.verificationRejectionReason.value.isNotEmpty) ...[
                                    SizedBox(height: 6.h),
                                    Text(
                                      '${'Rejection Reason'.tr}: "${controller.verificationRejectionReason.value}"',
                                      style: TextStyle(
                                        fontSize: 11.5.sp,
                                        color: Colors.red.shade800,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: 6.h),
                                  Text(
                                    'বিস্তারিত কারণ দেখতে ও পুনরায় আপলোড করতে এখানে ট্যাপ করুন ›',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        // Action button based on verification_status
                        if (status == 'approved' || level == 'verified' || level == 'trusted')
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: AppColors.primary,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 6.w),
                                  CustomText(
                                    text: level == 'trusted'
                                        ? 'Trusted Provider'.tr
                                        : 'Verified Provider'.tr,
                                    color: AppColors.primary,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (status == 'pending')
                          InkWell(
                            onTap: () {
                              showCustomSnackBar(
                                'আপনার NID তথ্য পর্যালোচনায় রয়েছে। অ্যাডমিনের অনুমোদন সম্পন্ন হওয়া পর্যন্ত অপেক্ষা করুন।'
                                    .tr,
                                isError: false,
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.h, horizontal: 12.w),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.amber.shade300),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.access_time_rounded,
                                      color: Colors.amber.shade800,
                                      size: 18.sp),
                                  SizedBox(width: 8.w),
                                  Flexible(
                                    child: Text(
                                      'Your documents are under review by admin'
                                          .tr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.amber.shade900,
                                        fontSize: 12.5.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (status == 'rejected')
                          // Rejected -> View Rejection Reason & Re-upload
                          InkWell(
                            onTap: () => Get.to(() => const ProviderNidRejectionScreen()),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red.shade400, width: 1.2),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.red.shade50,
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline_rounded,
                                      color: Colors.red.shade700,
                                      size: 18.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    CustomText(
                                      text: 'View Rejection Details & Re-upload'.tr,
                                      color: Colors.red.shade800,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          // 'not_initiated' -> Let provider upload NID
                          InkWell(
                            onTap: () => Get.to(() => const ProviderNidUploadScreen()),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.primary, width: 1.2),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_outlined,
                                      color: AppColors.primary,
                                      size: 18.sp,
                                    ),
                                    SizedBox(width: 6.w),
                                    CustomText(
                                      text: 'Upload NID to get Verified'.tr,
                                      color: AppColors.primary,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // 4. Rating Card
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
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
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            CustomText(
                              text: ratingStr,
                              color: Colors.white,
                              fontSize: 42.sp,
                              fontWeight: FontWeight.bold,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(width: 4.w),
                            Icon(Icons.star, color: Colors.amber, size: 36.sp),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        CustomText(
                          text: 'based_on_completed_jobs'
                              .trParams({'count': totalJobs.toString()}),
                          color: Colors.white70,
                          fontSize: 11.sp,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // 5. Jobs Done Card
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
                          text: totalJobs.toString(),
                          color: AppColors.primary,
                          fontSize: 42.sp,
                          fontWeight: FontWeight.bold,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4.h),
                        CustomText(
                          text: 'Jobs Done'.tr,
                          color: Colors.black54,
                          fontSize: 13.sp,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // 6. Work Radius Card
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
                              textAlign: TextAlign.start,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Obx(
                                () => CustomText(
                                  text:
                                      '${controller.workRadius.value.toInt()} KM',
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  textAlign: TextAlign.center,
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
                              overlayColor:
                                  AppColors.primary.withValues(alpha: 0.2),
                              trackHeight: 6,
                            ),
                            child: Slider(
                              value: controller.workRadius.value.clamp(1.0, 5.0),
                              min: 1,
                              max: 5,
                              divisions: 4,
                              onChangeStart: (val) =>
                                  controller.onRadiusDragStart(),
                              onChanged: (val) =>
                                  controller.workRadius.value = val,
                              onChangeEnd: (val) =>
                                  controller.updateWorkingRadius(val),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: '1 KM',
                              fontSize: 11.sp,
                              color: Colors.grey,
                              textAlign: TextAlign.start,
                            ),
                            CustomText(
                              text: '5 KM',
                              fontSize: 11.sp,
                              color: Colors.grey,
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // 7. My Skills Card
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
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(height: 16.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: [
                            if (data != null && data.skills.isNotEmpty)
                              ...data.skills.map(
                                (skill) => _buildSkillChip(
                                  context,
                                  skill,
                                  controller,
                                ),
                              ),
                            _buildAddSkillBtn(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // 8. Latest Reviews Container (under My Skills)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
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
                        // Reviews Header with Title & View All Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 22,
                                ),
                                SizedBox(width: 6.w),
                                CustomText(
                                  text: 'Customer Reviews'.tr,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  textAlign: TextAlign.start,
                                ),
                                SizedBox(width: 8.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 7.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    ratingStr,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                Get.to(() => const ProviderAllReviewsScreen());
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 4.h,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'View All'.tr,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 11,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),

                        // Real Reviews List (Up to 3 latest reviews)
                        Obx(() {
                          if (controller.isLoadingReviews.value &&
                              controller.reviewsList.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            );
                          }

                          if (controller.reviewsList.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.rate_review_outlined,
                                      size: 32.sp,
                                      color: Colors.grey.shade400,
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      isBn
                                          ? 'এখনো কোনো রিভিউ পাওয়া যায়নি'
                                          : 'No customer reviews yet',
                                      style: TextStyle(
                                        fontSize: 12.5.sp,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: controller.reviewsList
                                .take(3)
                                .map((review) =>
                                    _buildReviewItem(review, isBn))
                                .toList(),
                          );
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          );
        }),
      ),
      bottomNavigationBar: const ProviderNavBar(currentIndex: 0),
    );
  }

  Widget _buildReviewItem(ReviewItemModel review, bool isBn) {
    final String reviewerDisplayName = review.isAnonymous
        ? (isBn ? 'নাম প্রকাশে অনিচ্ছুক' : 'Anonymous Client')
        : (review.reviewerName.isNotEmpty
            ? review.reviewerName
            : (isBn ? 'গ্রাহক' : 'Client'));

    final String initial = reviewerDisplayName.isNotEmpty
        ? reviewerDisplayName[0].toUpperCase()
        : 'C';

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14.r,
                    backgroundColor: review.isAnonymous
                        ? Colors.grey.shade200
                        : AppColors.primary.withValues(alpha: 0.12),
                    child: review.isAnonymous
                        ? Icon(Icons.person_outline_rounded,
                            size: 15.sp, color: Colors.grey.shade600)
                        : Text(
                            initial,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reviewerDisplayName,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        review.localizedTimeAgo(isBn),
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 15.sp,
                  ),
                ),
              ),
            ],
          ),
          if ((review.comment ?? '').trim().isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              review.comment!,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.black87,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkillChip(
    BuildContext context,
    ProviderDashboardSkill skill,
    ProviderHomeController controller,
  ) {
    return Container(
      padding: EdgeInsets.only(left: 14.w, right: 6.w, top: 6.h, bottom: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4.w),
          InkWell(
            onTap: () => _showDeleteSkillDialog(context, skill, controller),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Icon(
                Icons.close_rounded,
                color: Colors.white.withValues(alpha: 0.95),
                size: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteSkillDialog(
    BuildContext context,
    ProviderDashboardSkill skill,
    ProviderHomeController controller,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 24),
            const SizedBox(width: 8),
            Text(
              'Remove Skill'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove "@skill"?'.trParams({'skill': skill.name}),
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('No'.tr, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Get.back();
              controller.removeSkill(skill.id);
            },
            child: Text('Yes'.tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddSkillBtn() {
    return InkWell(
      onTap: () => Get.to(() => const ProviderAddSkillScreen()),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: AppColors.primary, size: 16.sp),
            SizedBox(width: 4.w),
            CustomText(
              text: 'Add Skill'.tr,
              color: AppColors.primary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
