import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/utils/translations.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/driver_features/settings/widgets/settings_choice_card.dart';

class SettingsLanguageScreen extends StatelessWidget {
  const SettingsLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Language',
      child: ValueListenableBuilder<String>(
        valueListenable: AppTranslations.currentLanguage,
        builder: (context, language, _) {
          return ListView(
            padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(20)),
            children: [
              Text(
                'Select your preferred language',
                style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.slate500),
              ),
              SizedBox(height: context.h(14)),
              SettingsChoiceCard(
                selected: language == 'en',
                title: 'English',
                subtitle: 'Default',
                onTap: () => AppTranslations.changeLanguage('en'),
                leading: const _LangMark('En'),
              ),
              SettingsChoiceCard(
                selected: language == 'hi',
                title: 'Hindi',
                subtitle: 'हिंदी',
                onTap: () => AppTranslations.changeLanguage('hi'),
                leading: const _LangMark('अ'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LangMark extends StatelessWidget {
  const _LangMark(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.w(36),
      height: context.w(36),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(context.r(10)),
      ),
      child: Text(
        label,
        style: AppTypography.bold.copyWith(fontSize: 13, color: const Color(0xFF7C3AED)),
      ),
    );
  }
}
