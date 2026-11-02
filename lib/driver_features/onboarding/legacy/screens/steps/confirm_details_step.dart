import 'package:flutter/material.dart';
import 'package:rider_app/common/widgets/bouncing_widget.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class ConfirmDetailsStep extends StatefulWidget {
  final Color primaryColor;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController dobController;
  final String selectedVehicleType;
  final String selectedGender;
  final TextEditingController aadhaarNumberController;
  final TextEditingController dlNumberController;
  final TextEditingController rcNumberController;
  final TextEditingController pucNumberController;
  final TextEditingController pucTotalMarksController;
  final TextEditingController insuranceNumberController;
  final String faceMatchStatus;
  final double faceMatchScore;
  final TextEditingController bankNameController;
  final TextEditingController bankAccountNumberController;
  final TextEditingController upiIdController;
  final VoidCallback onConfirm;
  final VoidCallback? onDetailsEdited;

  const ConfirmDetailsStep({
    super.key,
    required this.primaryColor,
    required this.nameController,
    required this.phoneController,
    required this.dobController,
    required this.selectedVehicleType,
    required this.selectedGender,
    required this.aadhaarNumberController,
    required this.dlNumberController,
    required this.rcNumberController,
    required this.pucNumberController,
    required this.pucTotalMarksController,
    required this.insuranceNumberController,
    required this.faceMatchStatus,
    required this.faceMatchScore,
    required this.bankNameController,
    required this.bankAccountNumberController,
    required this.upiIdController,
    required this.onConfirm,
    this.onDetailsEdited,
  });

  @override
  State<ConfirmDetailsStep> createState() => _ConfirmDetailsStepState();
}

class _ConfirmDetailsStepState extends State<ConfirmDetailsStep> {
  Widget _detailFieldRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Colors.blueGrey.shade400),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blueGrey.shade400,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.torkk.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStyledEditField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.torkk.textBody,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.torkk.textPrimary,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              size: 20,
              color: context.legible(Color(0xFF6366F1)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            filled: true,
            fillColor: context.torkk.surfaceMuted,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.torkk.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.torkk.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: context.legible(Color(0xFF6366F1)),
                width: 1.8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: context.torkk.surface,
        elevation: 16,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: Color(0xFF6366F1),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.torkk.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Update your submitted info',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.torkk.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: context.torkk.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: context.torkk.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStyledEditField(
                        'Full Name',
                        widget.nameController,
                        Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 12),
                      _buildStyledEditField(
                        'Date of Birth (YYYY-MM-DD)',
                        widget.dobController,
                        Icons.calendar_today_rounded,
                      ),
                      const SizedBox(height: 12),
                      _buildStyledEditField(
                        'Aadhaar Number',
                        widget.aadhaarNumberController,
                        Icons.badge_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildStyledEditField(
                        'DL Number',
                        widget.dlNumberController,
                        Icons.credit_card_rounded,
                      ),
                      const SizedBox(height: 12),
                      _buildStyledEditField(
                        'RC Number',
                        widget.rcNumberController,
                        Icons.directions_car_rounded,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(
                          color: Color(0xFFCBD5E1),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        foregroundColor: context.legible(Color(0xFF475569)),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF6366F1,
                            ).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {});
                          widget.onDetailsEdited?.call();
                        },
                        icon: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            'Confirm Your Details',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: context.torkk.textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.torkk.surfaceMuted,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.torkk.border),
              ),
              child: ListView(
                children: [
                  _detailFieldRow(
                    Icons.person_outline,
                    'Name',
                    widget.nameController.text,
                  ),
                  const Divider(height: 28),
                  _detailFieldRow(
                    Icons.phone_android_outlined,
                    'Mobile',
                    widget.phoneController.text,
                  ),
                  const Divider(height: 28),
                  _detailFieldRow(
                    Icons.cake_outlined,
                    'DOB',
                    widget.dobController.text,
                  ),
                  const Divider(height: 28),
                  _detailFieldRow(
                    Icons.directions_car_filled_outlined,
                    'Vehicle Type',
                    widget.selectedVehicleType,
                  ),
                  const Divider(height: 28),
                  _detailFieldRow(
                    Icons.face_outlined,
                    'Gender',
                    widget.selectedGender,
                  ),
                  const Divider(height: 28),
                  _detailFieldRow(
                    Icons.credit_card_outlined,
                    'Aadhaar Number',
                    widget.aadhaarNumberController.text,
                  ),
                  const Divider(height: 28),
                  _detailFieldRow(
                    Icons.badge_outlined,
                    'DL Number',
                    widget.dlNumberController.text,
                  ),
                  const Divider(height: 28),
                  _detailFieldRow(
                    Icons.description_outlined,
                    'RC Number',
                    widget.rcNumberController.text,
                  ),
                  const Divider(height: 28),
                  _detailFieldRow(
                    Icons.receipt_long_outlined,
                    'PUC Number',
                    widget.pucNumberController.text,
                  ),
                  const Divider(height: 28),
                  _detailFieldRow(
                    Icons.grade_outlined,
                    'PUC Total Marks',
                    widget.pucTotalMarksController.text,
                  ),
                  const Divider(height: 28),
                  _detailFieldRow(
                    Icons.security_outlined,
                    'Insurance Number',
                    widget.insuranceNumberController.text,
                  ),
                  const Divider(height: 28),
                  _detailFieldRow(
                    Icons.face_retouching_natural_outlined,
                    'Face Match',
                    '${widget.faceMatchStatus} (${widget.faceMatchScore.toStringAsFixed(1)}%)',
                  ),
                  const Divider(height: 28),
                  _detailFieldRow(
                    Icons.account_balance_outlined,
                    'Bank Account',
                    '${widget.bankNameController.text} - ${widget.bankAccountNumberController.text}',
                  ),
                  const Divider(height: 28),
                  _detailFieldRow(
                    Icons.payment_outlined,
                    'UPI ID',
                    widget.upiIdController.text.isNotEmpty
                        ? widget.upiIdController.text
                        : 'N/A',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          BouncingWidget(
            onTap: widget.onConfirm,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: widget.primaryColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Confirm & Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: _showEditDialog,
              child: Text(
                'Edit Details',
                style: TextStyle(
                  color: Colors.blueGrey.shade400,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
