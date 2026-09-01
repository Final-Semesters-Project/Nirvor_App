import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/app_routes/app_routes.dart';
import '../../../../utils/app_colors/app_colors.dart';
import '../../../components/custom_royel_appbar/custom_royel_appbar.dart';
import '../../../components/custom_text/custom_text.dart';

class RegisterMethodScreen extends StatelessWidget {
  const RegisterMethodScreen({super.key});

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
          children: [
            const SizedBox(height: 16),
            CustomText(
              text: 'Create Account'.tr,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CustomText(
              text:
                  'Join our trusted community of service providers and seekers. Select your preferred registration method to get started.'
                      .tr,
              fontSize: 14,
              color: Colors.black54,
              textAlign: TextAlign.center,
              maxLines: 4,
            ),
            const SizedBox(height: 40),
            _buildMethodCard(
              title: 'Register with OTP'.tr,
              icon: Icons.phone_android,
              onTap: () {
                Get.toNamed(AppRoutes.otpVerifyScreen);
              },
            ),
            const SizedBox(height: 24),
            _buildMethodCard(
              title: 'Register with Password'.tr,
              icon: Icons.lock_outline,
              onTap: () {
                Get.toNamed(AppRoutes.registerScreen);
              },
            ),
            const SizedBox(height: 48),
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
                    text: 'Login'.tr,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            CustomText(
              text: title,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
