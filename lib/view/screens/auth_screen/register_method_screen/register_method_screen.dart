import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/app_routes/app_routes.dart';
import '../../../../utils/app_colors/app_colors.dart';
import '../../../components/custom_royel_appbar/custom_royel_appbar.dart';
import '../../../components/custom_text/custom_text.dart';

class RegisterMethodScreen extends StatelessWidget {
  const RegisterMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RxBool _isEnglish = true.obs;

    return Obx(() => Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomRoyelAppbar(
        titleName: 'KajerLok',
        leftIcon: true,
        centerTitleEnable: false,
        rightOnTap: () => _isEnglish.toggle(),
        rightWidget: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: _isEnglish.value ? 'English' : 'বাংলা',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
              TextSpan(
                text: '/',
                style: TextStyle(color: Colors.grey, fontSize: 13.sp),
              ),
              TextSpan(
                text: _isEnglish.value ? 'বাংলা' : 'English',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CustomText(
              text: _isEnglish.value ? 'Create Account' : 'অ্যাকাউন্ট খুলুন',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const CustomText(
              text: 'Join our trusted community of service providers and seekers. Select your preferred registration method to get started.',
              fontSize: 14,
              color: Colors.black54,
              textAlign: TextAlign.center,
              maxLines: 4,
            ),
            const SizedBox(height: 40),
            _buildMethodCard(
              title: _isEnglish.value ? 'Register with OTP' : 'OTP দিয়ে রেজিস্ট্রেশন করুন',
              icon: Icons.phone_android,
              onTap: () {
                Get.toNamed(AppRoutes.registerScreen);
              },
            ),
            const SizedBox(height: 24),
            _buildMethodCard(
              title: _isEnglish.value ? 'Register with Password' : 'পাসওয়ার্ড দিয়ে রেজিস্ট্রেশন করুন',
              icon: Icons.lock_outline,
              onTap: () {
                Get.toNamed(AppRoutes.registerScreen);
              },
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomText(
                  text: 'Already have an account? ',
                  color: Colors.black54,
                ),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.loginScreen);
                  },
                  child: const CustomText(
                    text: 'Login',
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ));
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
              child: Icon(
                icon,
                color: Colors.white,
                size: 40,
              ),
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
