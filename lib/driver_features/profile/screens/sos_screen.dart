import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:rider_app/driver_features/profile/screens/tickets_screen.dart';
import 'package:rider_app/service/sos_api_service.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/widgets/app_confirm_dialog.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
part 'sos_screen_sections.dart';

enum _SosPage { confirm, active, contacts, reported }

class _Contact {
  _Contact(this.name, this.phone);
  final String name;
  final String phone;
}

class SosScreen extends StatefulWidget {
  /// The ride to raise the alert for. Falls back to the ride saved by the ride
  /// flow when the screen is opened from the profile.
  const SosScreen({super.key, this.rideId});

  final int? rideId;

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  _SosPage _page = _SosPage.confirm;
  int _seconds = 0;
  bool _helpOnTheWay = false;
  Timer? _timer;
  final _contacts = <_Contact>[
    _Contact('Sister', '+91 23456785'),
    _Contact('Sister', '+91 23456785'),
    _Contact('Sister', '+91 23456785'),
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showError(Object error) {
    if (!mounted) return;
    final text = '$error'.replaceFirst('Exception: ', '');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _start() {
    _timer?.cancel();
    setState(() {
      _page = _SosPage.active;
      _seconds = 0;
      _helpOnTheWay = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _seconds++;
        if (_seconds >= 4) _helpOnTheWay = true;
      });
    });
    _sendStart();
  }

  /// Runs in the background so the alert screen opens at once.
  Future<void> _sendStart() async {
    try {
      await SosApiService.start(rideId: widget.rideId);
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _stop() async {
    _timer?.cancel();
    setState(() => _page = _SosPage.reported);
    try {
      await SosApiService.stop(rideId: widget.rideId);
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _addContact() async {
    final name = TextEditingController();
    final phone = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Emergency Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (saved == true &&
        name.text.trim().isNotEmpty &&
        phone.text.trim().isNotEmpty) {
      setState(
        () => _contacts.add(_Contact(name.text.trim(), phone.text.trim())),
      );
    }
    name.dispose();
    phone.dispose();
  }

  void _back() {
    if (_page == _SosPage.contacts) {
      setState(() => _page = _SosPage.confirm);
      return;
    }
    _timer?.cancel();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return switch (_page) {
      _SosPage.confirm => _confirm(context),
      _SosPage.active => _active(context),
      _SosPage.contacts => _contactsPage(context),
      _SosPage.reported => _reported(context),
    };
  }

  Widget _confirm(BuildContext context) {
    final accent = profileAccent(context);
    return _shell(
      context,
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: context.w(88),
            height: context.w(88),
            decoration: BoxDecoration(
              color: context.adaptiveTint(Color(0xFFFEE2E2)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              color: context.legible(Color(0xFFEF4444)),
              size: context.w(36),
            ),
          ),
          SizedBox(height: context.h(16)),
          Text('Activate SOS ?', style: _title()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(40)),
            child: Text(
              'This will notify emergency contacts with your live location.',
              textAlign: TextAlign.center,
              style: _muted(),
            ),
          ),
          SizedBox(height: context.h(22)),
          _redButton(
            context,
            'Confirm SOS',
            Icons.warning_amber_rounded,
            _start,
          ),
          SizedBox(height: context.h(10)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(20)),
            child: SizedBox(
              width: double.infinity,
              height: context.h(48),
              child: OutlinedButton(
                onPressed: _back,
                style: OutlinedButton.styleFrom(
                  foregroundColor: accent,
                  side: BorderSide(color: accent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.r(14)),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: AppTypography.bold.copyWith(
                    fontSize: 15,
                    height: 1,
                    color: accent,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: context.h(18)),
          Row(
            children: [
              Expanded(child: Divider(color: context.torkk.border)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(10)),
                child: Text(
                  'OR',
                  style: AppTypography.regular.copyWith(
                    fontSize: 12,
                    color: AppColors.slate400,
                  ),
                ),
              ),
              Expanded(child: Divider(color: context.torkk.border)),
            ],
          ),
          SizedBox(height: context.h(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _shortcut(
                context,
                Icons.call_rounded,
                const Color(0xFFFEE2E2),
                const Color(0xFFEF4444),
                'Call Emergency\nContacts',
                () {
                  setState(() => _page = _SosPage.contacts);
                },
              ),
              SizedBox(width: context.w(28)),
              _shortcut(
                context,
                Icons.warning_amber_rounded,
                const Color(0xFFFEF3C7),
                const Color(0xFFF59E0B),
                'Report Issue',
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const IssueCategoryScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  TextStyle _title() => AppTypography.bold.copyWith(
    fontSize: 20,
    height: 1.2,
    letterSpacing: -0.3,
  );

  TextStyle _muted() => AppTypography.regular.copyWith(
    fontSize: 13,
    height: 1.4,
    color: context.torkk.textSecondary,
  );
}
