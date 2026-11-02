import 'package:flutter/material.dart';

import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/widgets/animated_progress_steps.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_page.dart';
import 'package:rider_app/driver_features/subscription/widgets/subscription_text.dart';

class PaymentProcessingScreen extends StatelessWidget {
  const PaymentProcessingScreen({super.key, required this.onCompleted});

  final VoidCallback onCompleted;

  @override
  Widget build(BuildContext context) {
    return SubscriptionPage(
      showBack: false,
      child: Column(
        children: [
          SizedBox(height: context.h(48)),
          SizedBox(
            width: context.w(96),
            height: context.w(96),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: context.w(72),
                  height: context.w(80),
                  decoration: BoxDecoration(
                    color: context.adaptiveTint(const Color(0xFFF3E8FF)),
                    borderRadius: BorderRadius.circular(context.r(16)),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: const Color(0xFFDDD6FE),
                    size: context.w(40),
                  ),
                ),
                Positioned(
                  right: context.w(2),
                  bottom: context.h(2),
                  child: SizedBox(
                    width: context.w(28),
                    height: context.w(28),
                    child: const CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Color(0xFFC4B5FD),
                      backgroundColor: Color(0xFFEDE9FE),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.h(18)),
          Text(
            'Processing Payment...',
            textAlign: TextAlign.center,
            style: subscriptionTitle(),
          ),
          SizedBox(height: context.h(8)),
          Text(
            'Please do not close the app',
            textAlign: TextAlign.center,
            style: subscriptionMuted(
              context,
            ).copyWith(color: context.legible(AppColors.slate600)),
          ),
          SizedBox(height: context.h(40)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(28)),
            child: AnimatedProgressSteps(
              onCompleted: onCompleted,
              steps: const [
                ProgressStep(
                  title: 'Verifying payment details',
                  subtitle: '12 Jan 2026, 10:24 AM',
                ),
                ProgressStep(
                  title: 'Processing payment',
                  subtitle: "We'll notify you once it's approved",
                ),
                ProgressStep(title: 'Updating your plan'),
              ],
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(
              context.w(20),
              0,
              context.w(20),
              context.h(16),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: context.w(12),
              vertical: context.h(12),
            ),
            decoration: BoxDecoration(
              color: context.adaptiveTint(const Color(0xFFEFF6FF)),
              borderRadius: BorderRadius.circular(context.r(14)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info,
                  color: context.legible(Color(0xFF3B82F6)),
                  size: context.w(18),
                ),
                SizedBox(width: context.w(8)),
                Expanded(
                  child: Text(
                    "This may take a few moments. Please don't close the app",
                    style: subscriptionMuted(
                      context,
                    ).copyWith(color: context.torkk.textBody),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
