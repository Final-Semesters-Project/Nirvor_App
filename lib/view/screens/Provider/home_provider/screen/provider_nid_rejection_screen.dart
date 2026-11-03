import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../utils/app_colors/app_colors.dart';
import '../../../../components/custom_royel_appbar/custom_royel_appbar.dart';
import '../controller/provider_nid_rejection_controller.dart';
import 'provider_nid_upload_screen.dart';

class ProviderNidRejectionScreen extends StatelessWidget {
  const ProviderNidRejectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProviderNidRejectionController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CustomRoyelAppbar(
        titleName: 'Nirbhor | নির্ভর',
        leftIcon: true,
        leftOnTap: () => Get.back(),
        showLanguageSwitcher: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        final reason = controller.rejectionReason.value.trim();
        final displayReason = reason.isNotEmpty
            ? reason
            : "The uploaded photo was blurry. Please ensure all details are clearly visible.";
        final frontUrl = controller.nidUrlFront.value;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main Alert Container (matching Screenshot 1)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0xFFFCA5A5),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Red / Pink Banner Header
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(15.r),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: const Color(0xFFDC2626),
                            size: 34.sp,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "আপনার NID যাচাই প্রত্যাখ্যান করা হয়েছে",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF991B1B),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            "NID Verification Rejected",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFFB91C1C),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Inside Card Content
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Rejection Reason Label
                          Text(
                            "Rejection Reason / প্রত্যাখ্যানের কারণ:",
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF475569),
                            ),
                          ),
                          SizedBox(height: 8.h),

                          // Quoted Reason Box
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              "“$displayReason”",
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFF1E293B),
                                height: 1.45,
                              ),
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Rejected Image Preview
                          _buildRejectedImagePreview(frontUrl),

                          SizedBox(height: 16.h),

                          // Re-upload Documents Button (Deep Teal)
                          SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.to(() => const ProviderNidUploadScreen());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F766E),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.upload_file_rounded,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    "Re-upload Documents / পুনরায় আপলোড করুন",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 10.h),

                          // Contact Support Button (Outlined)
                          SizedBox(
                            width: double.infinity,
                            height: 48.h,
                            child: OutlinedButton(
                              onPressed: () => _contactSupport(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.grey.shade400,
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                              child: Text(
                                "Contact Support / সহায়তার জন্য যোগাযোগ করুন",
                                style: TextStyle(
                                  color: const Color(0xFF475569),
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // "What went wrong?" Breakdown Card (matching Screenshot 2)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: const Color(0xFFDC2626),
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "কী সমস্যা হয়েছে? / What went wrong?",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // Problem item 1
                    _buildIssueItem(
                      title: "অস্পষ্ট ছবি (Blurry Photo)",
                      description:
                          "আপনার আপলোড করা NID কার্ডের ছবি পরিষ্কার ছিল না।",
                    ),

                    SizedBox(height: 12.h),

                    // Problem item 2
                    _buildIssueItem(
                      title: "তথ্য অস্পষ্ট (Illegible Details)",
                      description: "কার্ডের নাম বা নম্বর পড়া যাচ্ছে না।",
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // "Tips for Good Photo" Card (matching Screenshot 2)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: const Color(0xFF16A34A),
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "ভালো ছবির জন্য কিছু টিপস / Tips",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    _buildTipRow(
                      icon: Icons.wb_sunny_outlined,
                      text: "পর্যাপ্ত আলোতে ছবি তুলুন (Use good lighting)",
                    ),
                    SizedBox(height: 10.h),
                    _buildTipRow(
                      icon: Icons.crop_free_rounded,
                      text: "কার্ডটি সমতল জায়গায় রাখুন (Place card on flat surface)",
                    ),
                    SizedBox(height: 10.h),
                    _buildTipRow(
                      icon: Icons.visibility_outlined,
                      text: "সব তথ্য ও ৪টি কোণা স্পষ্ট রাখুন (Keep all 4 edges visible)",
                    ),
                    SizedBox(height: 10.h),
                    _buildTipRow(
                      icon: Icons.flash_off_rounded,
                      text: "ক্যামেরার ফ্ল্যাশ বা প্রতিফলন এড়িয়ে চলুন (Avoid glare)",
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRejectedImagePreview(String imageUrl) {
    return Container(
      height: 160.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Image if available, otherwise stylized card mockup
            if (imageUrl.isNotEmpty)
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildCardPlaceholder(),
                ),
              )
            else
              _buildCardPlaceholder(),

            // Dark dim overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.55),
              ),
            ),

            // Rejected Badge and Icon
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.do_not_disturb_alt_rounded,
                  color: Colors.white.withOpacity(0.9),
                  size: 38.sp,
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    "REJECTED IMAGE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPlaceholder() {
    return Container(
      color: const Color(0xFF334155),
      child: Center(
        child: Icon(
          Icons.badge_outlined,
          size: 60.sp,
          color: Colors.white24,
        ),
      ),
    );
  }

  Widget _buildIssueItem({
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close_rounded,
            color: const Color(0xFFDC2626),
            size: 14.sp,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF64748B),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: const Color(0xFF16A34A),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF15803D),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _contactSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Text(
              "Contact Support / সহায়তা যোগাযোগ",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "ভেরিফিকেশন সংক্রান্ত যেকোনো সহায়তার জন্য আমাদের সাথে যোগাযোগ করুন।",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5.sp,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF0F766E),
                child: Icon(Icons.phone, color: Colors.white),
              ),
              title: const Text("সরাসরি কল করুন (Call Support)"),
              subtitle: const Text("+880 1700-000000"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                Navigator.pop(ctx);
                final uri = Uri.parse("tel:+8801700000000");
                try {
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                } catch (e) {
                  debugPrint("Error launching phone dialer: $e");
                }
              },
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}

