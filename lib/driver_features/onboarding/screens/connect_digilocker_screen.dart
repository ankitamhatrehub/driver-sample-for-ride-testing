import 'package:flutter/material.dart';
import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/onboarding_step_scaffold.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class ConnectDigilockerScreen extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onHelp;
  final VoidCallback onContinue;

  const ConnectDigilockerScreen({
    super.key,
    required this.isLoading,
    required this.onBack,
    required this.onHelp,
    required this.onContinue,
  });

  @override
  State<ConnectDigilockerScreen> createState() =>
      _ConnectDigilockerScreenState();
}

class _ConnectDigilockerScreenState extends State<ConnectDigilockerScreen> {
  bool _consent = true;

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.connectDigilocker,
      subtitle: AppStrings.connectDigilockerSubtitle,
      onBack: widget.onBack,
      onHelp: widget.onHelp,
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  context.w(24),
                  context.h(0),
                  context.w(24),
                  context.h(16),
                ),
                child: Column(
                  children: [
                    SizedBox(height: context.h(50)),
                    Image.asset(
                      AppAssets.connectDigilockerImage,
                      height: context.h(120),
                      width: context.w(280),
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: context.h(50)),
                    Container(
                      width: context.w(310),
                      padding: EdgeInsets.all(context.w(14)),
                      decoration: BoxDecoration(
                        color: context.torkk.surface,
                        borderRadius: BorderRadius.circular(context.r(16)),
                        border: Border.all(color: context.torkk.border),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            offset: Offset(2, 0),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        spacing: context.h(8),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppStrings.documentsWellAccess,
                              style: AppTypography.bold.copyWith(
                                fontSize: 11,
                                letterSpacing: 0.4,
                                color: context.torkk.textSecondary,
                              ),
                            ),
                          ),
                          _DocAccessTile(
                            icon: AppAssets.aadhaarCardIcon,
                            background: const Color(0xFFFFF7ED),
                            label: AppStrings.aadhaarDoc,
                          ),
                          _DocAccessTile(
                            icon: AppAssets.panCardIcon,
                            background: AppColors.blueLight,
                            label: AppStrings.panDoc,
                          ),
                          _DocAccessTile(
                            icon: AppAssets.drivingLicenceIcon,
                            background: const Color(0xFFFAF5FF),
                            label: AppStrings.drivingLicenseDoc,
                            suffix: AppStrings.whereAvailable,
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _consent,
                          checkColor: context.torkk.background,
                          side: BorderSide(
                            color: context.torkk.textPrimary,
                            width: 1.4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.r(4)),
                          ),
                          fillColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return context.torkk.textPrimary;
                            }
                            return Colors.transparent;
                          }),
                          onChanged: (value) =>
                              setState(() => _consent = value ?? false),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: context.h(12)),
                            child: Text(
                              AppStrings.digilockerConsent,
                              style: AppTypography.regular.copyWith(
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.h(8)),
                    UnifiedButton(
                      label: AppStrings.continueAction,
                      enabled: _consent,
                      isLoading: widget.isLoading,
                      onPressed: widget.onContinue,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DocAccessTile extends StatelessWidget {
  const _DocAccessTile({
    required this.icon,
    required this.background,
    required this.label,
    this.suffix,
  });

  final String icon;
  final Color background;
  final String label;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.w(14),
        vertical: context.h(14),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(36),
            height: context.w(36),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(context.r(8)),
            ),
            child: Image.asset(
              icon,
              width: context.w(20),
              height: context.w(20),
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: context.w(10)),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: label,
                style: AppTypography.bold.copyWith(
                  fontSize: 12,
                  height: 15 / 12,
                  color: context.torkk.textPrimary,
                ),
                children: [
                  if (suffix != null)
                    TextSpan(
                      text: ' $suffix',
                      style: AppTypography.regular.copyWith(
                        fontSize: 10,
                        height: 15 / 10,
                        fontWeight: FontWeight.w600,
                        color: context.torkk.textPrimary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
