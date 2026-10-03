import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/screen_utils.dart';

/// Rounded filled field. Pass [hintText] and [controller] from the screen.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.maxLength,
    this.onChanged,
    this.inputFormatters,
    this.obscureText = false,
    this.obscuringCharacter = '*',
    this.focusNode,
    this.hasError = false,
  });

  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final String obscuringCharacter;
  final FocusNode? focusNode;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.r(12));
    return Container(
      height: context.h(48),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: radius,
        border: Border.all(
          color: hasError ? AppColors.error : AppColors.fieldBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        maxLength: maxLength,
        onChanged: onChanged,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        obscuringCharacter: obscuringCharacter,
        style: AppTypography.regular,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.regular.copyWith(color: AppColors.slate400),
          filled: true,
          fillColor: AppColors.fieldFill,
          counterText: '',
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: context.w(16)),
          border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
