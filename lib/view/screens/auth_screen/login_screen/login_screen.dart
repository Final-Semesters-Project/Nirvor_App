import 'package:flutter/material.dart';
import 'package:nirbhor/utils/ToastMsg/toast_message.dart';
import '../controller/auth_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nirbhor/core/app_routes/app_routes.dart';
import 'package:nirbhor/utils/app_colors/app_colors.dart';
import 'package:nirbhor/view/components/custom_button/custom_button.dart';
import 'package:nirbhor/view/components/custom_from_card/custom_from_card.dart';
import '../../../../utils/app_images/app_images.dart';
import '../../../components/custom_image/custom_image.dart' show CustomImage;
import '../../../components/custom_royel_appbar/custom_royel_appbar.dart';
import '../../../components/custom_text/custom_text.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // GetX reactive state — no setState needed
  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomRoyelAppbar(
        titleName: 'KajerLok'.tr,
        leftIcon: true,
        centerTitleEnable: false,
        rightOnTap: () async {
          final prefs = await SharedPreferences.getInstance();
          if (Get.locale?.languageCode == 'en') {
            Get.updateLocale(const Locale('bn', 'BD'));
            await prefs.setString('languageCode', 'bn');
            await prefs.setString('countryCode', 'BD');
          } else {
            Get.updateLocale(const Locale('en', 'US'));
            await prefs.setString('languageCode', 'en');
            await prefs.setString('countryCode', 'US');
          }
        },
        rightWidget: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'English'.tr,
                style: TextStyle(
                  color: Get.locale?.languageCode == 'bn'
                      ? Colors.grey
                      : AppColors.primary,
                  fontWeight: Get.locale?.languageCode == 'bn'
                      ? FontWeight.w400
                      : FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
              TextSpan(
                text: '/',
                style: TextStyle(color: Colors.grey, fontSize: 13.sp),
              ),
              TextSpan(
                text: 'বাংলা'.tr,
                style: TextStyle(
                  color: Get.locale?.languageCode == 'bn'
                      ? AppColors.primary
                      : Colors.grey,
                  fontWeight: Get.locale?.languageCode == 'bn'
                      ? FontWeight.w700
                      : FontWeight.w400,
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
            CustomText(
              text: 'Login'.tr,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            CustomText(
              text: 'Access your verified community workspace'.tr,
              fontSize: 16,
              color: Colors.black54,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            // phone nyumber
            CustomFormCard(
              controller: phoneController,
              hintText: '+880 01XXX XXXXX',
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone),
              title: 'Phone Number'.tr,
            ),

            CustomFormCard(
              controller: passwordController,
              hintText: 'Enter your password'.tr,
              keyboardType: TextInputType.visiblePassword,
              prefixIcon: Icon(Icons.lock_outline),
              title: 'Password'.tr,
              isPassword: true,
            ),
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
            const SizedBox(height: 12),
            Obx(
              () => authController.isAuthLoading.value
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : CustomButton(
                      onTap: () {
                        if (phoneController.text.isNotEmpty &&
                            passwordController.text.isNotEmpty) {
                          authController.login(
                            phoneController.text,
                            passwordController.text,
                          );
                        } else {
                          showCustomSnackBar(
                            "Please enter phone and password".tr,
                            isError: true,
                          );
                        }
                      },
                      title: 'Login'.tr,
                      fillColor: AppColors.primary,
                      textColor: Colors.white,
                      fontSize: 16.sp,
                      borderRadius: 8,
                    ),
            ),
            const SizedBox(height: 10),
            // custom btn password
            // CustomButton(
            //   onTap: () {
            //     Get.toNamed(AppRoutes.passwordLoginScreen);
            //   },
            //   title: 'Password'.tr,
            //   fillColor: AppColors.primary,
            //   textColor: Colors.white,
            //   fontSize: 14.sp,
            //   borderRadius: 8,
            //   icon: const Icon(Icons.lock_outlined, color: Colors.white),
            // ),
            // const SizedBox(height: 16),
            // CustomButton(
            //   onTap: () {
            //     Get.toNamed(AppRoutes.otpVerifyScreen);
            //   },
            //   title: 'OTP'.tr,
            //   fillColor: AppColors.secondary,
            //   textColor: AppColors.primary,
            //   fontSize: 14.sp,
            //   borderRadius: 8,
            //   isBorder: true,
            //   borderColor: AppColors.primary,
            //   borderWidth: 1,
            //   icon: const Icon(Icons.sms_outlined, color: AppColors.primary),
            // ),
            // const SizedBox(height: 16),
            // //divider with or
            // Row(
            //   children: [
            //     Expanded(child: Divider()),
            //     Padding(
            //       padding: EdgeInsets.symmetric(horizontal: 8.0),
            //       child: CustomText(
            //         text: 'OR'.tr,
            //         color: AppColors.black,
            //         left: 10,
            //         right: 10,
            //       ),
            //     ),
            //     Expanded(child: Divider()),
            //   ],
            // ),
            // const SizedBox(height: 16),
            // // google login btn
            // CustomButton(
            //   onTap: () {},
            //   title: 'Continue with Google'.tr,
            //   fillColor: AppColors.secondary,
            //   textColor: AppColors.primary,
            //   fontSize: 14.sp,
            //   borderRadius: 8,
            //   isBorder: true,
            //   borderColor: AppColors.primary,
            //   borderWidth: 1,
            //   icon: FaIcon(FontAwesomeIcons.google, color: AppColors.primary),
            // ),

            // const SizedBox(height: 16),
            // CustomText(
            //   text:
            //       'Google login only available if you linked your Gmail after registration.'
            //           .tr,
            //   fontSize: 13,
            //   color: Colors.black54,
            //   textAlign: TextAlign.center,
            //   maxLines: 2,
            //   fontWeight: FontWeight.w500,
            // ),
            // const SizedBox(height: 24),
            //Register btn
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  text: "Don't have an account?".tr,
                  color: Colors.grey,
                ),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.registerScreen, arguments: "login");
                  },
                  child: CustomText(
                    text: 'Register Now'.tr,
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
}
