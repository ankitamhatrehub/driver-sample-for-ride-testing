import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';

class LanguageSelectStep extends StatefulWidget {
  final String selectedLanguage;
  final ValueChanged<String> onLanguageSelected;
  final VoidCallback onContinue;

  const LanguageSelectStep({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageSelected,
    required this.onContinue,
  });

  @override
  State<LanguageSelectStep> createState() => _LanguageSelectStepState();
}

class _LanguageSelectStepState extends State<LanguageSelectStep> {
  bool _showError = false;

  void _select(String language) {
    setState(() => _showError = false);
    widget.onLanguageSelected(language);
  }

  void _continue() {
    if (widget.selectedLanguage.isEmpty) {
      setState(() => _showError = true);
      return;
    }
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.w(24),
          context.h(30),
          context.w(24),
          context.h(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.chooseLanguage, style: AppTypography.bold),
            SizedBox(height: context.h(10.25)),
            SizedBox(
              width: context.w(280),
              child: Text(
                AppStrings.chooseLanguageSubtitle,
                style: AppTypography.regular.copyWith(
                  color: AppColors.secondaryTextColor,
                  fontSize: 14.5,
                ),
              ),
            ),
            SizedBox(height: context.h(30)),
            _buildLanguageOption(
              badge: 'Aa',
              title: AppStrings.english,
              selected: widget.selectedLanguage == AppStrings.english,
              onTap: () => _select(AppStrings.english),
            ),
            SizedBox(height: context.h(14)),
            _buildLanguageOption(
              badge: 'अ',
              title: AppStrings.hindi,
              subtitle: 'Hindi',
              selected: widget.selectedLanguage == AppStrings.hindi,
              onTap: () => _select(AppStrings.hindi),
            ),
            if (_showError) ...[
              SizedBox(height: context.h(14)),
              Row(
                children: [
                  Icon(
                    Icons.error,
                    color: AppColors.error,
                    size: context.w(20),
                  ),
                  SizedBox(width: context.w(8)),
                  Expanded(
                    child: Text(
                      AppStrings.selectLanguageError,
                      style: AppTypography.regular.copyWith(
                        color: AppColors.error,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const Spacer(),
            UnifiedButton(
              label: AppStrings.continueAction,
              onPressed: _continue,
            ),
            SizedBox(height: context.h(14)),
            Center(
              child: Text(
                AppStrings.languageChangedLater,
                style: AppTypography.regular.copyWith(
                  color: AppColors.secondaryTextColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String badge,
    required String title,
    String? subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(14),
          vertical: context.h(14),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(16)),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.slate200,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: context.w(40),
              height: context.w(40),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.fieldFill,
                borderRadius: BorderRadius.circular(context.r(10)),
              ),
              child: Text(
                badge,
                style: AppTypography.bold.copyWith(fontSize: 16),
              ),
            ),
            SizedBox(width: context.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bold.copyWith(
                      fontSize: 16,
                      height: 1.2,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: AppTypography.regular.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.slate300,
              size: context.w(22),
            ),
          ],
        ),
      ),
    );
  }
}
