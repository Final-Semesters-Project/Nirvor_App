import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        titleName: 'KajerLok',
        leftIcon: true,
        centerTitleEnable: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            const CustomText(
              text: 'Enter Password',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const CustomText(
              text: 'Please enter your password to login',
              fontSize: 16,
              color: Colors.black54,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            CustomFormCard(
              controller: passwordController,
              hintText: 'Enter your password',
              keyboardType: TextInputType.visiblePassword,
              prefixIcon: const Icon(Icons.lock_outline),
              title: 'Password',
              isPassword: true,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {},
                child: const CustomText(
                  text: 'Forgot Password?',
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
              title: "Login",
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
