import 'package:flutter/material.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/profile/screens/tickets/issue_problem_screen.dart';
import 'package:rider_app/driver_features/profile/screens/tickets/ticket_widgets.dart';

class IssueCategoryScreen extends StatelessWidget {
  const IssueCategoryScreen({super.key});

  static const _categories = [
    (
      Icons.receipt_long_rounded,
      Color(0xFFF59E0B),
      Color(0xFFFEF3C7),
      'Earning & Payments',
    ),
    (
      Icons.local_shipping_outlined,
      Color(0xFF7C3AED),
      Color(0xFFF3E8FF),
      'Delivery Issue',
    ),
    (
      Icons.phone_iphone_rounded,
      Color(0xFF7C3AED),
      Color(0xFFF3E8FF),
      'App Issues',
    ),
    (
      Icons.badge_outlined,
      Color(0xFF7C3AED),
      Color(0xFFF3E8FF),
      'Account & Documents',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Select Issue Category',
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(4),
          context.w(20),
          context.h(20),
        ),
        children: [
          Text(
            'Choose the category that best match your issue',
            style: AppTypography.regular.copyWith(
              fontSize: 13,
              color: context.torkk.textSecondary,
            ),
          ),
          SizedBox(height: context.h(12)),
          for (final item in _categories)
            ticketChoice(
              context,
              icon: item.$1,
              color: item.$2,
              background: item.$3,
              label: item.$4,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => IssueProblemScreen(category: item.$4),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
