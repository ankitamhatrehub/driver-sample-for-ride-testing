import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/app/theme/theme_bloc.dart';
import 'package:rider_app/app/theme/theme_repository.dart';
import 'package:rider_app/app/theme/theme_state.dart';
import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/theme.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/widgets/app_confirm_dialog.dart';
import 'package:rider_app/common/widgets/app_switch.dart';
import 'package:rider_app/driver_features/settings/screens/driver_appearance_screen.dart';
import 'package:rider_app/driver_features/settings/screens/driver_settings_screen.dart';
import 'package:rider_app/driver_features/settings/screens/privacy_security_screen.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance() + 0.05;
  final lb = b.computeLuminance() + 0.05;
  return la > lb ? la / lb : lb / la;
}

Widget themed(Widget child, {required bool dark}) => MaterialApp(
  themeMode: dark ? ThemeMode.dark : ThemeMode.light,
  theme: AppTheme.getTheme(isPink: false),
  darkTheme: AppTheme.getTheme(isPink: false, isDark: true),
  home: child,
);

Color? _resolve(WidgetStateProperty<Color?>? p, Set<WidgetState> s) =>
    p?.resolve(s);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('AppSwitch', () {
    for (final dark in [false, true]) {
      testWidgets('thumb stands out from track (dark: $dark)', (tester) async {
        await tester.pumpWidget(
          themed(
            Scaffold(
              body: Column(
                children: [
                  AppSwitch(value: true, onChanged: (_) {}),
                  AppSwitch(value: false, onChanged: (_) {}),
                ],
              ),
            ),
            dark: dark,
          ),
        );
        final switches = tester
            .widgetList<Switch>(find.byType(Switch))
            .toList();
        for (final entry in {
          'on': (switches[0], {WidgetState.selected}),
          'off': (switches[1], <WidgetState>{}),
        }.entries) {
          final (sw, states) = entry.value;
          final thumb = _resolve(sw.thumbColor, states)!;
          final track = _resolve(sw.trackColor, states)!;
          if (dark) {
            expect(
              contrast(thumb, track),
              greaterThan(1.8),
              reason: '${entry.key} (dark: $dark)',
            );
          }
        }
        if (!dark) {
          // Light mode keeps its original colors.
          expect(_resolve(switches[1].thumbColor, {}), Colors.white);
          expect(_resolve(switches[1].trackColor, {}), AppColors.gray200);
        }
      });
    }
  });

  group('confirm dialog (delete account / logout)', () {
    for (final dark in [false, true]) {
      testWidgets('filled action label is readable (dark: $dark)', (
        tester,
      ) async {
        await tester.pumpWidget(
          themed(
            Builder(
              builder: (context) => Scaffold(
                body: AppConfirmCard(
                  icon: const Icon(Icons.delete),
                  title: 'Delete',
                  subtitle: 'Sure?',
                  confirmLabel: 'Confirm',
                  onCancel: () {},
                  onConfirm: () {},
                  accent: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            dark: dark,
          ),
        );
        final material = tester.widget<Material>(
          find
              .ancestor(
                of: find.text('Confirm'),
                matching: find.byType(Material),
              )
              .first,
        );
        final label = tester.widget<Text>(find.text('Confirm')).style!.color!;
        expect(contrast(material.color!, label), greaterThan(4.5));
        final cancel = tester.widget<Text>(find.text('Cancel')).style!.color!;
        expect(
          contrast(TorkkColorsHelper.surface(dark), cancel),
          greaterThan(4.5),
        );
      });
    }
  });

  group('settings screens in dark mode', () {
    testWidgets('settings list uses dark surface and readable rows', (
      tester,
    ) async {
      await tester.pumpWidget(themed(const DriverSettingsScreen(), dark: true));
      await tester.pumpAndSettle();
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, TorkkColors.dark.background);
      final rowText = tester.widget<Text>(find.text(AppStrings.appearance));
      final style = DefaultTextStyle.of(
        tester.element(find.text(AppStrings.appearance)),
      ).style.merge(rowText.style);
      expect(
        contrast(style.color!, TorkkColors.dark.background),
        greaterThan(7),
      );
    });

    testWidgets('privacy switches are readable in dark mode', (tester) async {
      await tester.pumpWidget(
        themed(const PrivacySecurityScreen(), dark: true),
      );
      await tester.pumpAndSettle();
      final switches = tester.widgetList<Switch>(find.byType(Switch));
      expect(switches, isNotEmpty);
      for (final sw in switches) {
        final states = sw.value ? {WidgetState.selected} : <WidgetState>{};
        final thumb = _resolve(sw.thumbColor, states)!;
        final track = _resolve(sw.trackColor, states)!;
        expect(contrast(thumb, track), greaterThan(1.8));
        // The track must also stand out from the card behind it.
        expect(contrast(track, TorkkColors.dark.background), greaterThan(1.3));
      }
    });

    testWidgets('appearance options switch the whole app theme', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'app_theme': 'Light Mode'});
      final repo = ThemeRepository(await SharedPreferences.getInstance());
      final bloc = ThemeBloc(repo);
      addTearDown(bloc.close);
      await tester.pumpWidget(
        BlocProvider.value(
          value: bloc,
          child: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) => MaterialApp(
              themeMode: state.themeMode,
              theme: AppTheme.getTheme(isPink: state.isPink),
              darkTheme: AppTheme.getTheme(isPink: state.isPink, isDark: true),
              home: const DriverAppearanceScreen(),
            ),
          ),
        ),
      );
      Color? bg() =>
          tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor;

      expect(bg(), Colors.white);
      await tester.tap(find.text(AppStrings.darkMode));
      await tester.pumpAndSettle();
      expect(bg(), TorkkColors.dark.background);
      expect(repo.read().themeMode, ThemeMode.dark);

      await tester.tap(find.text(AppStrings.lightMode));
      await tester.pumpAndSettle();
      expect(bg(), Colors.white);
      expect(repo.read().themeMode, ThemeMode.light);
    });
  });
}

/// Surface color of each mode, for contrast checks.
class TorkkColorsHelper {
  static Color surface(bool dark) =>
      dark ? TorkkColors.dark.surface : TorkkColors.light.surface;
}
