import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/app_snackbar.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

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

  void _announceOtpSent() {
    if (!widget.announceOtpSent) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.announceOtpSent) return;
      AppSnackBar.showSuccess(
        context,
        title: AppStrings.otpSentTitle,
        message: AppStrings.otpSentMessage,
      );
      widget.onOtpSentAnnounced();
    });
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
              color: context.themed(light: Colors.black, dark: context.torkk.textPrimary),
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
                                style: AppTypography.bold.copyWith(fontSize: 24, height: 1.2),
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
                                  padding: EdgeInsets.symmetric(vertical: context.h(16)),
                                  decoration: BoxDecoration(
                                    color: AppColors.otpInfoFill.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(context.r(12)),
                                    border: Border.all(
                                      color: AppColors.otpInfoFill.withValues(alpha: 0.42),
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
                                        onTap: widget.otpCountdown == 0 ? widget.onResendOtp : null,
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
                                        color: context.themed(light: Colors.black, dark: context.torkk.textPrimary),
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

class _OtpBoxes extends StatefulWidget {
  const _OtpBoxes({
    required this.value,
    required this.length,
    required this.hasError,
    required this.controller,
    required this.focusNode,
  });

  final String value;
  final int length;
  final bool hasError;
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  State<_OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<_OtpBoxes> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_rebuild);
    widget.controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(_OtpBoxes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_rebuild);
      widget.focusNode.addListener(_rebuild);
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_rebuild);
      widget.controller.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_rebuild);
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  int _tappedIndex = 0;

  int get _cursorOffset {
    final text = widget.controller.text;
    final raw = widget.controller.selection.baseOffset;
    if (raw < 0) return text.length;
    return raw.clamp(0, text.length);
  }

  void _selectBox(int index) {
    final text = widget.controller.text;
    final offset = index < text.length ? index + 1 : text.length;
    widget.focusNode.requestFocus();
    widget.controller.value = widget.controller.value.copyWith(
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
    SystemChannels.textInput.invokeMethod<void>('TextInput.show');
  }

  bool _cursorInBox(int index) {
    if (!widget.focusNode.hasFocus) return false;
    final textLength = widget.controller.text.length;
    final offset = _cursorOffset;
    if (offset == textLength) {
      final slot = textLength >= widget.length ? widget.length - 1 : textLength;
      return index == slot;
    }
    if (offset == 0) return index == 0;
    return index == offset - 1;
  }

  bool _cursorBeforeDigit(int index) =>
      widget.focusNode.hasFocus && _cursorOffset == 0 && index == 0;

  @override
  Widget build(BuildContext context) {
    final gap = context.w(8);
    final boxSize =
        (MediaQuery.sizeOf(context).width - context.w(48) - gap * (widget.length - 1)) /
        widget.length;

    return SizedBox(
      height: boxSize,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          IgnorePointer(
            child: Row(
              children: List.generate(widget.length, (index) {
                final char = index < widget.controller.text.length
                    ? widget.controller.text[index]
                    : '';
                final isActive = _cursorInBox(index);
                final showErrorBorder = widget.hasError && index == widget.length - 1;
                return Padding(
                  padding: EdgeInsets.only(right: index == widget.length - 1 ? 0 : gap),
                  child: Container(
                    width: boxSize,
                    height: boxSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.torkk.surface,
                      borderRadius: BorderRadius.circular(context.r(14)),
                      border: Border.all(
                        color: showErrorBorder
                            ? context.legible(AppColors.error)
                            : isActive
                            ? AppColors.primary
                            : AppColors.fieldBorder,
                        width: showErrorBorder || isActive ? 1.6 : 1,
                      ),
                    ),
                    child: _OtpBoxContent(
                      char: char,
                      showCursor: isActive,
                      cursorBeforeDigit: _cursorBeforeDigit(index),
                    ),
                  ),
                );
              }),
            ),
          ),
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) {
                _tappedIndex = (event.localPosition.dx / (boxSize + gap))
                    .floor()
                    .clamp(0, widget.length - 1);
                _selectBox(_tappedIndex);
              },
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.none,
                autofillHints: const [AutofillHints.oneTimeCode],
                autofocus: true,
                showCursor: false,
                cursorWidth: 0,
                maxLength: widget.length,
                enableInteractiveSelection: false,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.transparent, fontSize: 1, height: 1),
                decoration: const InputDecoration(
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  counterText: '',
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  _selectBox(_tappedIndex);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _selectBox(_tappedIndex);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpBoxContent extends StatelessWidget {
  const _OtpBoxContent({
    required this.char,
    required this.showCursor,
    required this.cursorBeforeDigit,
  });

  final String char;
  final bool showCursor;
  final bool cursorBeforeDigit;

  @override
  Widget build(BuildContext context) {
    final digit = Text(
      char,
      style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2),
    );
    if (!showCursor) return digit;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (cursorBeforeDigit && char.isNotEmpty) const _OtpCursor(),
        if (char.isNotEmpty) digit,
        if (!cursorBeforeDigit) const _OtpCursor(),
      ],
    );
  }
}

class _OtpCursor extends StatefulWidget {
  const _OtpCursor();

  @override
  State<_OtpCursor> createState() => _OtpCursorState();
}

class _OtpCursorState extends State<_OtpCursor> with SingleTickerProviderStateMixin {
  late final AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _blink,
      child: Container(
        width: 1.6,
        height: context.h(22),
        color: AppColors.textPrimary,
      ),
    );
  }
}
