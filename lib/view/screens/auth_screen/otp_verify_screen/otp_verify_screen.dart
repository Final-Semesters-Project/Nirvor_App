import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import '../../../../utils/app_colors/app_colors.dart';
import '../../../components/custom_button/custom_button.dart';
import '../../../components/custom_pin_code/custom_pin_code.dart';
import '../../../components/custom_royel_appbar/custom_royel_appbar.dart';
import '../../../components/custom_text/custom_text.dart';

class OtpVerifyScreen extends StatelessWidget {
  OtpVerifyScreen({super.key});

  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomRoyelAppbar(
        titleName: 'KajerLok'.tr,
        leftIcon: true,
        centerTitleEnable: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Shield icon container
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.security, color: Colors.white, size: 40),
              ),
            ),
            const SizedBox(height: 24),
            CustomText(
              text: 'Verify OTP'.tr,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            const SizedBox(height: 8),
            CustomText(
              text: 'We sent a code to +880 XXXXX'.tr,
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
            const SizedBox(height: 32),
            // OTP Fields
            CustomPinCode(controller: otpController),
            const SizedBox(height: 24),
            // Resend text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  text: "Didn't receive the code? ",
                  color: Colors.grey.shade600,
                ),
                GestureDetector(
                  onTap: () {},
                  child: CustomText(
                    text: 'Resend OTP (30s)'.tr,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Verify Button
            CustomButton(
              onTap: () {},
              title: 'Verify'.tr,
              fillColor: AppColors.primary,
              textColor: Colors.white,
              fontSize: 16.sp,
              borderRadius: 8,
            ),
            const SizedBox(height: 48),
            // Verified Trust banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Verified Trust'.tr,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 4),
                        CustomText(
                          text:
                              'This verification helps us keep the KajerLok community safe and reliable for everyone.'
                                  .tr,
                          color: Colors.grey.shade700,
                          fontSize: 12,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
