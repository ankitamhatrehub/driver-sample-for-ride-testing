import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rider_app/app/theme/theme_bloc.dart';
import 'package:rider_app/app/theme/theme_event.dart';
import 'package:rider_app/app/theme/theme_state.dart';
import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/driver_features/settings/widgets/settings_choice_card.dart';

class DriverAppearanceScreen extends StatelessWidget {
  const DriverAppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return ProfilePage(
          title: 'Appearance',
          child: ListView(
            padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(20)),
            children: [
              Text(
                'Choose your appearance',
                style: AppTypography.regular.copyWith(fontSize: 13, color: AppColors.slate500),
              ),
              SizedBox(height: context.h(14)),
              SettingsChoiceCard(
                selected: state.appearanceLabel == 'Light Mode',
                title: 'Light mode',
                onTap: () => context.read<ThemeBloc>().add(const AppearanceSelected('Light Mode')),
                leading: _mark(Icons.light_mode_rounded, const Color(0xFFF59E0B), const Color(0xFFFFF7ED)),
              ),
              SettingsChoiceCard(
                selected: state.appearanceLabel == 'Dark Mode',
                title: 'Dark mode',
                onTap: () => context.read<ThemeBloc>().add(const AppearanceSelected('Dark Mode')),
                leading: _mark(Icons.dark_mode_rounded, const Color(0xFF7C3AED), const Color(0xFFF3E8FF)),
              ),
              SettingsChoiceCard(
                selected: state.appearanceLabel == 'Default',
                title: 'System Default',
                onTap: () => context.read<ThemeBloc>().add(const AppearanceSelected('Default')),
                leading: _mark(Icons.grid_view_rounded, const Color(0xFF7C3AED), const Color(0xFFF3E8FF)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _mark(IconData icon, Color color, Color background) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: color, size: 18),
    );
  }
}
