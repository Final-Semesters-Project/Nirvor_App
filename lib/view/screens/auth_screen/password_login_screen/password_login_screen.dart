import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors/app_colors.dart';
import '../../../components/custom_button/custom_button.dart';
import '../../../components/custom_from_card/custom_from_card.dart';
import '../../../components/custom_royel_appbar/custom_royel_appbar.dart';
import '../../../components/custom_text/custom_text.dart';

class PasswordLoginScreen extends StatelessWidget {
  PasswordLoginScreen({super.key});

  final TextEditingController passwordController = TextEditingController();

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            CustomText(
              text: 'Enter Password'.tr,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            CustomText(
              text: 'Please enter your password to login'.tr,
              fontSize: 16,
              color: Colors.black54,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            CustomFormCard(
              controller: passwordController,
              hintText: 'Enter your password'.tr,
              keyboardType: TextInputType.visiblePassword,
              prefixIcon: Icon(Icons.lock_outline),
              title: 'Password'.tr,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {},
                child: CustomText(
                  text: 'Forgot Password?'.tr,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              onTap: () {
                // Handle login
              },
              title: 'Login'.tr,
              fillColor: AppColors.primary,
              textColor: Colors.white,
              fontSize: 16.sp,
              borderRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}
