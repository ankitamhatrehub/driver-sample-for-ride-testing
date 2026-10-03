import 'package:flutter/material.dart';
import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';

Color profileAccent(BuildContext context) => Theme.of(context).colorScheme.primary;

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.bottom,
    this.onBack,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final Widget? bottom;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(context.w(8), context.h(4), context.w(16), 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack ?? () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2, letterSpacing: -0.4),
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
            if (subtitle != null)
              Padding(
                padding: EdgeInsets.only(left: 56, right: context.w(60), bottom: context.h(12)),
                child: SizedBox(
                  width: context.w(281),
                  child: Text(
                    subtitle!,
                    style: AppTypography.regular.copyWith(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.secondaryTextColor,
                    ),
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

class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({super.key, required this.items});

  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFF1F5F9)),
            items[i],
          ],
        ],
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ? profileAccent(context) : AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.w(14), vertical: context.h(14)),
        child: Row(
          children: [
            Icon(icon, size: context.w(20), color: color),
            SizedBox(width: context.w(14)),
            Expanded(
              child: Text(
                label,
                style: AppTypography.regular.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.slate400, size: context.w(20)),
          ],
        ),
      ),
    );
  }
}

class ProfileValueRow extends StatelessWidget {
  const ProfileValueRow({
    super.key,
    required this.icon,
    required this.label,
    this.value = '',
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(14), vertical: context.h(12)),
      child: Row(
        children: [
          Icon(icon, size: context.w(18), color: AppColors.textPrimary),
          SizedBox(width: context.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.regular.copyWith(fontSize: 11, color: AppColors.slate500),
                ),
                SizedBox(height: context.h(4)),
                if (value.isNotEmpty)
                  Text(
                    value,
                    style: AppTypography.bold.copyWith(
                      fontSize: 12,
                      height: 1.3,
                      letterSpacing: -0.2,
                      color: valueColor ?? AppColors.textPrimary,
                    ),
                  ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.slate400, size: context.w(20)),
        ],
      ),
    );
  }
}

class ProfileTitleScreen extends StatelessWidget {
  const ProfileTitleScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ProfilePage(title: title, child: const SizedBox.shrink());
  }
}

class ProfileAccentButton extends StatelessWidget {
  const ProfileAccentButton({super.key, required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(16)),
      child: SizedBox(
        width: double.infinity,
        height: context.h(48),
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: profileAccent(context),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(14))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTypography.bold.copyWith(fontSize: 15, height: 1, color: Colors.white, letterSpacing: -0.2),
              ),
              SizedBox(width: context.w(8)),
              Icon(icon, size: context.w(18), color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
