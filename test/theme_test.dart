import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/app/theme/theme_bloc.dart';
import 'package:rider_app/app/theme/theme_event.dart';
import 'package:rider_app/app/theme/theme_repository.dart';
import 'package:rider_app/app/theme/theme_state.dart';
import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/theme.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/driver_features/settings/widgets/settings_choice_card.dart';

Future<ThemeRepository> _repo([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  return ThemeRepository(await SharedPreferences.getInstance());
}

void main() {
  group('theme data', () {
    test('dark theme uses the Torkk dark palette', () {
      final theme = AppTheme.getTheme(isPink: false, isDark: true);
      final colors = theme.extension<TorkkColors>()!;

      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF101114));
      expect(colors.surface, const Color(0xFF202126));
      expect(theme.colorScheme.primary, const Color(0xFFEEEBDA));
      expect(theme.colorScheme.onPrimary, const Color(0xFF282B4A));
    });

    test('light theme keeps the original look', () {
      final theme = AppTheme.getTheme(isPink: false);

      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, Colors.white);
      expect(theme.colorScheme.primary, AppColors.maleBlue);
      expect(
        theme.extension<TorkkColors>()!.textPrimary,
        AppColors.textPrimary,
      );
    });

    test('pink accent applies in both themes', () {
      expect(
        AppTheme.getTheme(isPink: true).colorScheme.primary,
        AppColors.femalePink,
      );
      expect(
        AppTheme.getTheme(isPink: true, isDark: true).colorScheme.primary,
        TorkkColors.darkPinkAccent,
      );
    });

    test('dark text is readable on dark surfaces', () {
      double contrast(Color a, Color b) {
        final la = a.computeLuminance() + 0.05;
        final lb = b.computeLuminance() + 0.05;
        return la > lb ? la / lb : lb / la;
      }

      const c = TorkkColors.dark;
      expect(contrast(c.textPrimary, c.background), greaterThan(7));
      expect(contrast(c.textPrimary, c.surface), greaterThan(7));
      expect(contrast(c.textSecondary, c.surface), greaterThan(4.5));
      expect(contrast(c.onAccent, c.accent), greaterThan(7));
    });
  });

  group('persistence', () {
    test('defaults to system mode', () async {
      final state = (await _repo()).read();
      expect(state.themeMode, ThemeMode.system);
    });

    test('saved appearance is restored on start', () async {
      final repo = await _repo();
      await repo.saveAppearance('Dark Mode');
      final restored = ThemeRepository(await SharedPreferences.getInstance());
      expect(restored.read().themeMode, ThemeMode.dark);
      expect(restored.read().appearanceLabel, 'Dark Mode');
    });

    test('bloc updates state and saves the choice', () async {
      final repo = await _repo();
      final bloc = ThemeBloc(repo);
      addTearDown(bloc.close);

      bloc.add(const AppearanceSelected('Dark Mode'));
      await bloc.stream.first;
      expect(bloc.state.themeMode, ThemeMode.dark);
      expect(repo.read().themeMode, ThemeMode.dark);

      bloc.add(const AppearanceSelected('Light Mode'));
      await bloc.stream.first;
      expect(bloc.state.themeMode, ThemeMode.light);
      expect(repo.read().themeMode, ThemeMode.light);
    });
  });

  group('app wiring', () {
    Widget app(ThemeBloc bloc, Widget home) {
      return BlocProvider.value(
        value: bloc,
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) => MaterialApp(
            themeMode: state.themeMode,
            theme: AppTheme.getTheme(isPink: state.isPink),
            darkTheme: AppTheme.getTheme(isPink: state.isPink, isDark: true),
            home: home,
          ),
        ),
      );
    }

    testWidgets('toggle switches the whole screen Light -> Dark -> Light', (
      tester,
    ) async {
      final bloc = ThemeBloc(await _repo({'app_theme': 'Light Mode'}));
      addTearDown(bloc.close);
      final key = GlobalKey();
      await tester.pumpWidget(
        app(
          bloc,
          ProfilePage(
            key: key,
            title: 'Settings',
            child: Column(
              children: [
                SettingsChoiceCard(
                  leading: const Icon(Icons.dark_mode),
                  title: 'Card',
                  selected: false,
                  onTap: () {},
                ),
                Builder(
                  builder: (context) =>
                      Text('body', style: AppTypography.regular),
                ),
              ],
            ),
          ),
        ),
      );

      Color? scaffoldColor() =>
          tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor;
      Color? cardColor() {
        final box = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(SettingsChoiceCard),
                matching: find.byType(Container),
              )
              .first,
        );
        return (box.decoration as BoxDecoration).color;
      }

      Color? bodyColor() => tester
          .widget<DefaultTextStyle>(
            find
                .ancestor(
                  of: find.text('body'),
                  matching: find.byType(DefaultTextStyle),
                )
                .first,
          )
          .style
          .color;

      expect(scaffoldColor(), Colors.white);
      expect(cardColor(), Colors.white);

      bloc.add(const AppearanceSelected('Dark Mode'));
      await tester.pumpAndSettle();
      expect(scaffoldColor(), const Color(0xFF101114));
      expect(cardColor(), const Color(0xFF202126));
      expect(bodyColor(), TorkkColors.dark.textPrimary);

      bloc.add(const AppearanceSelected('Light Mode'));
      await tester.pumpAndSettle();
      expect(scaffoldColor(), Colors.white);
      expect(cardColor(), Colors.white);
      expect(bodyColor(), TorkkColors.light.textPrimary);
    });
  });
}
