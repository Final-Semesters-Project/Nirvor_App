import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../../utils/app_colors/app_colors.dart';
import '../../../../components/custom_button/custom_button.dart';
import '../../../../components/custom_royel_appbar/custom_royel_appbar.dart';
import '../controller/provider_nid_upload_controller.dart';

class ProviderNidUploadScreen extends StatelessWidget {
  const ProviderNidUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderNidUploadController());

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: CustomRoyelAppbar(
        titleName: 'Upload NID'.tr,
        leftIcon: true,
        leftOnTap: () => Get.back(),
        showLanguageSwitcher: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Guidelines Card
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NID Verification Instructions'.tr,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Please capture clear, readable photos of both the front and back sides of your National ID card. Ensure all text is clearly visible without reflection or blur.'.tr,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Slot 1: NID Front
            Text(
              'NID Front Side'.tr,
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 8.h),
            Obx(
              () => _buildUploadCard(
                context: context,
                imageFile: controller.frontImage.value,
                networkUrl: controller.frontSecureUrl.value,
                isFront: true,
                controller: controller,
                title: 'NID Front'.tr,
              ),
            ),
            SizedBox(height: 20.h),

            // Slot 2: NID Back
            Text(
              'NID Back Side'.tr,
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 8.h),
            Obx(
              () => _buildUploadCard(
                context: context,
                imageFile: controller.backImage.value,
                networkUrl: controller.backSecureUrl.value,
                isFront: false,
                controller: controller,
                title: 'NID Back'.tr,
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
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
          child: Obx(() {
            final isFrontReady = controller.isFrontUploaded.value ||
                (controller.frontImage.value != null);
            final isBackReady = controller.isBackUploaded.value ||
                (controller.backImage.value != null);
            final isReady = isFrontReady && isBackReady;
            final isSubmitting = controller.isSubmitting.value;

            if (isSubmitting) {
              return Container(
                height: 52.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.2,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      controller.uploadProgressText.value.isNotEmpty
                          ? controller.uploadProgressText.value
                          : 'Submitting for verification...'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return CustomButton(
              onTap: isReady ? controller.submitNid : null,
              title: 'Submit for Verification'.tr,
              fillColor: isReady ? AppColors.primary : Colors.grey.shade300,
              textColor: isReady ? Colors.white : Colors.grey.shade600,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            );
          }),
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required BuildContext context,
    required File? imageFile,
    required String networkUrl,
    required bool isFront,
    required ProviderNidUploadController controller,
    required String title,
  }) {
    final hasImage = imageFile != null || networkUrl.isNotEmpty;
    final isUploading = isFront
        ? controller.isFrontUploading.value
        : controller.isBackUploading.value;
    final isUploaded = isFront
        ? controller.isFrontUploaded.value
        : controller.isBackUploaded.value;
    final errorText = isFront
        ? controller.frontUploadError.value
        : controller.backUploadError.value;

    if (hasImage) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: errorText.isNotEmpty
                ? Colors.red.shade400
                : (isUploaded ? AppColors.primary : Colors.grey.shade300),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(13.r)),
                  child: imageFile != null
                      ? Image.file(
                          imageFile,
                          height: 180.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          networkUrl,
                          height: 180.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(
                            height: 180.h,
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: Icon(Icons.broken_image_rounded,
                                size: 40.sp, color: Colors.grey.shade400),
                          ),
                        ),
                ),
                // Clear / Remove image button on top-right
                if (!isUploading)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.65),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => controller.clearImage(isFront),
                        child: Padding(
                          padding: EdgeInsets.all(6.r),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(13.r)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            isFront
                                ? 'Uploading Front NID...'.tr
                                : 'Uploading Back NID...'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (isUploading)
                          SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        else if (isUploaded)
                          const Icon(Icons.check_circle,
                              color: AppColors.primary, size: 20)
                        else if (errorText.isNotEmpty)
                          Icon(Icons.error_outline,
                              color: Colors.red.shade700, size: 20)
                        else
                          const Icon(Icons.photo_rounded,
                              color: Colors.grey, size: 20),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            isUploading
                                ? 'Uploading to Cloudinary...'.tr
                                : (isUploaded
                                    ? '$title ${'Selected'.tr}'
                                    : (errorText.isNotEmpty
                                        ? errorText
                                        : '$title ${'Selected'.tr}')),
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w600,
                              color: errorText.isNotEmpty
                                  ? Colors.red.shade700
                                  : (isUploaded
                                      ? AppColors.primary
                                      : const Color(0xFF1E293B)),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (errorText.isNotEmpty && imageFile != null && !isUploading) ...[
                        TextButton(
                          onPressed: () => controller.uploadToCloudinary(
                            file: imageFile,
                            side: isFront ? 'front' : 'back',
                          ),
                          child: Text(
                            'Retry Upload'.tr,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                      ],
                      TextButton.icon(
                        onPressed: isUploading
                            ? null
                            : () => controller.showImagePickerOptions(
                                  context: context,
                                  isFront: isFront,
                                ),
                        icon: const Icon(Icons.camera_alt_rounded,
                            size: 16, color: AppColors.primary),
                        label: Text(
                          'Retake'.tr,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade300, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.credit_card_rounded,
              size: 32.sp,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '$title ${'Photo Required'.tr}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.pickNidImage(
                    isFront: isFront,
                    source: ImageSource.camera,
                  ),
                  icon: const Icon(Icons.camera_alt_rounded,
                      size: 18, color: Colors.white),
                  label: Text(
                    'Take with Camera'.tr,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                    padding: EdgeInsets.symmetric(vertical: 11.h),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              OutlinedButton.icon(
                onPressed: () => controller.pickNidImage(
                  isFront: isFront,
                  source: ImageSource.gallery,
                ),
                icon: const Icon(Icons.photo_library_rounded,
                    size: 18, color: AppColors.primary),
                label: Text(
                  'Gallery'.tr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                  padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 14.w),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
