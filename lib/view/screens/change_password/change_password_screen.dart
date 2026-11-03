import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../service/api_client.dart';
import '../../../service/api_url.dart';
import '../../../utils/app_colors/app_colors.dart';
import '../../../utils/ToastMsg/toast_message.dart';
import '../../components/custom_button/custom_button.dart';
import '../../components/custom_from_card/custom_from_card.dart';
import '../../components/custom_royel_appbar/custom_royel_appbar.dart';
import '../../components/custom_text/custom_text.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_onTextChanged);
    _confirmPasswordController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_onTextChanged);
    _confirmPasswordController.removeListener(_onTextChanged);
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (_isLoading) return;

    final String currentPass = _currentPasswordController.text;
    final String newPass = _newPasswordController.text;
    final String confirmPass = _confirmPasswordController.text;

    // Validation
    if (currentPass.isEmpty) {
      showCustomSnackBar("Please enter current password".tr, isError: true);
      return;
    }

    if (newPass.isEmpty) {
      showCustomSnackBar("Please enter new password".tr, isError: true);
      return;
    }

    if (newPass.length < 8) {
      showCustomSnackBar("Password must be at least 8 characters".tr, isError: true);
      return;
    }

    if (newPass == currentPass) {
      showCustomSnackBar("New password cannot be same as current password".tr, isError: true);
      return;
    }

    if (confirmPass.isEmpty) {
      showCustomSnackBar("Please confirm new password".tr, isError: true);
      return;
    }

    if (newPass != confirmPass) {
      showCustomSnackBar("Passwords do not match".tr, isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final body = {
        "current_password": currentPass,
        "new_password": newPass,
      };

      final response = await ApiClient.patchData(
        ApiUrl.updatePassword,
        body,
      );

      if (response.statusCode == 200) {
        String successMsg = "Password updated successfully".tr;
        if (response.body is String && (response.body as String).isNotEmpty) {
          successMsg = response.body as String;
        } else if (response.body is Map && response.body['message'] != null) {
          successMsg = response.body['message'].toString();
        }

        if (mounted) {
          Navigator.of(context).pop(true);
        }
        showCustomSnackBar(successMsg, isError: false);
        return;
      } else {
        String errorMsg = "Something went wrong".tr;
        try {
          final data = response.body is Map
              ? response.body
              : jsonDecode(response.body.toString());
          if (data is Map && data['detail'] != null) {
            errorMsg = data['detail'].toString();
          } else if (data is Map && data['message'] != null) {
            errorMsg = data['message'].toString();
          }
        } catch (_) {
          if (response.statusText != null && response.statusText!.isNotEmpty) {
            errorMsg = response.statusText!;
          }
        }
        showCustomSnackBar(errorMsg, isError: true);
      }
    } catch (e) {
      debugPrint("Error updating password: $e");
      showCustomSnackBar("Something went wrong".tr, isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildRequirement(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 16.sp,
            color: met ? AppColors.primary : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: met ? FontWeight.w600 : FontWeight.w400,
                color: met ? AppColors.primary : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasMinLength = _newPasswordController.text.length >= 8;
    final bool passwordsMatch = _confirmPasswordController.text.isNotEmpty &&
        _newPasswordController.text == _confirmPasswordController.text;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomRoyelAppbar(
        titleName: 'Change Password'.tr,
        leftIcon: true,
        centerTitleEnable: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Update Password'.tr,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF14532D),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enter your current password and choose a strong new password with at least 8 characters.'.tr,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF166534),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Form Fields
            CustomFormCard(
              controller: _currentPasswordController,
              title: 'Current Password'.tr,
              hintText: 'Enter current password'.tr,
              isPassword: true,
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
            ),

            CustomFormCard(
              controller: _newPasswordController,
              title: 'New Password'.tr,
              hintText: 'Enter new password'.tr,
              isPassword: true,
              prefixIcon: const Icon(Icons.lock_reset, color: AppColors.primary),
            ),

            CustomFormCard(
              controller: _confirmPasswordController,
              title: 'Confirm New Password'.tr,
              hintText: 'Re-enter new password'.tr,
              isPassword: true,
              prefixIcon: const Icon(Icons.check_circle_outline, color: AppColors.primary),
            ),

            // Real-time Requirements Helper Box
            Container(
              margin: const EdgeInsets.only(top: 4, bottom: 28),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRequirement(
                    'At least 8 characters'.tr,
                    hasMinLength,
                  ),
                  _buildRequirement(
                    'Passwords match'.tr,
                    passwordsMatch,
                  ),
                ],
              ),
            ),

            // Submit Button
            _isLoading
                ? const Center(
                    child: SizedBox(
                      height: 48,
                      width: 48,
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                : CustomButton(
                    onTap: _updatePassword,
                    title: 'Update Password'.tr,
                    fillColor: AppColors.primary,
                    textColor: Colors.white,
                    fontSize: 16.sp,
                    borderRadius: 10,
                  ),
          ],
        ),
      ),
    );
  }
}

