import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

/// Shared result layout.
///
/// [celebration] shows the confetti behind [icon]. [title] and [subtitle]
/// sit under that icon. [child] is any extra content below the subtitle.
/// [button] sits at the bottom, with an optional [extraButton] under it.
class StatusResult extends StatelessWidget {
  const StatusResult({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.button,
    this.child,
    this.celebration = false,
    this.extraButton,
    this.onBack,
  });

  final bool celebration;
  final Widget icon;
  final String title;
  final String subtitle;
  final Widget? child;
  final Widget button;
  final Widget? extraButton;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.torkk.background,
      body: SafeArea(
        child: Column(
          children: [
            if (onBack != null)
              Padding(
                padding: EdgeInsets.only(left: context.w(24), top: context.h(20)),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: context.themed(light: Colors.black, dark: context.torkk.textPrimary), size: 24),
                    onPressed: onBack,
                  ),
                ),
              ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(context.w(20), 0, context.w(20), context.h(16)),
                children: [
                  _hero(context),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTypography.bold.copyWith(fontSize: 20, height: 1.25),
                  ),
                  SizedBox(height: context.h(8)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(20)),
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.regular.copyWith(
                        fontSize: 12,
                        height: 1.45,
                        color: context.torkk.textSecondary,
                      ),
                    ),
                  ),
                  if (child != null) ...[
                    SizedBox(height: context.h(28)),
                    child!,
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(16)),
              child: Column(
                children: [
                  button,
                  if (extraButton != null) ...[
                    SizedBox(height: context.h(12)),
                    extraButton!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero(BuildContext context) {
    if (!celebration) return Center(child: icon);
    return SizedBox(
      height: context.h(200),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ColorFiltered(
            colorFilter: const ColorFilter.matrix(<double>[
              1, 0, 0, 0, 0,
              0, 1, 0, 0, 0,
              0, 0, 1, 0, 0,
              1, 1, 1, 0, 0,
            ]),
            child: Image.asset(
              AppAssets.celebration,
              width: context.w(316),
              height: context.h(200),
              fit: BoxFit.contain,
            ),
          ),
          icon,
        ],
      ),
    );
  }
}
