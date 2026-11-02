import 'package:flutter/material.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/service/driver_api_service.dart';

/// Lets the driver pick the time slot they prefer to go online in.
/// Pops with the selected slot title on Save.
class PlanDrivingHoursScreen extends StatefulWidget {
  const PlanDrivingHoursScreen({super.key});

  @override
  State<PlanDrivingHoursScreen> createState() => _PlanDrivingHoursScreenState();
}

class _Slot {
  const _Slot(
    this.title,
    this.time,
    this.start,
    this.end,
    this.icon,
    this.color,
    this.background,
  );
  final String title;
  final String time;

  /// 24h `HH:mm:ss`, sent to the schedule API.
  final String start;
  final String end;
  final IconData icon;
  final Color color;
  final Color background;
}

class _PlanDrivingHoursScreenState extends State<PlanDrivingHoursScreen> {
  static const _purple = Color(0xFF5B21B6);

  static const _slots = [
    _Slot(
      'Morning Time',
      '06:00 AM - 12:00 PM',
      '06:00:00',
      '12:00:00',
      Icons.wb_twilight_rounded,
      Color(0xFFF59E0B),
      Color(0xFFFDEBD0),
    ),
    _Slot(
      'Day time',
      '12:00 PM - 04:00 PM',
      '12:00:00',
      '16:00:00',
      Icons.wb_sunny_outlined,
      Color(0xFFF97316),
      Color(0xFFFFF3E6),
    ),
    _Slot(
      'Evening Time',
      '04:00 PM - 08:00 PM',
      '16:00:00',
      '20:00:00',
      Icons.waves_rounded,
      Color(0xFFB91C1C),
      Color(0xFFFFF1E6),
    ),
    _Slot(
      'Night Time',
      '08:00 PM - 12:00 AM',
      '20:00:00',
      '23:59:59',
      Icons.nightlight_round,
      Color(0xFF312E81),
      Color(0xFFEEF0FF),
    ),
    _Slot(
      'Flexible',
      'Available Anytime',
      '00:00:00',
      '23:59:59',
      Icons.calendar_month_rounded,
      Color(0xFF1D4ED8),
      Color(0xFFEEF0FF),
    ),
  ];

  int _selected = 0;
  bool _saving = false;

  Future<void> _showSavedDialog(_Slot slot) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: dialogContext.torkk.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dialogContext.r(20)),
          ),
          title: Text(
            'Schedule saved',
            style: AppTypography.bold.copyWith(fontSize: 18),
          ),
          content: Text(
            '${slot.title} (${slot.time}) has been saved as your driving hours.',
            style: AppTypography.regular.copyWith(
              fontSize: 14,
              color: dialogContext.torkk.textSecondary,
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: UnifiedButton(
                label: 'OK',
                backgroundColor: const Color(0xFF1E3FBF),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    final slot = _slots[_selected];
    setState(() => _saving = true);
    try {
      final response = await DriverApiService.saveSchedule(
        title: slot.title,
        startTime: slot.start,
        endTime: slot.end,
      );
      debugPrint(
        'SCHEDULE_SCREEN_01 | saved "${slot.title}" ${slot.start}-${slot.end} response=$response',
      );
      if (!mounted) return;
      await _showSavedDialog(slot);
      if (!mounted) return;
      Navigator.of(context).pop(slot.title);
    } catch (e) {
      debugPrint('SCHEDULE_SCREEN_02 | save failed: $e');
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Plan your Driving Hours',
      subtitle:
          'Select your time slots when you prefer to go online and receive more ride requests.',
      bottom: Padding(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(16),
        ),
        child: UnifiedButton(
          label: _saving ? 'Saving...' : 'Save Schedule',
          backgroundColor: const Color(0xFF1E3FBF),
          onPressed: _saving ? null : _save,
        ),
      ),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(20),
        ),
        itemCount: _slots.length,
        separatorBuilder: (_, _) => SizedBox(height: context.h(12)),
        itemBuilder: (_, i) => _slotCard(context, i),
      ),
    );
  }

  Widget _slotCard(BuildContext context, int index) {
    final slot = _slots[index];
    final selected = index == _selected;
    return GestureDetector(
      onTap: () => setState(() => _selected = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(16),
          vertical: context.h(16),
        ),
        decoration: BoxDecoration(
          color: context.torkk.surface,
          borderRadius: BorderRadius.circular(context.r(16)),
          border: Border.all(
            color: selected ? _purple : context.torkk.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: context.w(48),
              height: context.w(48),
              decoration: BoxDecoration(
                color: context.adaptiveTint(slot.background),
                borderRadius: BorderRadius.circular(context.r(12)),
              ),
              child: Icon(
                slot.icon,
                color: context.legible(slot.color),
                size: context.w(24),
              ),
            ),
            SizedBox(width: context.w(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.title,
                    style: AppTypography.bold.copyWith(
                      fontSize: 15,
                      height: 1.2,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: context.h(4)),
                  Text(
                    slot.time,
                    style: AppTypography.regular.copyWith(
                      fontSize: 12,
                      color: context.torkk.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _radio(context, selected),
          ],
        ),
      ),
    );
  }

  Widget _radio(BuildContext context, bool selected) {
    final size = context.w(28);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? _purple : context.torkk.textSecondary,
          width: selected ? 2 : 1.4,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: size * 0.5,
              height: size * 0.5,
              decoration: const BoxDecoration(
                color: _purple,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}
