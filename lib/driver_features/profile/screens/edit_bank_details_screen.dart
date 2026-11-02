import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/service/driver_api_service.dart';

/// Bank details the driver can edit. Keys match the API payload.
class BankDetails {
  const BankDetails({
    this.accountHolderName = '',
    this.accountNumber = '',
    this.ifscCode = '',
    this.bankName = '',
    this.branchName = '',
  });

  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String bankName;
  final String branchName;

  /// Reads bank details from a profile response, wherever the backend nests
  /// them.
  factory BankDetails.fromProfile(Map<String, dynamic> profile) {
    final sources = <Map>[profile];
    for (final key in const ['driver', 'data', 'profile', 'bank_details']) {
      final nested = profile[key];
      if (nested is Map) {
        sources.add(nested);
        final inner = nested['bank_details'];
        if (inner is Map) sources.add(inner);
      }
    }
    String pick(List<String> keys) {
      for (final source in sources) {
        for (final key in keys) {
          final v = source[key];
          if (v != null && v.toString().trim().isNotEmpty) {
            return v.toString().trim();
          }
        }
      }
      return '';
    }

    return BankDetails(
      accountHolderName: pick([
        'account_holder_name',
        'bank_account_holder_name',
      ]),
      accountNumber: pick(['account_number', 'bank_account_number']),
      ifscCode: pick(['ifsc_code', 'bank_ifsc_code']),
      bankName: pick(['bank_name']),
      branchName: pick(['branch_name', 'bank_branch_name']),
    );
  }

  bool get isEmpty =>
      accountNumber.isEmpty && bankName.isEmpty && accountHolderName.isEmpty;
}

/// Form to add or replace the driver's bank account. Pops with the saved
/// [BankDetails] on success.
class EditBankDetailsScreen extends StatefulWidget {
  const EditBankDetailsScreen({super.key, this.initial = const BankDetails()});

  final BankDetails initial;

  @override
  State<EditBankDetailsScreen> createState() => _EditBankDetailsScreenState();
}

class _EditBankDetailsScreenState extends State<EditBankDetailsScreen> {
  static final _ifscPattern = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');

  final _formKey = GlobalKey<FormState>();
  late final _holder = TextEditingController(
    text: widget.initial.accountHolderName,
  );
  late final _account = TextEditingController(
    text: widget.initial.accountNumber,
  );
  late final _ifsc = TextEditingController(text: widget.initial.ifscCode);
  late final _bank = TextEditingController(text: widget.initial.bankName);
  late final _branch = TextEditingController(text: widget.initial.branchName);
  bool _saving = false;

  @override
  void dispose() {
    _holder.dispose();
    _account.dispose();
    _ifsc.dispose();
    _bank.dispose();
    _branch.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final details = BankDetails(
      accountHolderName: _holder.text.trim(),
      accountNumber: _account.text.trim(),
      ifscCode: _ifsc.text.trim().toUpperCase(),
      bankName: _bank.text.trim(),
      branchName: _branch.text.trim(),
    );
    setState(() => _saving = true);
    try {
      final response = await DriverApiService.saveBankDetails(
        accountHolderName: details.accountHolderName,
        accountNumber: details.accountNumber,
        ifscCode: details.ifscCode,
        bankName: details.bankName,
        branchName: details.branchName,
      );
      debugPrint('BANK_SCREEN_01 | saved response=$response');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bank details saved successfully')),
      );
      Navigator.of(context).pop(details);
    } catch (e) {
      debugPrint('BANK_SCREEN_02 | save failed: $e');
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  InputDecoration _decoration(
    BuildContext context,
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: context.w(20)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(context.r(12)),
      ),
    );
  }

  Widget _field(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String value) validator,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.words,
    List<TextInputFormatter>? formatters,
    bool last = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.regular.copyWith(
              fontSize: 12,
              color: context.torkk.textSecondary,
            ),
          ),
          SizedBox(height: context.h(6)),
          TextFormField(
            controller: controller,
            enabled: !_saving,
            keyboardType: keyboardType,
            textCapitalization: capitalization,
            inputFormatters: formatters,
            textInputAction: last ? TextInputAction.done : TextInputAction.next,
            onFieldSubmitted: last ? (_) => _submit() : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) => validator((v ?? '').trim()),
            decoration: _decoration(context, hint, icon),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Edit Bank Details',
      subtitle:
          'Earnings are paid to this account. Please double-check the details.',
      bottom: Padding(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(16),
        ),
        child: UnifiedButton(
          label: 'Save Bank Details',
          icon: Icons.check_rounded,
          iconAtEnd: true,
          backgroundColor: const Color(0xFF0F3FBF),
          isLoading: _saving,
          onPressed: _submit,
        ),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            context.w(20),
            context.h(12),
            context.w(20),
            context.h(12),
          ),
          children: [
            _field(
              context,
              label: 'Account holder name',
              hint: 'As per bank records',
              icon: Icons.person_outline,
              controller: _holder,
              validator: (v) =>
                  v.length < 3 ? 'Enter the account holder name' : null,
              formatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z .'-]")),
              ],
            ),
            _field(
              context,
              label: 'Account number',
              hint: 'Enter account number',
              icon: Icons.credit_card_outlined,
              controller: _account,
              keyboardType: TextInputType.number,
              capitalization: TextCapitalization.none,
              validator: (v) => v.length < 9 || v.length > 18
                  ? 'Account number must be 9 to 18 digits'
                  : null,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(18),
              ],
            ),
            _field(
              context,
              label: 'IFSC code',
              hint: 'e.g. HDFC0001234',
              icon: Icons.pin_outlined,
              controller: _ifsc,
              capitalization: TextCapitalization.characters,
              validator: (v) => _ifscPattern.hasMatch(v.toUpperCase())
                  ? null
                  : 'Enter a valid 11 character IFSC code',
              formatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(11),
              ],
            ),
            _field(
              context,
              label: 'Bank name',
              hint: 'e.g. HDFC Bank',
              icon: Icons.account_balance_outlined,
              controller: _bank,
              validator: (v) => v.isEmpty ? 'Enter the bank name' : null,
            ),
            _field(
              context,
              label: 'Branch name',
              hint: 'e.g. Main Branch',
              icon: Icons.location_city_outlined,
              controller: _branch,
              validator: (v) => v.isEmpty ? 'Enter the branch name' : null,
              last: true,
            ),
          ],
        ),
      ),
    );
  }
}
