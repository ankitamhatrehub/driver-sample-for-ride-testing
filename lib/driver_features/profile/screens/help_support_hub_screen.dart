import 'package:flutter/material.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/chat/screens/driver_live_chat_screen.dart';
import 'package:rider_app/driver_features/profile/screens/tickets_screen.dart';
import 'package:rider_app/driver_features/profile/screens/emergency_contacts_screen.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';

/// Settings-style landing page for Help & Support.
class HelpSupportHubScreen extends StatelessWidget {
  const HelpSupportHubScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: AppStrings.helpSupport,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(20),
        ),
        children: [
          ProfileMenuCard(
            items: [
              ProfileMenuItem(
                icon: Icons.smart_toy_outlined,
                iconColor: const Color(0xFF6366F1),
                label: 'Chat with AI Assistant',
                onTap: () => _open(context, const DriverLiveChatScreen()),
              ),
              ProfileMenuItem(
                icon: Icons.report_problem_outlined,
                iconColor: const Color(0xFFF59E0B),
                label: 'Issues & Tickets',
                onTap: () => _open(context, const TicketsScreen()),
              ),
              ProfileMenuItem(
                icon: Icons.contact_phone_outlined,
                iconColor: const Color(0xFFEF4444),
                label: 'Emergency Contacts',
                onTap: () => _open(context, const EmergencyContactsScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
