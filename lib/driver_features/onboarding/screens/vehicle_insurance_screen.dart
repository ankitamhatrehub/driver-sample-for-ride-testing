import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/onboarding/widgets/kyc_form_widgets.dart';
import 'package:rider_app/common/widgets/app_text_field.dart';
import 'package:rider_app/common/widgets/onboarding_step_scaffold.dart';
import 'package:rider_app/common/widgets/unified_button.dart';

/// Insurance step. Upload and verification come later. Skip continues onboarding.
class VehicleInsuranceScreen extends StatefulWidget {
  const VehicleInsuranceScreen({
    super.key,
    required this.onBack,
    required this.onHelp,
    required this.onSkip,
  });

  final VoidCallback onBack;
  final VoidCallback onHelp;
  final VoidCallback onSkip;

  @override
  State<VehicleInsuranceScreen> createState() => _VehicleInsuranceScreenState();
}

class _VehicleInsuranceScreenState extends State<VehicleInsuranceScreen> {
  final _insuranceExpiry = TextEditingController();
  final _permitExpiry = TextEditingController();
  bool _commercialPermit = false;

  @override
  void dispose() {
    _insuranceExpiry.dispose();
    _permitExpiry.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    setState(() {
      controller.text = '${picked.day} ${months[picked.month - 1]} ${picked.year}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.vehicleInsurance,
      onBack: widget.onBack,
      onHelp: widget.onHelp,
      headerAction: TextButton(
        onPressed: widget.onSkip,
        child: Text(
          AppStrings.skip,
          style: AppTypography.bold.copyWith(fontSize: 15, color: AppColors.primary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(context.w(24), context.h(8), context.w(24), context.h(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KycUploadTile(label: AppStrings.uploadInsurance, uploaded: false, onTap: () {}),
            SizedBox(height: context.h(16)),
            Text('${AppStrings.expiryDate} *', style: AppTypography.regular.copyWith(fontSize: 13)),
            SizedBox(height: context.h(8)),
            _dateField(_insuranceExpiry),
            SizedBox(height: context.h(16)),
            Row(
              children: [
                Expanded(
                  child: Text(AppStrings.permitIfApplicable, style: AppTypography.regular.copyWith(fontSize: 13)),
                ),
                Text(AppStrings.commercialPermit, style: AppTypography.regular.copyWith(fontSize: 12)),
                SizedBox(width: context.w(8)),
                Switch(
                  value: _commercialPermit,
                  activeThumbColor: AppColors.primary,
                  onChanged: (value) => setState(() => _commercialPermit = value),
                ),
              ],
            ),
            SizedBox(height: context.h(8)),
            KycUploadTile(label: AppStrings.uploadPermit, uploaded: false, onTap: () {}),
            SizedBox(height: context.h(16)),
            Text('${AppStrings.expiryDate} *', style: AppTypography.regular.copyWith(fontSize: 13)),
            SizedBox(height: context.h(8)),
            _dateField(_permitExpiry),
            SizedBox(height: context.h(16)),
            Text(AppStrings.preview, style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2)),
            SizedBox(height: context.h(10)),
            KycPreviewCard(onRetake: () {}),
            SizedBox(height: context.h(16)),
            const KycPendingBanner(title: AppStrings.verificationPending),
            SizedBox(height: context.h(24)),
            UnifiedButton(label: AppStrings.continueAction, onPressed: widget.onSkip),
          ],
        ),
      ),
    );
  }

  Widget _dateField(TextEditingController controller) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        AppTextField(controller: controller, hintText: AppStrings.expiryDate),
        IconButton(
          onPressed: () => _pickDate(controller),
          icon: Icon(Icons.calendar_today_outlined, size: context.w(18), color: AppColors.secondaryTextColor),
        ),
      ],
    );
  }
}
