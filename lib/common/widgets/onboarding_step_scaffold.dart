import 'package:flutter/material.dart';

import 'package:rider_app/common/widgets/ai_chat_button.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

/// Shared header for onboarding steps.
///
/// Back, title, help, and [subtitle] sit in a column. [subtitle] lines up under the title.
class OnboardingStepScaffold extends StatelessWidget {
  const OnboardingStepScaffold({
    super.key,
    required this.title,
    required this.onBack,
    required this.body,
    this.subtitle,
    this.onHelp,
    this.headerAction,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final VoidCallback? onHelp;
  final Widget? headerAction;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.torkk.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: context.h(35),
              left: context.w(16),
              right: context.w(16),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: context.themed(light: Colors.black, dark: context.torkk.textPrimary),
                    size: 20,
                  ),
                  onPressed: onBack,
                ),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.bold.copyWith(
                      fontSize: 20,
                      height: 1.2,
                    ),
                  ),
                ),
                ?headerAction,
                if (onHelp != null)
                  Padding(
                    padding: EdgeInsets.only(right: context.w(8)),
                    child: AiChatButton(size: context.w(40), onTap: onHelp),
                  ),
              ],
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: EdgeInsets.only(
                left: 56,
                right: context.w(60),
                bottom: context.h(12),
              ),
              child: SizedBox(
                width: context.w(281),
                child: Text(
                  subtitle!,
                  style: AppTypography.regular.copyWith(
                    fontSize: 14,
                    height: 1.4,
                    color: context.torkk.textSecondary,
                  ),
                ),
              ),
            ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
