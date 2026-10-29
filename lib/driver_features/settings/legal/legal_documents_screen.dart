import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/driver_features/settings/legal/cancellation_refund_policy_screen.dart';
import 'package:rider_app/driver_features/settings/legal/drivers_riders_agreement_screen.dart';
import 'package:rider_app/driver_features/settings/legal/privacy_policy_screen.dart';
import 'package:rider_app/driver_features/settings/legal/terms_conditions_users_screen.dart';

/// Settings -> Legal & Policies: one row per document.
class LegalDocumentsScreen extends StatelessWidget {
  const LegalDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Legal & Policies',
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(12),
          context.w(20),
          context.h(20),
        ),
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.r(16)),
              border: Border.all(color: context.torkk.border),
            ),
            child: Column(
              children: [
                _LegalRow(
                  icon: Icons.verified_user_outlined,
                  label: 'Privacy Policy',
                  screen: const TorkkPrivacyPolicyScreen(),
                ),
                const _LegalDivider(),
                _LegalRow(
                  icon: Icons.description_outlined,
                  label: 'Terms and Conditions',
                  screen: const TermsConditionsUsersScreen(),
                ),
                const _LegalDivider(),
                _LegalRow(
                  icon: Icons.currency_rupee_rounded,
                  label: 'Refund & Cancellation Policy',
                  screen: const CancellationRefundPolicyScreen(),
                ),
                const _LegalDivider(),
                _LegalRow(
                  icon: Icons.handshake_outlined,
                  label: 'Driver Agreement',
                  screen: const DriversRidersAgreementScreen(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalRow extends StatelessWidget {
  const _LegalRow({
    required this.icon,
    required this.label,
    required this.screen,
  });

  final IconData icon;
  final String label;
  final Widget screen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => screen)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(14),
          vertical: context.h(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: context.torkk.textPrimary, size: context.w(20)),
            SizedBox(width: context.w(12)),
            Expanded(
              child: Text(
                label,
                style: AppTypography.regular.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.slate400,
              size: context.w(22),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalDivider extends StatelessWidget {
  const _LegalDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: context.torkk.border);
  }
}
