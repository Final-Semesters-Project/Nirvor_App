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
  RegisterScreen({Key? key}) : super(key: key);

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            CustomText(
              text: _isEnglish.value ? 'Create Account' : 'অ্যাকাউন্ট তৈরি করুন',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            const SizedBox(height: 40),
            CustomFormCard(
              controller: phoneController,
              hintText: '1XXX XXXXXX',
              keyboardType: TextInputType.phone,
              title: _isEnglish.value ? 'Phone Number' : 'ফোন নম্বর',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomText(
                      text: 'BD +880',
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
              hintText: _isEnglish.value ? 'Enter your full name' : 'আপনার পুরো নাম লিখুন',
              title: _isEnglish.value ? 'Full Name' : 'পুরো নাম',
            ),
            const SizedBox(height: 16),
            CustomFormCard(
              controller: passwordController,
              hintText: '********',
              title: _isEnglish.value ? 'Password' : 'পাসওয়ার্ড',
              isPassword: true,
            ),
            const SizedBox(height: 16),
            CustomFormCard(
              controller: confirmPasswordController,
              hintText: '********',
              title: _isEnglish.value ? 'Confirm Password' : 'পাসওয়ার্ড নিশ্চিত করুন',
              isPassword: true,
            ),
            const SizedBox(height: 32),
            CustomButton(
              onTap: () {
                // Handle Registration
              },
              title: _isEnglish.value ? 'Continue' : 'চালিয়ে যান',
              fillColor: AppColors.primary,
              textColor: Colors.white,
              fontSize: 16.sp,
              borderRadius: 8,
            ),
            const SizedBox(height: 24),
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
                  child: CustomText(
                    text: _isEnglish.value ? 'Log In' : 'লগ ইন',
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
                    Icon(Icons.verified_user_outlined, color: Colors.grey.shade600, size: 16),
                    const SizedBox(width: 8),
                    CustomText(
                      text: 'Verified Trust Ecosystem',
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomText(
                  text: 'By continuing, you agree to our Terms of Service & Privacy Policy',
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
    ));
  }
}
