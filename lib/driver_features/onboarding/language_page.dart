import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:rider_app/common/routes/app_routes.dart';
import 'package:rider_app/common/utils/translations.dart';
import 'package:rider_app/driver_features/onboarding/screens/language_selection.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.torkk.background,
      body: ValueListenableBuilder<String>(
        valueListenable: AppTranslations.currentLanguage,
        builder: (context, currentLanguage, _) {
          final selectedCode = currentLanguage == 'hi' ? 'hi' : 'en';

          return LanguageSelectStep(
            selectedLanguage: selectedCode,
            onLanguageSelected: AppTranslations.changeLanguage,
            onContinue: () {
              AppTranslations.changeLanguage(selectedCode);
              context.go(AppRoutes.welcome);
            },
          );
        },
      ),
    );
  }
}
