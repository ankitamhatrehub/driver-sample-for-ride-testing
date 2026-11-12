import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/rides/payment/static_qr_painter.dart';

const paymentRed = Color(0xFFDC2626);
const paymentGreen = Color(0xFF16A34A);

String rupee(double v) => '₹${v.round()}';
String rupee2(double v) => '₹${v.toStringAsFixed(2)}';

/// Page frame: back button, optional title, body and a bottom action.
class PaymentScaffold extends StatelessWidget {
  const PaymentScaffold({
    super.key,
    required this.onBack,
    required this.child,
    this.title = '',
    this.bottom,
  });

  final VoidCallback onBack;
  final String title;
  final Widget child;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.torkk.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.w(8),
                context.h(4),
                context.w(16),
                0,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTypography.bold.copyWith(fontSize: 16),
                    ),
                  ),
                  SizedBox(width: context.w(48)),
                ],
              ),
            ),
            Expanded(child: child),
            if (bottom != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.w(20),
                  context.h(8),
                  context.w(20),
                  context.h(12),
                ),
                child: bottom,
              ),
          ],
        ),
      ),
    );
  }
}

/// Label, big amount and an optional small line (for example the rider id).
class PaymentAmountHeader extends StatelessWidget {
  const PaymentAmountHeader({
    super.key,
    required this.label,
    required this.amount,
    this.sub,
  });

  final String label;
  final double amount;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTypography.regular.copyWith(fontSize: 15)),
        SizedBox(height: context.h(6)),
        Text(
          rupee2(amount),
          style: AppTypography.bold.copyWith(fontSize: 32, height: 1.1),
        ),
        if (sub != null) ...[
          SizedBox(height: context.h(4)),
          Text(
            sub!,
            style: AppTypography.regular.copyWith(
              fontSize: 12,
              color: context.torkk.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class PaymentQrBlock extends StatelessWidget {
  const PaymentQrBlock({
    super.key,
    required this.paymentId,
    this.size = 200,
    this.qrData,
    this.imageUrl,
    this.loading = false,
    this.error,
    this.onRetry,
  });

  final String paymentId;
  final double size;

  /// The UPI string (`upi://pay?...`) the QR encodes. Drawn as a clean QR.
  final String? qrData;

  /// Razorpay's poster image, only used if [qrData] is missing. When null (and not loading / failed) a placeholder
  /// pattern is drawn.
  final String? imageUrl;
  final bool loading;
  final String? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: context.w(size),
          height: context.w(size),
          padding: EdgeInsets.all(context.w(10)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.r(12)),
            border: Border.all(color: context.torkk.border),
          ),
          child: _content(context),
        ),
        if (qrData != null ||
            imageUrl != null ||
            (!loading && error == null)) ...[
          SizedBox(height: context.h(8)),
          Text(
            '${AppStrings.payPaymentId}:  $paymentId',
            style: AppTypography.regular.copyWith(
              fontSize: 12,
              color: context.torkk.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _content(BuildContext context) {
    if (loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(strokeWidth: 2),
            SizedBox(height: context.h(10)),
            Text(
              AppStrings.payQrLoading,
              style: AppTypography.regular.copyWith(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.payQrFailed,
              textAlign: TextAlign.center,
              style: AppTypography.bold.copyWith(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: context.h(4)),
            Text(
              error!,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.regular.copyWith(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: Text(AppStrings.retry)),
          ],
        ),
      );
    }
    final data = qrData;
    if (data != null && data.isNotEmpty) {
      return QrImageView(
        data: data,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
        backgroundColor: Colors.white,
        padding: EdgeInsets.zero,
      );
    }
    final url = imageUrl;
    if (url == null) return CustomPaint(painter: StaticQrPainter(paymentId));
    return Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorBuilder: (_, _, _) => Center(
        child: TextButton(onPressed: onRetry, child: Text(AppStrings.retry)),
      ),
    );
  }
}

class PaymentCard extends StatelessWidget {
  const PaymentCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.w(14),
        vertical: context.h(10),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Column(children: children),
    );
  }
}

class PaymentRow extends StatelessWidget {
  const PaymentRow({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final labelStyle = bold
        ? AppTypography.bold.copyWith(fontSize: 14)
        : AppTypography.regular.copyWith(
            fontSize: 14,
            color: context.torkk.textSecondary,
          );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.h(6)),
      child: Row(
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          Text(
            value,
            style: (bold ? AppTypography.bold : AppTypography.regular).copyWith(
              fontSize: 14,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentSectionTitle extends StatelessWidget {
  const PaymentSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.h(16), bottom: context.h(8)),
      child: Text(text, style: AppTypography.bold.copyWith(fontSize: 13)),
    );
  }
}

class PaymentChoice extends StatelessWidget {
  const PaymentChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.h(8)),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 20,
              color: selected ? context.brandColor : context.torkk.textDisabled,
            ),
            SizedBox(width: context.w(10)),
            Expanded(
              child: Text(
                label,
                style: AppTypography.regular.copyWith(fontSize: 13.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Green round badge: a money icon, or a tick inside a ring when [check].
class PaymentBadge extends StatelessWidget {
  const PaymentBadge({super.key, this.check = false});

  final bool check;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: context.w(84),
        height: context.w(84),
        decoration: const BoxDecoration(
          color: Color(0x1A16A34A),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: check
              ? Container(
                  width: context.w(60),
                  height: context.w(60),
                  decoration: const BoxDecoration(
                    color: paymentGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                )
              : const Icon(Icons.paid_rounded, size: 42, color: paymentGreen),
        ),
      ),
    );
  }
}
