import 'dart:async';

import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/onboarding/widgets/kyc_form_widgets.dart';
import 'package:rider_app/common/widgets/app_text_field.dart';
import 'package:rider_app/common/widgets/onboarding_info_banner.dart';
import 'package:rider_app/common/widgets/onboarding_step_scaffold.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

part 'bank_payout_screen_parts/bank_step.dart';
part 'bank_payout_screen_parts/reason.dart';
part 'bank_payout_screen_sections.dart';

enum _BankPage { form, verifying, verified, failed }

class BankPayoutScreen extends StatefulWidget {
  const BankPayoutScreen({
    super.key,
    required this.onBack,
    required this.onHelp,
    required this.onFinished,
  });

  final VoidCallback onBack;
  final VoidCallback onHelp;
  final ValueChanged<BankPayoutDetails> onFinished;

  @override
  State<BankPayoutScreen> createState() => _BankPayoutScreenState();
}

class _BankPayoutScreenState extends State<BankPayoutScreen> {
  _BankPage _page = _BankPage.form;
  int _bankDone = 0;
  String _submittedAt = '';
  Timer? _bankTimer;
  final _name = TextEditingController();
  final _account = TextEditingController();
  final _confirm = TextEditingController();
  final _ifsc = TextEditingController();
  final _bank = TextEditingController();

  @override
  void dispose() {
    _bankTimer?.cancel();
    _name.dispose();
    _account.dispose();
    _confirm.dispose();
    _ifsc.dispose();
    _bank.dispose();
    super.dispose();
  }

  void _go(_BankPage page) => setState(() => _page = page);

  void _startVerifying() {
    _bankTimer?.cancel();
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    setState(() {
      _submittedAt =
          '${now.day} ${months[now.month - 1]} ${now.year}, $hour:$minute $period';
      _bankDone = 1;
      _page = _BankPage.verifying;
    });
    _bankTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_bankDone < 3) _bankDone += 1;
        if (_bankDone >= 3) timer.cancel();
      });
    });
  }

  bool get _matches =>
      _account.text.isNotEmpty &&
      _account.text == _confirm.text &&
      _ifsc.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return switch (_page) {
      _BankPage.form => _form(context),
      _BankPage.verifying => _verifying(context),
      _BankPage.verified => _verified(context),
      _BankPage.failed => _failed(context),
    };
  }
}

class BankPayoutDetails {
  const BankPayoutDetails({
    required this.holderName,
    required this.accountNumber,
    required this.ifsc,
    required this.bankName,
  });

  final String holderName;
  final String accountNumber;
  final String ifsc;
  final String bankName;
}
