import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/driver_features/profile/screens/tickets/ticket_widgets.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/driver_features/settings/screens/driver_emergency_contact_screen.dart';
import 'package:rider_app/service/emergency_contacts_api_service.dart';

/// Lists the driver's saved emergency contacts with a one-tap call button.
class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<Map<String, String>> _contacts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _showError(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', '')),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _load({bool showSpinner = true}) async {
    if (showSpinner) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final contacts = await EmergencyContactsApiService.fetch();
      if (!mounted) return;
      setState(() {
        _contacts = contacts;
        _error = null;
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

  Future<void> _add() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const DriverEmergencyContactScreen()),
    );
    _load(showSpinner: false);
  }

  Future<void> _remove(int index) async {
    final removed = _contacts[index];
    setState(() => _contacts.removeAt(index));
    try {
      await EmergencyContactsApiService.save(_contacts);
    } catch (e) {
      _showError(e);
      if (mounted) setState(() => _contacts.insert(index, removed));
    }
  }

  static String _display(String phone) =>
      phone.startsWith('+') ? phone : '+91 $phone';

  Future<void> _call(String phone) => launchUrl(
    Uri(scheme: 'tel', path: phone.startsWith('+') ? phone : '+91$phone'),
  );

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Emergency Contacts',
      bottom: Padding(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(16),
        ),
        child: UnifiedButton(
          label: 'Add Emergency Contact',
          icon: Icons.add,
          onPressed: _add,
        ),
      ),
      child: ticketAsyncBody(
        context,
        loading: _loading,
        error: _error,
        onRetry: _load,
        child: _contacts.isEmpty
            ? Center(
                child: Text(
                  'No emergency contacts added yet',
                  style: AppTypography.regular.copyWith(
                    fontSize: 14,
                    color: context.torkk.textSecondary,
                  ),
                ),
              )
            : ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  context.w(20),
                  context.h(12),
                  context.w(20),
                  context.h(20),
                ),
                itemCount: _contacts.length,
                separatorBuilder: (_, _) => SizedBox(height: context.h(12)),
                itemBuilder: (context, i) {
                  final c = _contacts[i];
                  return Dismissible(
                    key: ValueKey('${c['phone']}-$i'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _remove(i),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: context.w(20)),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(context.r(16)),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                    ),
                    child: _ContactCard(
                      name: c['name'] ?? '',
                      subtitle: _display(c['phone'] ?? ''),
                      onCall: () => _call(c['phone'] ?? ''),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.name,
    required this.subtitle,
    required this.onCall,
  });

  final String name;
  final String subtitle;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(14)),
      decoration: BoxDecoration(
        color: context.torkk.background,
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(44),
            height: context.w(44),
            decoration: BoxDecoration(
              color: context.torkk.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: context.w(22),
              color: context.torkk.textSecondary,
            ),
          ),
          SizedBox(width: context.w(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.bold.copyWith(fontSize: 14)),
                SizedBox(height: context.h(2)),
                Text(
                  subtitle,
                  style: AppTypography.regular.copyWith(
                    fontSize: 12,
                    color: context.torkk.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onCall,
            customBorder: const CircleBorder(),
            child: Container(
              width: context.w(44),
              height: context.w(44),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: context.torkk.border),
              ),
              child: Icon(
                Icons.call,
                size: context.w(20),
                color: profileAccent(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
