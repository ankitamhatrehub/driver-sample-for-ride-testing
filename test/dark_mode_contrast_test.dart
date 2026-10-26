import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/theme.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/widgets/app_primary_button.dart';
import 'package:rider_app/common/widgets/unified_button.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance() + 0.05;
  final lb = b.computeLuminance() + 0.05;
  return la > lb ? la / lb : lb / la;
}

Widget host(Widget child, {required bool dark, bool pink = false}) {
  return MaterialApp(
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    theme: AppTheme.getTheme(isPink: pink),
    darkTheme: AppTheme.getTheme(isPink: pink, isDark: true),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('theme-level button contrast', () {
    for (final pink in [false, true]) {
      for (final dark in [false, true]) {
        test('filled/elevated labels readable (dark: $dark, pink: $pink)', () {
          final theme = AppTheme.getTheme(isPink: pink, isDark: dark);
          final scheme = theme.colorScheme;
          expect(contrast(scheme.primary, scheme.onPrimary), greaterThan(4.5));
          final elevated = theme.elevatedButtonTheme.style!;
          final bg = elevated.backgroundColor!.resolve({})!;
          final fg = elevated.foregroundColor!.resolve({})!;
          expect(contrast(bg, fg), greaterThan(4.5));
        });
      }
    }

    test('dark input hint, label and text are readable on the field', () {
      final theme = AppTheme.getTheme(isPink: false, isDark: true);
      final input = theme.inputDecorationTheme;
      final fill = input.fillColor!;
      expect(contrast(input.hintStyle!.color!, fill), greaterThan(4.5));
      expect(contrast(input.labelStyle!.color!, fill), greaterThan(4.5));
      expect(
        contrast(theme.textTheme.bodyMedium!.color!, fill),
        greaterThan(7),
      );
    });

    test('dark dialog and sheet text are readable on their surface', () {
      final theme = AppTheme.getTheme(isPink: false, isDark: true);
      final dialog = theme.dialogTheme;
      expect(
        contrast(dialog.titleTextStyle!.color!, dialog.backgroundColor!),
        greaterThan(7),
      );
      expect(
        contrast(dialog.contentTextStyle!.color!, dialog.backgroundColor!),
        greaterThan(4.5),
      );
    });
  });

  group('helpers', () {
    test('onColorFor picks a readable label for fixed fills', () {
      expect(onColorFor(AppColors.otpInfoBorder), Colors.white);
      expect(onColorFor(AppColors.error), Colors.white);
      expect(onColorFor(const Color(0xFFEEEBDA)), isNot(Colors.white));
      expect(onColorFor(AppColors.amber500), isNot(Colors.white));
      for (final fill in [
        AppColors.primary,
        AppColors.blue700,
        AppColors.amber500,
        const Color(0xFFEEEBDA),
      ]) {
        expect(contrast(fill, onColorFor(fill)), greaterThan(4.5));
      }
    });

    testWidgets('legible and adaptiveTint keep light mode, fix dark mode', (
      tester,
    ) async {
      const brands = [
        AppColors.primary,
        AppColors.royalBlue,
        AppColors.navyBlue,
        AppColors.deepPurple,
      ];
      const tint = Color(0xFFF6F3FB);

      Future<BuildContext> pumpMode({required bool dark}) async {
        late BuildContext captured;
        await tester.pumpWidget(
          host(
            Builder(
              builder: (c) {
                captured = c;
                return const SizedBox();
              },
            ),
            dark: dark,
          ),
        );
        // The theme animates between modes; wait for it to finish.
        await tester.pumpAndSettle();
        return captured;
      }

      final light = await pumpMode(dark: false);
      for (final brand in brands) {
        expect(light.legible(brand), brand);
      }
      expect(light.adaptiveTint(tint), tint);

      final dark = await pumpMode(dark: true);
      for (final brand in brands) {
        expect(
          contrast(dark.legible(brand), TorkkColors.dark.surface),
          greaterThanOrEqualTo(4.5),
        );
      }
      expect(dark.adaptiveTint(tint), isNot(tint));
      expect(dark.adaptiveTint(tint).computeLuminance(), lessThan(0.1));
    });
  });

  group('shared buttons', () {
    Color fillOf(WidgetTester tester, Finder button) {
      final container = tester.widget<Container>(
        find.descendant(of: button, matching: find.byType(Container)).first,
      );
      return (container.decoration as BoxDecoration).color!;
    }

    Color labelOf(WidgetTester tester, String text) =>
        tester.widget<Text>(find.text(text)).style!.color!;

    for (final dark in [false, true]) {
      testWidgets('AppPrimaryButton is readable (dark: $dark)', (tester) async {
        await tester.pumpWidget(
          host(
            AppPrimaryButton(label: 'Continue', onPressed: () {}),
            dark: dark,
          ),
        );
        final fill = fillOf(tester, find.byType(AppPrimaryButton));
        expect(contrast(fill, labelOf(tester, 'Continue')), greaterThan(4.5));
        if (!dark) {
          expect(fill, AppColors.zinc800);
          expect(labelOf(tester, 'Continue'), Colors.white);
        } else {
          expect(fill, TorkkColors.dark.accent);
        }
      });

      testWidgets('UnifiedButton variants are readable (dark: $dark)', (
        tester,
      ) async {
        await tester.pumpWidget(
          host(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                UnifiedButton(label: 'Filled', onPressed: () {}),
                UnifiedButton(
                  label: 'Outline',
                  variant: UnifiedButtonVariant.outline,
                  onPressed: () {},
                ),
                UnifiedButton(
                  label: 'Danger',
                  variant: UnifiedButtonVariant.error,
                  onPressed: () {},
                ),
              ],
            ),
            dark: dark,
          ),
        );
        for (final label in ['Filled', 'Outline', 'Danger']) {
          final button = find.ancestor(
            of: find.text(label),
            matching: find.byType(UnifiedButton),
          );
          final fill = fillOf(tester, button);
          expect(
            contrast(fill, labelOf(tester, label)),
            greaterThan(4.5),
            reason: '$label (dark: $dark)',
          );
        }
      });
    }
  });

  group('source guard', () {
    test('screens do not define their own light/dark palettes', () {
      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (entity.path.contains('common/theme/')) continue;
        final text = entity.readAsStringSync();
        if (RegExp(r'\bisDark\s*\?|Brightness\.dark').hasMatch(text) &&
            !entity.path.endsWith('driver_app.dart')) {
          offenders.add(entity.path);
        }
      }
      expect(
        offenders,
        isEmpty,
        reason: 'Use context.torkk tokens instead of local isDark palettes',
      );
    });
  });
}
