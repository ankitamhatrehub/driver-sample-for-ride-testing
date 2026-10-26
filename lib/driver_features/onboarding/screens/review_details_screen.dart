import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class ReviewDetailsScreen extends StatelessWidget {
  const ReviewDetailsScreen({
    super.key,
    required this.gender,
    required this.name,
    required this.email,
    required this.bankName,
    this.aadhaarNumber = '',
    this.panNumber = '',
    this.licenceNumber = '',
    this.vehicleType = '',
    this.registrationNumber = '',
    this.photosUploaded = false,
    this.faceVerified = false,
    this.accountHolder = '',
    this.accountNumber = '',
    this.ifsc = '',
    required this.onBack,
    required this.onEditPersonal,
    required this.onEditKyc,
    required this.onEditVehicle,
    required this.onEditBank,
    required this.onSubmit,
    required this.personalDone,
    required this.kycDone,
    required this.vehicleDone,
    required this.bankDone,
    this.isLoading = false,
  });

  final String gender;
  final String name;
  final String email;
  final String bankName;
  final String aadhaarNumber;
  final String panNumber;
  final String licenceNumber;
  final String vehicleType;
  final String registrationNumber;
  final bool photosUploaded;
  final bool faceVerified;
  final String accountHolder;
  final String accountNumber;
  final String ifsc;
  final VoidCallback onBack;
  final VoidCallback onEditPersonal;
  final VoidCallback onEditKyc;
  final VoidCallback onEditVehicle;
  final VoidCallback onEditBank;
  final VoidCallback onSubmit;
  final bool personalDone;
  final bool kycDone;
  final bool vehicleDone;
  final bool bankDone;
  final bool isLoading;

  Color get _accent =>
      gender == AppStrings.genderFemale ? AppColors.femalePink : AppColors.maleBlue;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: context.torkk.background,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: context.themed(light: Colors.black, dark: context.torkk.textPrimary), size: 20),
            onPressed: onBack,
          ),
          titleSpacing: 0,
          centerTitle: false,
          backgroundColor: context.torkk.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: Text(
            AppStrings.reviewYourDetails,
            style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(context.w(20), context.h(50), context.w(20), context.h(16)),
                children: [
                  _detailCard(
                    context,
                    title: AppStrings.personalDetails,
                    done: personalDone,
                    onEdit: onEditPersonal,
                    rows: [
                      if (name.isNotEmpty) _Detail(Icons.person_outline, AppStrings.fullName, name),
                      if (gender.isNotEmpty) _Detail(Icons.badge_outlined, AppStrings.gender, gender),
                      if (email.isNotEmpty) _Detail(Icons.mail_outline, AppStrings.emailAddress, email),
                    ],
                  ),
                  SizedBox(height: context.h(12)),
                  _detailCard(
                    context,
                    title: AppStrings.kycDocuments,
                    done: kycDone,
                    onEdit: onEditKyc,
                    rows: [
                      if (aadhaarNumber.isNotEmpty)
                        _Detail(Icons.badge_outlined, AppStrings.aadhaarCardNumber, aadhaarNumber),
                      if (panNumber.isNotEmpty) _Detail(Icons.credit_card, AppStrings.panNumber, panNumber),
                      if (licenceNumber.isNotEmpty)
                        _Detail(Icons.card_membership_outlined, AppStrings.licenseNumber, licenceNumber),
                      if (faceVerified) _Detail(Icons.face_outlined, AppStrings.kycFaceVerification, AppStrings.kycVerified),
                    ],
                  ),
                  SizedBox(height: context.h(12)),
                  _detailCard(
                    context,
                    title: AppStrings.vehicleDetails,
                    done: vehicleDone,
                    onEdit: onEditVehicle,
                    rows: [
                      if (vehicleType.isNotEmpty)
                        _Detail(Icons.directions_car_outlined, AppStrings.vehicleType, vehicleType),
                      if (registrationNumber.isNotEmpty)
                        _Detail(Icons.pin_outlined, AppStrings.registrationNumber, registrationNumber),
                      if (photosUploaded) _Detail(Icons.photo_camera_outlined, AppStrings.vehiclePhotos, AppStrings.rcUploaded),
                    ],
                  ),
                  SizedBox(height: context.h(12)),
                  _detailCard(
                    context,
                    title: AppStrings.bankDetails,
                    done: bankDone,
                    onEdit: onEditBank,
                    rows: [
                      if (accountHolder.isNotEmpty)
                        _Detail(Icons.person_outline, AppStrings.accountHolderName, accountHolder),
                      if (accountNumber.isNotEmpty)
                        _Detail(Icons.numbers, AppStrings.accountNumber, accountNumber),
                      if (ifsc.isNotEmpty) _Detail(Icons.tag, AppStrings.ifscCode, ifsc),
                      if (bankName.isNotEmpty) _Detail(Icons.account_balance, AppStrings.bankName, bankName),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(16)),
              child: UnifiedButton(
                label: AppStrings.submit,
                backgroundColor: _accent,
                isLoading: isLoading,
                onPressed: onSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailCard(
    BuildContext context, {
    required String title,
    required bool done,
    required VoidCallback onEdit,
    required List<_Detail> rows,
  }) {
    return Container(
      decoration: _cardDecoration(context),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(context.w(14), context.h(14), context.w(14), context.h(14)),
            child: Row(
              children: [
                _mark(context, done),
                SizedBox(width: context.w(8)),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.bold.copyWith(fontSize: 15, height: 1.2),
                  ),
                ),
                _pencil(context, onEdit),
              ],
            ),
          ),
          for (final row in rows) _infoRow(context, row.icon, row.label, row.value),
        ],
      ),
    );
  }

  Widget _mark(BuildContext context, bool done) {
    if (done) {
      return Icon(Icons.check_circle, color: AppColors.green600, size: context.w(22));
    }
    return Container(
      width: context.w(22),
      height: context.w(22),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.slate300, width: 1.6),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      height: context.h(63),
      padding: EdgeInsets.symmetric(horizontal: context.w(14)),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.torkk.border)),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(36),
            height: context.w(36),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(context.r(10)),
            ),
            child: Icon(icon, size: context.w(18), color: _accent),
          ),
          SizedBox(width: context.w(12)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.regular.copyWith(
                    fontSize: 12,
                    height: 1.2,
                    color: context.torkk.textSecondary,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pencil(BuildContext context, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(Icons.edit_outlined, color: _accent, size: context.w(20)),
    );
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: context.torkk.surface,
      borderRadius: BorderRadius.circular(context.r(16)),
      border: Border.all(color: context.torkk.border),
      boxShadow: const [
        BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 3),
      ],
    );
  }
}

class _Detail {
  const _Detail(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}
