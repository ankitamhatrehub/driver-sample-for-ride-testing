import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/onboarding/widgets/kyc_form_widgets.dart';
import 'package:rider_app/common/widgets/app_text_field.dart';
import 'package:rider_app/common/widgets/onboarding_info_banner.dart';
import 'package:rider_app/common/widgets/onboarding_step_scaffold.dart';
import 'package:rider_app/common/widgets/unified_button.dart';

class PanVerificationScreen extends StatefulWidget {
  const PanVerificationScreen({
    super.key,
    required this.onBack,
    required this.onVerify,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onVerify;

  @override
  State<PanVerificationScreen> createState() => _PanVerificationScreenState();
}

class _PanVerificationScreenState extends State<PanVerificationScreen> {
  final _panController = TextEditingController();

  @override
  void dispose() {
    _panController.dispose();
    super.dispose();
  }

  bool get _validPan => RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(_panController.text.trim());

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.panVerification,
      onBack: widget.onBack,
      body: Padding(
        padding: EdgeInsets.fromLTRB(context.w(24), context.h(8), context.w(24), context.h(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: _PanCardArt()),
            SizedBox(height: context.h(28)),
            Text('${AppStrings.panNumber} *', style: AppTypography.regular.copyWith(fontSize: 13)),
            SizedBox(height: context.h(8)),
            AppTextField(
              controller: _panController,
              hintText: AppStrings.panNumber,
              obscureText: true,
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  return newValue.copyWith(text: newValue.text.toUpperCase());
                }),
              ],
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: context.h(12)),
            OnboardingInfoBanner(message: AppStrings.panGovHint),
            SizedBox(height: context.h(12)),
            KycPendingBanner(title: AppStrings.verificationPending),
            const Spacer(),
            UnifiedButton(
              label: AppStrings.verifyPan,
              enabled: _validPan,
              onPressed: () => widget.onVerify(_panController.text.trim()),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanCardArt extends StatelessWidget {
  const _PanCardArt();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.w(220),
      height: context.h(120),
      padding: EdgeInsets.all(context.w(16)),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(context.r(16)),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(44),
            height: context.w(44),
            decoration: const BoxDecoration(color: Color(0xFFE7EEF6), shape: BoxShape.circle),
            child: Icon(Icons.person, color: const Color(0xFFC5D0DE), size: context.w(26)),
          ),
          SizedBox(width: context.w(14)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _bar(context, 1),
                SizedBox(height: context.h(8)),
                _bar(context, 0.7),
                SizedBox(height: context.h(8)),
                _bar(context, 0.45),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(BuildContext context, double widthFactor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          height: context.h(8),
          decoration: BoxDecoration(color: const Color(0xFFE3EAF2), borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }
}
