import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rider_app/app/theme/theme_bloc.dart';
import 'package:rider_app/app/theme/theme_event.dart';
import 'package:rider_app/app/theme/theme_state.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/driver_features/settings/widgets/settings_choice_card.dart';

import '../../../common/constants/string_constants.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class DriverAppearanceScreen extends StatelessWidget {
  const DriverAppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return ProfilePage(
          title: AppStrings.appearance,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              context.w(20),
              context.h(8),
              context.w(20),
              context.h(20),
            ),
            children: [
              Text(
                AppStrings.chooseYourAppearance,
                style: AppTypography.regular.copyWith(
                  fontSize: 13,
                  color: context.torkk.textSecondary,
                ),
              ),
              SizedBox(height: context.h(14)),
              SettingsChoiceCard(
                selected: state.appearanceLabel == 'Light Mode',
                title: AppStrings.lightMode,
                onTap: () => context.read<ThemeBloc>().add(
                  const AppearanceSelected('Light Mode'),
                ),
                leading: _mark(
                  Icons.light_mode_rounded,
                  const Color(0xFFF59E0B),
                ),
              ),
              SettingsChoiceCard(
                selected: state.appearanceLabel == 'Dark Mode',
                title: AppStrings.darkMode,
                onTap: () => context.read<ThemeBloc>().add(
                  const AppearanceSelected('Dark Mode'),
                ),
                leading: _mark(
                  Icons.dark_mode_rounded,
                  const Color(0xFF7C3AED),
                ),
              ),
              SettingsChoiceCard(
                selected: state.appearanceLabel == 'Default',
                title: AppStrings.systemDefault,
                onTap: () => context.read<ThemeBloc>().add(
                  const AppearanceSelected('Default'),
                ),
                leading: _mark(
                  Icons.grid_view_rounded,
                  const Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _mark(IconData icon, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}
