import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/app_snackbar.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

part 'verify_otp_screen_parts/otp_box_content.dart';
part 'verify_otp_screen_parts/otp_boxes.dart';
part 'verify_otp_screen_parts/otp_boxes_state.dart';
part 'verify_otp_screen_parts/otp_cursor.dart';
part 'verify_otp_screen_parts/otp_cursor_state.dart';
part 'verify_otp_screen_sections.dart';

class VerifyOtpScreen extends StatefulWidget {
  final TextEditingController otpController;
  final FocusNode otpFocusNode;
  final TextEditingController phoneController;
  final int otpCountdown;
  final bool isLoading;
  final bool incorrectOtp;
  final bool announceOtpSent;
  final VoidCallback onOtpSentAnnounced;
  final VoidCallback onBack;
  final VoidCallback onDismissError;
  final VoidCallback onChangeNumber;
  final VoidCallback onResendOtp;
  final VoidCallback onVerify;

  const VerifyOtpScreen({
    super.key,
    required this.otpController,
    required this.otpFocusNode,
    required this.phoneController,
    required this.otpCountdown,
    required this.isLoading,
    required this.incorrectOtp,
    required this.announceOtpSent,
    required this.onOtpSentAnnounced,
    required this.onBack,
    required this.onDismissError,
    required this.onChangeNumber,
    required this.onResendOtp,
    required this.onVerify,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  static const int _otpLength = 6;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    widget.otpController.addListener(_onOtpChanged);
    _announceOtpSent();
  }

  @override
  void didUpdateWidget(VerifyOtpScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.announceOtpSent && !oldWidget.announceOtpSent) {
      _announceOtpSent();
    }
  }

  @override
  void dispose() {
    widget.otpController.removeListener(_onOtpChanged);
    super.dispose();
  }

  void _onOtpChanged() {
    if (!mounted) return;
    if (_showError) setState(() => _showError = false);
    if (widget.incorrectOtp) widget.onDismissError();
  }

  bool get _hasError => _showError || widget.incorrectOtp;

  void _verify() {
    if (widget.otpController.text.trim().length != _otpLength) {
      setState(() => _showError = true);
      return;
    }
    widget.onVerify();
  }

  String get _maskedPhone {
    final digits = widget.phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 2) {
      return '${AppStrings.countryCodeIndia}**********';
    }
    final hidden = '*' * (digits.length - 2);
    final lastTwo = digits.substring(digits.length - 2);
    return '${AppStrings.countryCodeIndia}$hidden$lastTwo';
  }

  String get _countdownLabel {
    final minutes = (widget.otpCountdown ~/ 60).toString().padLeft(2, '0');
    final seconds = (widget.otpCountdown % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final currentText = widget.otpController.text;

    return SafeArea(
      child: Scaffold(
        backgroundColor: context.torkk.background,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: context.themed(
                light: Colors.black,
                dark: context.torkk.textPrimary,
              ),
              size: 20,
            ),
            onPressed: widget.onBack,
          ),
          title: Text(
            AppStrings.otpVerification,
            style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2),
          ),
          titleSpacing: 0,
          backgroundColor: context.torkk.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        context.w(24),
                        context.h(10),
                        context.w(24),
                        context.h(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.verifyYourNumber,
                            style: AppTypography.bold.copyWith(
                              fontSize: 24,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: context.h(8)),
                          Text(
                            '${AppStrings.otpSentPrefix}$_maskedPhone',
                            style: AppTypography.regular.copyWith(
                              color: context.torkk.textSecondary,
                              fontSize: 14.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                    child: _OtpBoxes(
                      value: currentText,
                      length: _otpLength,
                      hasError: _hasError,
                      controller: widget.otpController,
                      focusNode: widget.otpFocusNode,
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          context.w(24),
                          0,
                          context.w(24),
                          context.h(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_hasError) ...[
                              SizedBox(height: context.h(20)),
                              Row(
                                children: [
                                  Icon(
                                    Icons.info,
                                    color: context.legible(AppColors.error),
                                    size: context.w(18),
                                  ),
                                  SizedBox(width: context.w(8)),
                                  Expanded(
                                    child: Text(
                                      AppStrings.incorrectOtp,
                                      style: AppTypography.regular.copyWith(
                                        color: context.legible(AppColors.error),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (widget.otpCountdown > 0) ...[
                              SizedBox(height: context.h(20)),
                              Center(
                                child: Text(
                                  '${AppStrings.resendOtpIn}$_countdownLabel',
                                  style: AppTypography.regular.copyWith(
                                    color: context.torkk.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                            SizedBox(height: context.h(28)),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: context.h(16),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.otpInfoFill.withValues(
                                  alpha: 0.05,
                                ),
                                borderRadius: BorderRadius.circular(
                                  context.r(12),
                                ),
                                border: Border.all(
                                  color: AppColors.otpInfoFill.withValues(
                                    alpha: 0.42,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    AppStrings.didntReceiveCode,
                                    style: AppTypography.regular.copyWith(
                                      color: context.torkk.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: context.h(4)),
                                  GestureDetector(
                                    onTap: widget.otpCountdown == 0
                                        ? widget.onResendOtp
                                        : null,
                                    child: Text(
                                      AppStrings.resendOtp,
                                      style: AppTypography.bold.copyWith(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        height: 1.2,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: context.h(20)),
                            UnifiedButton(
                              label: AppStrings.verifyAndContinue,
                              isLoading: widget.isLoading,
                              onPressed: _verify,
                            ),
                            SizedBox(height: context.h(30)),
                            Center(
                              child: GestureDetector(
                                onTap: widget.onChangeNumber,
                                child: Text(
                                  AppStrings.changeMobileNumber,
                                  style: AppTypography.regular.copyWith(
                                    color: context.themed(
                                      light: Colors.black,
                                      dark: context.torkk.textPrimary,
                                    ),
                                    fontSize: 14.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
