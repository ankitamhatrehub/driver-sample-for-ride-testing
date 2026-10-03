import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/app_text_field.dart';
import 'package:rider_app/common/widgets/onboarding_header_image.dart';
import 'package:rider_app/common/widgets/unified_button.dart';

class WelcomeScreen extends StatefulWidget {
  final TextEditingController phoneController;
  final bool termsAccepted;
  final ValueChanged<bool> onTermsChanged;
  final VoidCallback onContinue;
  final bool isLoading;

  const WelcomeScreen({
    super.key,
    required this.phoneController,
    required this.termsAccepted,
    required this.onTermsChanged,
    required this.onContinue,
    required this.isLoading,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    widget.phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    widget.phoneController.removeListener(_onPhoneChanged);
    super.dispose();
  }

  void _onPhoneChanged() {
    if (!mounted) return;
    if (_isPhoneValid && _showError) {
      setState(() => _showError = false);
    }
  }

  bool get _isPhoneValid =>
      widget.phoneController.text.trim().replaceAll(' ', '').length == 10;

  void _continue() {
    if (!_isPhoneValid) {
      setState(() => _showError = true);
      return;
    }
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingHeaderImage(),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              context.w(20),
              context.h(20),
              context.w(24),
              context.h(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.welcome,
                          style: AppTypography.bold.copyWith(fontSize: 24),
                        ),
                        SizedBox(height: context.h(10)),
                        Text(
                          AppStrings.welcomeSubtitle,
                          style: AppTypography.regular.copyWith(
                            color: AppColors.secondaryTextColor,
                            fontSize: 14.5,
                          ),
                        ),
                        SizedBox(height: context.h(29)),
                        Row(
                          children: [
                            Container(
                              height: context.h(48),
                              padding: EdgeInsets.symmetric(
                                horizontal: context.w(14),
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.fieldFill,
                                borderRadius: BorderRadius.circular(
                                  context.r(12),
                                ),
                                border: Border.all(color: AppColors.fieldBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    AppStrings.countryCodeIndia,
                                    style: AppTypography.regular,
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppColors.slate500,
                                    size: context.w(18),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: context.w(10)),
                            Expanded(
                              child: AppTextField(
                                controller: widget.phoneController,
                                hintText: AppStrings.enterMobileHint,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                hasError: _showError,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (_showError) ...[
                          SizedBox(height: context.h(14)),
                          Row(
                            children: [
                              Icon(
                                Icons.info,
                                color: AppColors.error,
                                size: context.w(18),
                              ),
                              SizedBox(width: context.w(8)),
                              Expanded(
                                child: Text(
                                  AppStrings.enterMobileError,
                                  style: AppTypography.regular.copyWith(
                                    color: AppColors.error,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (!keyboardOpen) ...[
                  _termsAgreement(
                    () => widget.onTermsChanged(!widget.termsAccepted),
                  ),
                  SizedBox(height: context.h(14)),
                ],
                UnifiedButton(
                  label: AppStrings.continueAction,
                  isLoading: widget.isLoading,
                  onPressed: _continue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _termsAgreement(VoidCallback onTap) {
    final linkStyle = AppTypography.regular.copyWith(
      color: AppColors.blue600,
      fontSize: 13,
    );
    return GestureDetector(
      onTap: onTap,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: AppStrings.termsPrefix,
          style: AppTypography.regular.copyWith(
            color: AppColors.secondaryTextColor,
            fontSize: 13,
          ),
          children: [
            TextSpan(text: AppStrings.termsOfService, style: linkStyle),
            TextSpan(text: AppStrings.andWord),
            TextSpan(text: AppStrings.privacyPolicy, style: linkStyle),
          ],
        ),
      ),
    );
  }
}

