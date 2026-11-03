import 'package:flutter/material.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/profile/screens/tickets/issue_problem_screen.dart';
import 'package:rider_app/driver_features/profile/screens/tickets/ticket_widgets.dart';
import 'package:rider_app/service/support_api_service.dart';

class IssueCategoryScreen extends StatefulWidget {
  const IssueCategoryScreen({super.key});

  @override
  State<IssueCategoryScreen> createState() => _IssueCategoryScreenState();
}

class _IssueCategoryScreenState extends State<IssueCategoryScreen> {
  static const _icons = [
    Icons.directions_car_outlined,
    Icons.receipt_long_rounded,
    Icons.badge_outlined,
    Icons.phone_iphone_rounded,
  ];
  static const _colors = [
    (Color(0xFF7C3AED), Color(0xFFF3E8FF)),
    (Color(0xFFF59E0B), Color(0xFFFEF3C7)),
  ];

  List<SupportOption> _categories = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final categories = await SupportApiService.fetchCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Select Issue Category',
      child: ticketAsyncBody(
        context,
        loading: _loading,
        error: _error,
        onRetry: _load,
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
            for (var i = 0; i < _categories.length; i++)
              ticketChoice(
                context,
                icon: _icons[i % _icons.length],
                color: _colors[i % _colors.length].$1,
                background: _colors[i % _colors.length].$2,
                label: _categories[i].name,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          IssueProblemScreen(category: _categories[i]),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
