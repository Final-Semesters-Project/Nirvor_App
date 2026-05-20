// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../utils/app_colors/app_colors.dart';

class CustomPinCode extends StatelessWidget {
  const CustomPinCode({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: PinCodeTextField(
        keyboardType: TextInputType.number,
        appContext: context,
        length: 6,
        enableActiveFill: true,
        animationType: AnimationType.fade,
        animationDuration: Duration(milliseconds: 300),
        controller: controller,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(8),
          fieldHeight: 60,
          fieldWidth: size.width * 0.12,
          inactiveColor: AppColors.grey_1,
          activeColor: AppColors.primary, // active color
          activeFillColor: AppColors.white_50,
          inactiveFillColor: AppColors.white,
          selectedFillColor: AppColors.primary, // selected color
          disabledColor: AppColors.white_50,
          selectedColor: AppColors.white,
        ),
      ),
    );
  }
}
