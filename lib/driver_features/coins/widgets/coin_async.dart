import 'package:flutter/material.dart';

import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/driver_features/coins/widgets/coins_text.dart';

/// Centered spinner shown while a coins API call is running.
class CoinLoading extends StatelessWidget {
  const CoinLoading({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: context.h(48)),
    child: const Center(child: CircularProgressIndicator()),
  );
}

/// Error text with a retry button.
class CoinError extends StatelessWidget {
  const CoinError({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(
      horizontal: context.w(24),
      vertical: context.h(32),
    ),
    child: Column(
      children: [
        Text(message, textAlign: TextAlign.center, style: coinsMuted(context)),
        SizedBox(height: context.h(14)),
        UnifiedButton(label: 'Try Again', onPressed: onRetry),
      ],
    ),
  );
}

/// "1,240" style thousands grouping.
String coinNumber(int value) => value.toString().replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+(?!\d))'),
  (_) => ',',
);

/// "3 Nov, 4:00 pm".
String coinDate(DateTime? date) {
  if (date == null) return '';
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
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final suffix = date.hour >= 12 ? 'pm' : 'am';
  return '${date.day} ${months[date.month - 1]}, $hour:$minute $suffix';
}
