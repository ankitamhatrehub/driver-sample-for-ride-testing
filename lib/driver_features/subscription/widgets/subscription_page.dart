import 'package:flutter/material.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({
    super.key,
    required this.child,
    this.bottom,
    this.onBack,
    this.showBack = true,
  });

  final Widget child;
  final Widget? bottom;
  final VoidCallback? onBack;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.torkk.background,
      body: SafeArea(
        child: Column(
          children: [
            if (showBack)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: onBack,
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: context.torkk.textPrimary,
                  ),
                ),
              ),
            Expanded(child: child),
            ?bottom,
          ],
        ),
      ),
    );
  }
}

class SubscriptionButton extends StatelessWidget {
  const SubscriptionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.padded = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        padded ? context.w(20) : 0,
        context.h(8),
        padded ? context.w(20) : 0,
        padded ? context.h(16) : 0,
      ),
      child: SizedBox(
        width: double.infinity,
        height: context.h(48),
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: profileAccent(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.r(14)),
            ),
          ),
          child: Text(
            label,
            style: AppTypography.bold.copyWith(
              fontSize: 15,
              height: 1,
              color: Theme.of(context).colorScheme.onPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}
