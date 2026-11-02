part of 'package:rider_app/driver_features/onboarding/screens/bank_payout_screen.dart';

extension _BankPayoutScreenStateSections on _BankPayoutScreenState {
  Widget _form(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.bankPayoutDetails,
      onBack: widget.onBack,
      onHelp: widget.onHelp,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          context.w(24),
          context.h(8),
          context.w(24),
          context.h(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: context.w(12),
                vertical: context.h(10),
              ),
              decoration: BoxDecoration(
                color: context.adaptiveTint(const Color(0xFFF0FDF4)),
                borderRadius: BorderRadius.circular(context.r(12)),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: context.legible(AppColors.green600),
                    size: context.w(16),
                  ),
                  SizedBox(width: context.w(8)),
                  Text(
                    AppStrings.informationSecure,
                    style: AppTypography.regular.copyWith(
                      fontSize: 12,
                      color: context.legible(AppColors.green600),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.h(16)),
            KycRequiredLabel(AppStrings.accountHolderName),
            SizedBox(height: context.h(8)),
            AppTextField(controller: _name),
            SizedBox(height: context.h(14)),
            KycRequiredLabel(AppStrings.accountNumber),
            SizedBox(height: context.h(8)),
            AppTextField(
              controller: _account,
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            SizedBox(height: context.h(14)),
            KycRequiredLabel(AppStrings.confirmAccountNumber),
            SizedBox(height: context.h(8)),
            AppTextField(
              controller: _confirm,
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            SizedBox(height: context.h(14)),
            Row(
              children: [
                Expanded(child: KycRequiredLabel(AppStrings.ifscCode)),
                Text(
                  AppStrings.findIfsc,
                  style: AppTypography.bold.copyWith(
                    fontSize: 12,
                    color: AppColors.green600,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.h(8)),
            AppTextField(controller: _ifsc),
            SizedBox(height: context.h(14)),
            KycRequiredLabel(AppStrings.bankName),
            SizedBox(height: context.h(8)),
            AppTextField(controller: _bank),
            SizedBox(height: context.h(14)),
            KycPendingBanner(title: AppStrings.verificationPending),
            SizedBox(height: context.h(24)),
            UnifiedButton(
              label: AppStrings.saveAndVerify,
              onPressed: () =>
                  _matches ? _startVerifying() : _go(_BankPage.failed),
            ),
          ],
        ),
      ),
    );
  }

  Widget _verifying(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.bankPayoutDetails,
      onBack: () => _go(_BankPage.form),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          context.w(24),
          context.h(24),
          context.w(24),
          context.h(16),
        ),
        child: Column(
          children: [
            SizedBox(
              width: context.w(84),
              height: context.w(84),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: context.w(36),
                    backgroundColor: context.adaptiveTint(
                      const Color(0xFFF5F3FF),
                    ),
                    child: Icon(
                      Icons.account_balance,
                      color: context.legible(AppColors.primary),
                      size: context.w(32),
                    ),
                  ),
                  if (_bankDone < 3)
                    Positioned(
                      right: context.w(6),
                      bottom: context.w(6),
                      child: SizedBox(
                        width: context.w(18),
                        height: context.w(18),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.legible(AppColors.primary),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: context.h(16)),
            Text(
              AppStrings.verifyingBank,
              style: AppTypography.bold.copyWith(fontSize: 18, height: 1.2),
            ),
            SizedBox(height: context.h(6)),
            Text(
              AppStrings.verifyingBankSubtitle,
              textAlign: TextAlign.center,
              style: AppTypography.regular.copyWith(
                fontSize: 13,
                color: context.torkk.textSecondary,
              ),
            ),
            SizedBox(height: context.h(24)),
            _BankStep(
              label: AppStrings.bankDetailsSubmitted,
              note: _submittedAt,
              done: _bankDone >= 1,
              active: false,
            ),
            _BankStep(
              label: AppStrings.verifyingAccountWithBank,
              note: _bankDone == 1 ? AppStrings.bankVerifyWait : null,
              done: _bankDone >= 2,
              active: _bankDone == 1,
            ),
            _BankStep(
              label: AppStrings.confirmingAccountDetails,
              note: _bankDone == 2 ? AppStrings.bankVerifyWait : null,
              done: _bankDone >= 3,
              active: _bankDone == 2,
              last: true,
            ),
            const Spacer(),
            OnboardingInfoBanner(message: AppStrings.bankEncryptedHint),
            SizedBox(height: context.h(16)),
            UnifiedButton(
              label: AppStrings.continueAction,
              enabled: _bankDone >= 3,
              onPressed: () {
                _bankTimer?.cancel();
                _go(_BankPage.verified);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _verified(BuildContext context) {
    return Scaffold(
      backgroundColor: context.torkk.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            context.w(24),
            context.h(36),
            context.w(24),
            context.h(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  AppAssets.verifiedIcon,
                  width: context.w(96),
                  height: context.w(96),
                ),
              ),
              SizedBox(height: context.h(12)),
              Center(
                child: Text(
                  AppStrings.bankDetailsVerified,
                  style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2),
                ),
              ),
              SizedBox(height: context.h(8)),
              Text(
                AppStrings.bankDetailsVerifiedSubtitle,
                textAlign: TextAlign.center,
                style: AppTypography.regular.copyWith(
                  fontSize: 14,
                  color: context.torkk.textSecondary,
                ),
              ),
              SizedBox(height: context.h(20)),
              Text(
                AppStrings.bankAccountDetails,
                style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2),
              ),
              SizedBox(height: context.h(8)),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.r(12)),
                  border: Border.all(color: context.torkk.border),
                ),
                child: Column(
                  children: [
                    KycDetailRow(
                      icon: Icons.person_outline,
                      label: AppStrings.accountHolderName,
                      value: _name.text,
                    ),
                    KycDetailRow(
                      icon: Icons.credit_card,
                      label: AppStrings.accountNumber,
                      value: '*' * _account.text.length,
                    ),
                    KycDetailRow(
                      icon: Icons.account_balance_outlined,
                      label: AppStrings.ifscCode,
                      value: _ifsc.text,
                    ),
                    KycDetailRow(
                      icon: Icons.account_balance,
                      label: AppStrings.bankName,
                      value: _bank.text,
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.h(14)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(context.w(12)),
                decoration: BoxDecoration(
                  color: context.adaptiveTint(const Color(0xFFF0FDF4)),
                  borderRadius: BorderRadius.circular(context.r(12)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: context.legible(AppColors.green600),
                      size: context.w(16),
                    ),
                    SizedBox(width: context.w(8)),
                    Expanded(
                      child: Text(
                        AppStrings.bankReadyHint,
                        style: AppTypography.regular.copyWith(
                          fontSize: 12,
                          color: context.legible(AppColors.green600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              UnifiedButton(
                label: AppStrings.continueAction,
                onPressed: () => widget.onFinished(
                  BankPayoutDetails(
                    holderName: _name.text.trim(),
                    accountNumber: _account.text.trim(),
                    ifsc: _ifsc.text.trim(),
                    bankName: _bank.text.trim(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _failed(BuildContext context) {
    return Scaffold(
      backgroundColor: context.torkk.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            context.w(24),
            context.h(48),
            context.w(24),
            context.h(16),
          ),
          child: Column(
            children: [
              Image.asset(
                AppAssets.failedIcon,
                width: context.w(96),
                height: context.w(96),
              ),
              SizedBox(height: context.h(16)),
              Text(
                AppStrings.bankVerificationFailed,
                style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2),
              ),
              SizedBox(height: context.h(8)),
              Text(
                AppStrings.bankVerificationFailedSubtitle,
                textAlign: TextAlign.center,
                style: AppTypography.regular.copyWith(
                  fontSize: 14,
                  color: context.torkk.textSecondary,
                ),
              ),
              SizedBox(height: context.h(20)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(context.w(14)),
                decoration: BoxDecoration(
                  color: context.adaptiveTint(const Color(0xFFFEF2F2)),
                  borderRadius: BorderRadius.circular(context.r(12)),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.reason,
                      style: AppTypography.bold.copyWith(
                        color: context.torkk.textPrimary,
                        fontSize: 14,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: context.h(8)),
                    _Reason(AppStrings.incorrectAccountOrIfsc),
                    SizedBox(height: context.h(6)),
                    _Reason(AppStrings.accountInactive),
                  ],
                ),
              ),
              const Spacer(),
              UnifiedButton(
                label: AppStrings.retryVerification,
                onPressed: () => _go(_BankPage.form),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
