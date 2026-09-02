import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/app_colors/app_colors.dart';
import '../custom_text/custom_text.dart';
import '../custom_text_field/custom_text_field.dart';

class CustomFormCard extends StatelessWidget {
  final String title;
  final String? hintText;
  final Color? inputTextColor;
  final Color? curserColor;
  final TextEditingController controller;
  final bool isPassword;
  final bool? hasSuffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool hasBackgroundColor;
  final bool isMultiLine;
  final String? Function(dynamic)? validator;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLine;
  final double? fillBorderRadius;
  final Color? fieldBorderColor;
  final double? fontSize;
  final bool? enabled;
  final Color? titleColor;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const CustomFormCard({
    super.key,
    required this.title,
    required this.controller,
    this.isPassword = false,
    this.hasSuffixIcon,
    this.readOnly = false,
    this.onTap,
    this.hasBackgroundColor = false,
    this.isMultiLine = false,
    this.validator,
    this.hintText,
    this.suffixIcon,
    this.maxLine = 1,
    this.fontSize,
    this.titleColor,
    this.prefixIcon,
    this.keyboardType,
    this.onChanged,
    this.enabled,
    this.fillBorderRadius,
    this.fieldBorderColor,
    this.inputTextColor,
    this.curserColor,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: title,
          color: titleColor ?? AppColors.black,
          fontWeight: FontWeight.w600,
          fontSize: fontSize ?? 14.w,
          bottom: 8.h,
          maxLines: 2,
        ),
        CustomTextField(
          isDens: true,
          enabled: enabled,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          prefixIcon: prefixIcon,
          validator: validator,
          readOnly: readOnly,
          hintText: hintText,
          cursorColor: curserColor ?? AppColors.black,
          hintStyle: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: AppColors.grey_1,
          ),
          suffixIcon: suffixIcon,
          isPassword: isPassword,
          textEditingController: controller,
          inputTextStyle: GoogleFonts.poppins(
            color: inputTextColor ?? AppColors.black,
            fontSize: 18.sp,
          ),
          fillColor: hasBackgroundColor  ? Colors.transparent : Colors.transparent,
          fieldBorderColor: fieldBorderColor ?? AppColors.grey,
          keyboardType:  keyboardType ?? (isPassword ? TextInputType.visiblePassword : TextInputType.text),
          onTap: onTap,
          maxLines: isPassword ? 1 : maxLine,
          fieldBorderRadius: fillBorderRadius ?? 8,
        ),
        SizedBox(height: 15.h),
      ],
    );
  }
}
