
import 'package:flutter/material.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/profile/screens/tickets/add_photos_screen.dart';
import 'package:rider_app/driver_features/profile/screens/tickets/ticket_widgets.dart';

class IssueProblemScreen extends StatelessWidget {
  const IssueProblemScreen({super.key, required this.category});

  final String category;

  List<(IconData, String)> get _problems {
    if (category == 'Earning & Payments') {
      return [
        (Icons.receipt_long_rounded, 'Payment not received'),
        (Icons.sell_outlined, 'Wrong fare'),
      ];
    }
    if (category == 'Delivery Issue') {
      return [
        (Icons.inventory_2_outlined, 'Parcel Delayed'),
        (Icons.phone_disabled_outlined, 'Sender not picking up the call'),
      ];
    }
    return [
      (Icons.bug_report_outlined, 'App not opening'),
      (Icons.location_off_outlined, 'Location not updating'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Select Specific Problem',
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), context.h(4), context.w(20), context.h(20)),
        children: [
          Text('Choose the issue you are facing', style: AppTypography.regular.copyWith(fontSize: 13, color: context.torkk.textSecondary)),
          SizedBox(height: context.h(12)),
          for (final item in _problems)
            ticketChoice(
              context,
              icon: item.$1,
              color: category == 'Earning & Payments' ? const Color(0xFFF59E0B) : const Color(0xFF7C3AED),
              background: category == 'Earning & Payments' ? const Color(0xFFFEF3C7) : const Color(0xFFF3E8FF),
              label: item.$2,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AddPhotosScreen(category: category, problem: item.$2),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
