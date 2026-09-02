import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nirbhor/utils/ToastMsg/toast_message.dart'
    show showCustomSnackBar;
import '../controller/auth_controller.dart';
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
  final TextEditingController nameBnController = TextEditingController();
  final TextEditingController nameEnController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    String userType = '';
    if (Get.arguments is String) {
      userType = Get.arguments;
    } else if (Get.arguments is Map) {
      userType = Get.arguments['role'] ?? '';
    }
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
            CustomText(
              text: 'Create Account'.tr,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            const SizedBox(height: 20),
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

            CustomFormCard(
              controller: nameEnController,
              hintText: 'Enter your full name (English)'.tr,
              title: 'Full Name (English)'.tr,
            ),
            CustomFormCard(
              controller: nameBnController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\u0980-\u09FF\s]')),
              ],
              hintText: 'আপনার পুরো নাম লিখুন (বাংলা)'.tr,
              title: 'Full Name (Bangla)'.tr,
            ),

            CustomFormCard(
              controller: passwordController,
              hintText: '********'.tr,
              title: 'Password'.tr,
              isPassword: true,
            ),

            CustomFormCard(
              controller: confirmPasswordController,
              hintText: '********'.tr,
              title: 'Confirm Password'.tr,
              isPassword: true,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter confirm password".tr;
                }
                if (value != passwordController.text) {
                  return "Passwords do not match".tr;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Obx(
              () => authController.isAuthLoading.value
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : CustomButton(
                      onTap: () {
                        String phone = phoneController.text.trim();
                        if (phone.isNotEmpty && !phone.startsWith('0')) {
                          phone = '0$phone';
                        }

                        if (phone.isEmpty ||
                            nameEnController.text.isEmpty ||
                            nameBnController.text.isEmpty ||
                            passwordController.text.isEmpty ||
                            confirmPasswordController.text.isEmpty) {
                          showCustomSnackBar(
                            "Please fill all fields".tr,
                            isError: true,
                          );

                          return;
                        }

                        if (phone.length != 11 ||
                            !RegExp(r'^01[3-9]\d{8}$').hasMatch(phone)) {
                          showCustomSnackBar(
                            "Please enter a valid 11-digit BD phone number".tr,
                            isError: true,
                          );

                          return;
                        }

                        if (!RegExp(
                          r'^[a-zA-Z\s]+$',
                        ).hasMatch(nameEnController.text.trim())) {
                          showCustomSnackBar(
                            "Please enter English name using English letters only"
                                .tr,
                            isError: true,
                          );
                          return;
                        }

                        if (!RegExp(
                          r'^[\u0980-\u09FF\s]+$',
                        ).hasMatch(nameBnController.text.trim())) {
                          showCustomSnackBar(
                            "দয়া করে সঠিক বাংলা নাম লিখুন".tr,
                            isError: true,
                          );
                          return;
                        }

                        if (userType == 'Seeker') {
                          authController.register(
                            phone: phone,
                            nameBn: nameBnController.text.trim(),
                            nameEn: nameEnController.text.trim(),
                            password: passwordController.text,
                            role: userType,
                          );
                        } else {
                          Get.toNamed(
                            AppRoutes.setupDetailsScreen,
                            arguments: {
                              'phone': phone,
                              'nameBn': nameBnController.text.trim(),
                              'nameEn': nameEnController.text.trim(),
                              'password': passwordController.text,
                              'role': userType,
                            },
                          );
                        }
                      },
                      title: 'Continue'.tr,
                      fillColor: AppColors.primary,
                      textColor: Colors.white,
                      fontSize: 16.sp,
                      borderRadius: 8,
                    ),
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
