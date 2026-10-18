import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: AppStrings.personalInformation,
      bottom: const _ProfileEditButton(),
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(28), context.h(30), context.w(28), context.h(20)),
        children: [
          ProfileMenuCard(
            items: [
              ProfileValueRow(icon: Icons.person_outline, label: AppStrings.name, value: 'Rahul'),
              ProfileValueRow(icon: Icons.person_outline, label: AppStrings.gender, value: 'Male'),
              ProfileValueRow(icon: Icons.badge_outlined, label: AppStrings.driversId, value: '6767676767'),
              ProfileValueRow(icon: Icons.phone_outlined, label: AppStrings.mobileNumber, value: '6767676767'),
              ProfileValueRow(icon: Icons.mail_outline, label: AppStrings.emailAddress, value: 'User@gmail.com'),
            ],
          ),
        ],
      ),
    );
  }
}

class VehicleInformationScreen extends StatelessWidget {
  const VehicleInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: AppStrings.vehicleInformation,
      bottom: const _ProfileEditButton(),
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(12), context.w(20), context.h(12)),
        children: [
          const _VehicleHeader(),
          SizedBox(height: context.h(12)),
          ProfileMenuCard(
            items: [
              ProfileValueRow(icon: Icons.confirmation_number_outlined, label: AppStrings.registrationNumber, value: 'MH12AB1234'),
              ProfileValueRow(icon: Icons.two_wheeler_outlined, label: AppStrings.vehicleModel, value: 'Honda Activa'),
              ProfileValueRow(icon: Icons.directions_car_outlined, label: AppStrings.vehicleType, value: 'Two Wheeler'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileEditButton extends StatelessWidget {
  const _ProfileEditButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.w(20),
        context.h(8),
        context.w(20),
        context.h(16),
      ),
      child: UnifiedButton(
        label: AppStrings.edit,
        icon: Icons.edit,
        iconAtEnd: true,
        onPressed: () {},
      ),
    );
  }
}

class _VehicleHeader extends StatelessWidget {
  const _VehicleHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: const Color(0xFFE8EDF5)),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(72),
            height: context.h(48),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(context.r(8)),
            ),
          ),
          SizedBox(width: context.w(12)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.carModel,
                style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.slate500),
              ),
              Text(
                'Cab . 4 Seater',
                style: AppTypography.bold.copyWith(fontSize: 14, height: 1.3, letterSpacing: -0.2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DocumentKycScreen extends StatelessWidget {
  const DocumentKycScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = [
      (Icons.verified_rounded, const Color(0xFF16A34A), 'Aadhaar + PAN', AppStrings.verified, const Color(0xFF16A34A)),
      (Icons.verified_rounded, const Color(0xFF16A34A), 'Driving License', AppStrings.verified, const Color(0xFF16A34A)),
      (Icons.radio_button_unchecked, const Color(0xFFCBD5E1), 'Vehicle RC', AppStrings.pending, const Color(0xFFEF4444)),
      (Icons.radio_button_unchecked, const Color(0xFFCBD5E1), 'Vehicle Photos', AppStrings.notStarted, AppColors.slate400),
      (Icons.radio_button_unchecked, const Color(0xFFCBD5E1), 'Face Verification', AppStrings.notStarted, AppColors.slate400),
      (Icons.radio_button_unchecked, const Color(0xFFCBD5E1), 'Profile Review & Submission', AppStrings.notStarted, AppColors.slate400),
    ];
    return ProfilePage(
      title: AppStrings.documentKyc,
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(12), context.w(20), context.h(20)),
        children: [
          for (final row in rows) ...[
            _KycCard(icon: row.$1, iconColor: row.$2, title: row.$3, status: row.$4, statusColor: row.$5),
            SizedBox(height: context.h(10)),
          ],
        ],
      ),
    );
  }
}

class _KycCard extends StatelessWidget {
  const _KycCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.status,
    required this.statusColor,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(14), vertical: context.h(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: const Color(0xFFE8EDF5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: context.w(22)),
          SizedBox(width: context.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.regular.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                Text(status, style: AppTypography.regular.copyWith(fontSize: 12, color: statusColor)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.slate400, size: context.w(20)),
        ],
      ),
    );
  }
}

class BankInformationScreen extends StatelessWidget {
  const BankInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: AppStrings.bankInformation,
      bottom: ProfileAccentButton(
        label: AppStrings.editReplace,
        icon: Icons.sync_rounded,
        onTap: () {},
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(12), context.w(20), context.h(12)),
        children: [
          Container(
            padding: EdgeInsets.all(context.w(14)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.r(16)),
              border: Border.all(color: const Color(0xFFE8EDF5)),
            ),
            child: Row(
              children: [
                Container(
                  width: context.w(36),
                  height: context.w(36),
                  decoration: BoxDecoration(
                    color: profileAccent(context).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(context.r(10)),
                  ),
                  child: Icon(Icons.account_balance_outlined, color: profileAccent(context), size: context.w(18)),
                ),
                SizedBox(width: context.w(12)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.bankName,
                      style: AppTypography.regular.copyWith(fontSize: 12, color: AppColors.slate500),
                    ),
                    Text(
                      'HDFC Bank',
                      style: AppTypography.bold.copyWith(fontSize: 14, height: 1.3, letterSpacing: -0.2),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: context.h(12)),
          ProfileMenuCard(
            items: [
              ProfileValueRow(icon: Icons.person_outline, label: AppStrings.accountHolderName, value: 'Rahul'),
              ProfileValueRow(icon: Icons.credit_card_outlined, label: AppStrings.accountNumber, value: '123456789012'),
              ProfileValueRow(icon: Icons.account_balance_outlined, label: AppStrings.ifscCode, value: 'HDFC0001234'),
            ],
          ),
        ],
      ),
    );
  }
}
