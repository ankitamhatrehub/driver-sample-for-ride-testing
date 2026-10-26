import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

/// Indian mobile field with a fixed +91 prefix.
class AppPhoneField extends StatelessWidget {
  const AppPhoneField({
    super.key,
    required this.controller,
    this.hintText,
    this.countryCode,
    this.maxLength = 10,
  });

  final TextEditingController controller;
  final String? hintText;
  final String? countryCode;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    final effHint = hintText ?? AppStrings.phoneHint;
    final effCountryCode =
        countryCode ?? AppStrings.countryCodeIndia;
    final radius = BorderRadius.circular(context.r(16));
    return Row(
      children: [
        Container(
          width: context.w(76),
          height: context.h(54),
          decoration: BoxDecoration(
            color: context.torkk.border,
            borderRadius: radius,
          ),
          alignment: Alignment.center,
          child: Text(
            effCountryCode,
            style: TextStyle(
              fontSize: context.sp(16),
              color: context.torkk.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(width: context.w(12)),
        Expanded(
          child: SizedBox(
            height: context.h(54),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              maxLength: maxLength,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                color: context.torkk.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: context.sp(18),
                letterSpacing: 1.5,
              ),
              decoration: InputDecoration(
                hintText: effHint,
                hintStyle: TextStyle(
                  color: AppColors.slate400,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  fontSize: context.sp(18),
                ),
                filled: true,
                fillColor: context.torkk.border,
                border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: radius,
                  borderSide: BorderSide(color: context.legible(AppColors.blue600), width: 2),
                ),
                counterText: '',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.w(16),
                  vertical: context.h(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
