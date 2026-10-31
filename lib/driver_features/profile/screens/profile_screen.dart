import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rider_app/driver_features/chat/screens/driver_live_chat_screen.dart';
import 'package:rider_app/driver_features/parcels/coming_soon_screen.dart';
import 'package:rider_app/driver_features/settings/legal/privacy_policy_screen.dart';
import 'package:rider_app/driver_features/settings/legal/terms_conditions_users_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/widgets/app_confirm_dialog.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/routes/app_routes.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/coins/screens/coins_screen.dart';
import 'package:rider_app/driver_features/profile/screens/about_torkk_screen.dart';
import 'package:rider_app/driver_features/profile/screens/bank_information_screen.dart';
import 'package:rider_app/driver_features/profile/screens/document_kyc_screen.dart';
import 'package:rider_app/driver_features/profile/screens/faq_screen.dart';
import 'package:rider_app/driver_features/profile/screens/help_support_screen.dart';
import 'package:rider_app/driver_features/profile/screens/personal_information_screen.dart';
import 'package:rider_app/driver_features/profile/screens/privacy_policy_screen.dart';
import 'package:rider_app/driver_features/profile/screens/profile_notifications_screen.dart';
import 'package:rider_app/driver_features/profile/screens/terms_conditions_screen.dart';
import 'package:rider_app/driver_features/profile/screens/vehicle_information_screen.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_header.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/driver_features/subscription/screens/subscription_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: AppStrings.profile,
      onBack: onBack,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(20),
        ),
        children: [
          const ProfileHeader(),
          SizedBox(height: context.h(20)),
          ProfileMenuCard(
            items: [
              ProfileMenuItem(
                icon: Icons.person_outline,
                label: AppStrings.personalInformation,
                accent: true,
                onTap: () => _open(context, const PersonalInformationScreen()),
              ),
              ProfileMenuItem(
                icon: Icons.directions_car_outlined,
                label: AppStrings.vehicleInformation,
                onTap: () => _open(context, const VehicleInformationScreen()),
              ),
              ProfileMenuItem(
                icon: Icons.description_outlined,
                label: AppStrings.documentKycStatus,
                onTap: () => _open(context, const DocumentKycScreen()),
              ),
              ProfileMenuItem(
                icon: Icons.account_balance_outlined,
                label: AppStrings.bankInformation,
                onTap: () => _open(context, const BankInformationScreen()),
              ),
              ProfileMenuItem(
                icon: Icons.verified_outlined,
                label: AppStrings.subscriptionRecharge,
                onTap: () => _open(context, const ComingSoonScreen()),
              ),
              ProfileMenuItem(
                icon: Icons.toll_outlined,
                label: AppStrings.torkkCoins,
                onTap: () => _open(context, const CoinsScreen()),
              ),
            ],
          ),
          SizedBox(height: context.h(14)),
          ProfileMenuCard(
            items: [
              ProfileMenuItem(
                icon: Icons.notifications_none_rounded,
                label: AppStrings.notifications,
                onTap: () => _open(context, const ProfileNotificationsScreen()),
              ),
              ProfileMenuItem(
                icon: Icons.settings_outlined,
                label: AppStrings.settings,
                onTap: () => context.push(AppRoutes.settings),
              ),
              ProfileMenuItem(
                icon: Icons.shield_outlined,
                label: AppStrings.privacyPolicy,
                onTap: () => _open(context, const TorkkPrivacyPolicyScreen()),
              ),
              ProfileMenuItem(
                icon: Icons.article_outlined,
                label: AppStrings.termsConditions,
                onTap: () => _open(context, const TermsConditionsUsersScreen()),
              ),
              ProfileMenuItem(
                icon: Icons.help_outline_rounded,
                label: AppStrings.faq,
                onTap: () => _open(context, const FaqScreen()),
              ),
              ProfileMenuItem(
                icon: Icons.support_agent_rounded,
                label: AppStrings.helpSupport,
                onTap: () => _open(context, const DriverLiveChatScreen()),
              ),
              ProfileMenuItem(
                icon: Icons.info_outline_rounded,
                label: AppStrings.aboutTorkk,
                onTap: () => _open(context, const AboutTorkkScreen()),
              ),
            ],
          ),
          SizedBox(height: context.h(18)),
          UnifiedButton(
            label: AppStrings.logout,
            variant: UnifiedButtonVariant.outline,
            backgroundColor: const Color(0x12DA2527),
            borderColor: const Color(0x45DA2527),
            foregroundColor: const Color(0xFFDA2527),
            icon: Icons.logout_rounded,
            onPressed: () => showProfileLogoutDialog(context),
          ),
        ],
      ),
    );
  }
}

Future<void> showProfileLogoutDialog(BuildContext context) async {
  final confirmed = await showAppConfirmDialog(
    context,
    accent: profileAccent(context),
    icon: const AppDialogBadge(
      icon: Icons.logout_rounded,
      color: Color(0xFFEF4444),
      background: Color(0xFFFEE2E2),
    ),
    title: 'Logout ?',
    subtitle: AppStrings.logoutConfirm,
    confirmLabel: AppStrings.logout,
  );
  if (confirmed != true || !context.mounted) return;
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  if (context.mounted) context.go(AppRoutes.login);
}
