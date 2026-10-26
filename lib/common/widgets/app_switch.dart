import 'package:flutter/material.dart';

import '../theme/torkk_colors.dart';

/// The app's on/off switch: accent track when on, a quiet track when off.
///
/// Light mode keeps the original look (white thumb, accent / light-grey
/// track). Dark mode swaps in dark-palette colors so the thumb never matches
/// its track.
class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.torkk;
    return Switch(
      value: value,
      onChanged: onChanged,
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.onPrimary
            : context.themed(light: Colors.white, dark: colors.textSecondary),
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.primary
            : colors.switchTrackOff,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }
}
