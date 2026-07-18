import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:nirbhor/core/app_routes/app_routes.dart';
import 'package:nirbhor/utils/app_colors/app_colors.dart';
import 'package:nirbhor/view/components/custom_button/custom_button.dart';
import 'package:nirbhor/view/components/custom_from_card/custom_from_card.dart';
import '../../../../utils/app_images/app_images.dart';
import '../../../components/custom_image/custom_image.dart' show CustomImage;
import '../../../components/custom_royel_appbar/custom_royel_appbar.dart';
import '../../../components/custom_text/custom_text.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // GetX reactive state — no setState needed
  final RxBool _isEnglish = true.obs;

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CustomText(
              text: 'Login',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const CustomText(
              text: 'Access your verified community workspace',
              fontSize: 16,
              color: Colors.black54,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Placeholder for image
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.hardEdge,
              child: CustomImage(
                imageSrc: AppImages.loginImg,
                height: 180,
                width: double.infinity,
                sizeWidth: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 32),
            // phone nyumber
            CustomFormCard(
              controller: phoneController,
              hintText: '+880 01XXX XXXXX',
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone),
              title: 'Phone Number',
            ),
            const SizedBox(height: 16),
            // custom btn password
            CustomButton(
              onTap: () {
                Get.toNamed(AppRoutes.passwordLoginScreen);
              },
              title: "Password",
              fillColor: AppColors.primary,
              textColor: Colors.white,
              fontSize: 14.sp,
              borderRadius: 8,
              icon: const Icon(Icons.lock_outlined, color: Colors.white),
            ),
            const SizedBox(height: 16),
            CustomButton(
              onTap: () {
                Get.toNamed(AppRoutes.otpVerifyScreen);
              },
              title: "OTP",
              fillColor: AppColors.secondary,
              textColor: AppColors.primary,
              fontSize: 14.sp,
              borderRadius: 8,
              isBorder: true,
              borderColor: AppColors.primary,
              borderWidth: 1,
              icon: const Icon(Icons.sms_outlined, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            //divider with or
            Row(
              children: const [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: CustomText(
                    text: 'OR',
                    color: AppColors.black,
                    left: 10,
                    right: 10,
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),
            // google login btn
            CustomButton(
              onTap: () {},
              title: "Continue with Google",
              fillColor: AppColors.secondary,
              textColor: AppColors.primary,
              fontSize: 14.sp,
              borderRadius: 8,
              isBorder: true,
              borderColor: AppColors.primary,
              borderWidth: 1,
              icon: FaIcon(FontAwesomeIcons.google, color: AppColors.primary),
            ),

            const SizedBox(height: 16),
            const CustomText(
              text:
                  'Google login only available if you linked your Gmail after registration.',
              fontSize: 13,
              color: Colors.black54,
              textAlign: TextAlign.center,
              maxLines: 2,
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(height: 24),
            //Register btn
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomText(
                  text: "Don't have an account?  ",
                  color: Colors.grey,
                ),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.registerScreen);
                  },
                  child: const CustomText(
                    text: 'Register Now',
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
}
