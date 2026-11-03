import 'package:flutter/material.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/profile/screens/tickets/add_photos_screen.dart';
import 'package:rider_app/driver_features/profile/screens/tickets/ticket_widgets.dart';
import 'package:rider_app/service/support_api_service.dart';

class IssueProblemScreen extends StatefulWidget {
  const IssueProblemScreen({super.key, required this.category});

  final SupportOption category;

  @override
  State<IssueProblemScreen> createState() => _IssueProblemScreenState();
}

class _IssueProblemScreenState extends State<IssueProblemScreen> {
  List<SupportOption> _problems = [];
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
      final problems = await SupportApiService.fetchProblems(
        widget.category.id,
      );
      if (!mounted) return;
      setState(() {
        _problems = problems;
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
      title: 'Select Specific Problem',
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
              'Choose the issue you are facing',
              style: AppTypography.regular.copyWith(
                fontSize: 13,
                color: context.torkk.textSecondary,
              ),
            ),
            SizedBox(height: context.h(12)),
            for (final item in _problems)
              ticketChoice(
                context,
                icon: Icons.report_problem_outlined,
                color: const Color(0xFF7C3AED),
                background: const Color(0xFFF3E8FF),
                label: item.name,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AddPhotosScreen(
                        category: widget.category,
                        problem: item,
                      ),
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
