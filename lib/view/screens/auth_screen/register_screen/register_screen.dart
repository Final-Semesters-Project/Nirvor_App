import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/app_routes/app_routes.dart';
import '../../../../utils/app_colors/app_colors.dart';
import '../../../components/custom_button/custom_button.dart';
import '../../../components/custom_from_card/custom_from_card.dart';
import '../../../components/custom_royel_appbar/custom_royel_appbar.dart';
import '../../../components/custom_text/custom_text.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomRoyelAppbar(
        titleName: 'KajerLok'.tr,
        leftIcon: true,
        centerTitleEnable: false,
        showLanguageSwitcher: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            CustomText(
              text: 'Create Account'.tr,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            const SizedBox(height: 40),
            CustomFormCard(
              controller: phoneController,
              hintText: '1XXX XXXXXX'.tr,
              keyboardType: TextInputType.phone,
              title: 'Phone Number'.tr,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      text: 'BD +880'.tr,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 24,
                      width: 1,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomFormCard(
              controller: nameController,
              hintText: 'Enter your full name'.tr,
              title: 'Full Name'.tr,
            ),
            const SizedBox(height: 16),
            CustomFormCard(
              controller: passwordController,
              hintText: '********'.tr,
              title: 'Password'.tr,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            CustomFormCard(
              controller: confirmPasswordController,
              hintText: '********'.tr,
              title: 'Confirm Password'.tr,
              isPassword: true,
            ),
            const SizedBox(height: 32),
            CustomButton(
              onTap: () {
                // Handle Registration
              },
              title: 'Continue'.tr,
              fillColor: AppColors.primary,
              textColor: Colors.white,
              fontSize: 16.sp,
              borderRadius: 8,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  text: 'Already have an account? '.tr,
                  color: Colors.black54,
                ),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.loginScreen);
                  },
                  child: CustomText(
                    text: 'Log In'.tr,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: Colors.grey.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    CustomText(
                      text: 'Verified Trust Ecosystem'.tr,
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomText(
                  text:
                      'By continuing, you agree to our Terms of Service & Privacy Policy'
                          .tr,
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
