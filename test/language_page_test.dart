import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rider_app/common/utils/translations.dart';
import 'package:rider_app/driver_features/onboarding/language_page.dart';
import 'package:rider_app/driver_features/onboarding/screens/language_selection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'shows the saved language selected and updates content after selection',
    (tester) async {
      SharedPreferences.setMockInitialValues({'app_language': 'hi'});
      await AppTranslations.init();
      addTearDown(() {
        AppTranslations.currentLanguage.value = 'en';
      });

      await tester.pumpWidget(const MaterialApp(home: LanguagePage()));

      expect(find.text('अपनी भाषा चुनें'), findsOneWidget);
      expect(
        tester
            .widget<LanguageSelectStep>(find.byType(LanguageSelectStep))
            .selectedLanguage,
        'hi',
      );

      await tester.tap(find.text('अंग्रेज़ी'));
      await tester.pumpAndSettle();

      expect(find.text('Choose your Language'), findsOneWidget);
      expect(AppTranslations.currentLanguage.value, 'en');
      expect(
        tester
            .widget<LanguageSelectStep>(find.byType(LanguageSelectStep))
            .selectedLanguage,
        'en',
      );
    },
  );
}
