part of 'package:rider_app/driver_features/profile/screens/sos_screen.dart';

extension _SosScreenStateSections on _SosScreenState {
  Future<void> _confirmStop() async {
    final cancel = await showAppConfirmDialog(
      context,
      accent: profileAccent(context),
      icon: const AppDialogBadge(
        icon: Icons.logout_rounded,
        color: Color(0xFFEF4444),
        background: Color(0xFFFEE2E2),
      ),
      title: 'Cancel SOS ?',
      subtitle: 'Are you sure you want to stop the emergency alert',
      cancelLabel: 'No, Keep it',
      confirmLabel: 'Yes, Cancel',
    );
    if (cancel) _stop();
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Widget _active(BuildContext context) {
    final clock =
        '${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}';
    return _shell(
      context,
      showBack: false,
      child: Column(
        children: [
          SizedBox(height: context.h(8)),
          if (_helpOnTheWay)
            _banner(
              context,
              'Help is on the way',
              'Your request have been sent. Our support team and nearby partners are on it.',
            )
          else
            _banner(context, 'Emergency Number Notified', null),
          const Spacer(),
          _sosOrb(context),
          SizedBox(height: context.h(18)),
          Text('SOS Activated', style: _title()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(36)),
            child: Text(
              'Your emergency contacts have been notified with your live location and job details',
              textAlign: TextAlign.center,
              style: _muted(),
            ),
          ),
          SizedBox(height: context.h(16)),
          Container(
            margin: EdgeInsets.symmetric(horizontal: context.w(28)),
            padding: EdgeInsets.symmetric(vertical: context.h(12)),
            decoration: BoxDecoration(
              color: context.adaptiveTint(const Color(0xFFFFF1F2)),
              borderRadius: BorderRadius.circular(context.r(14)),
            ),
            child: Column(
              children: [
                Text(
                  clock,
                  style: AppTypography.bold.copyWith(
                    fontSize: 22,
                    height: 1.1,
                    color: context.legible(Color(0xFFEF4444)),
                    letterSpacing: -0.4,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Help is on the way',
                      style: AppTypography.regular.copyWith(
                        fontSize: 12,
                        color: context.legible(Color(0xFFEF4444)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          _redButton(context, 'Stop SOS', null, _confirmStop),
          SizedBox(height: context.h(12)),
        ],
      ),
    );
  }

  Widget _contactsPage(BuildContext context) {
    return ProfilePage(
      title: 'Emergency Contacts',
      onBack: _back,
      bottom: _accentButton(context, '+  Add Emergency Contact', _addContact),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(12),
        ),
        itemCount: _contacts.length,
        separatorBuilder: (_, _) => SizedBox(height: context.h(10)),
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(12),
              vertical: context.h(12),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.r(16)),
              border: Border.all(color: context.torkk.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: context.w(18),
                  backgroundColor: context.adaptiveTint(
                    const Color(0xFFF1F5F9),
                  ),
                  child: Icon(
                    Icons.person,
                    color: AppColors.slate400,
                    size: context.w(18),
                  ),
                ),
                SizedBox(width: context.w(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: AppTypography.regular.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        contact.phone,
                        style: AppTypography.regular.copyWith(
                          fontSize: 12,
                          color: context.torkk.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => _call(contact.phone),
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: context.w(36),
                    height: context.w(36),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: context.torkk.border),
                    ),
                    child: Icon(
                      Icons.call_rounded,
                      color: profileAccent(context),
                      size: context.w(16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _reported(BuildContext context) {
    return _shell(
      context,
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: context.w(72),
            height: context.w(72),
            decoration: BoxDecoration(
              color: context.adaptiveTint(Color(0xFFDCFCE7)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: context.legible(Color(0xFF16A34A)),
              size: context.w(36),
            ),
          ),
          SizedBox(height: context.h(16)),
          Text('Issue Reported', style: _title()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(36)),
            child: Text(
              'Your emergency alert has been stopped. Your contacts have been notified',
              textAlign: TextAlign.center,
              style: _muted(),
            ),
          ),
          const Spacer(),
          _accentButton(
            context,
            'Back to Home',
            () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _shell(
    BuildContext context, {
    required Widget child,
    bool showBack = true,
  }) {
    return Scaffold(
      backgroundColor: context.torkk.background,
      body: SafeArea(
        child: Column(
          children: [
            if (showBack)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _back,
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: context.torkk.textPrimary,
                  ),
                ),
              ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget _sosOrb(BuildContext context) {
    return Container(
      width: context.w(168),
      height: context.w(168),
      decoration: BoxDecoration(
        color: context.adaptiveTint(Color(0xFFFFF1F2)),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: context.w(124),
        height: context.w(124),
        decoration: const BoxDecoration(
          color: Color(0xFFFECACA),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Container(
          width: context.w(84),
          height: context.w(84),
          decoration: const BoxDecoration(
            color: Color(0xFFEF4444),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            'SOS',
            style: AppTypography.bold.copyWith(
              fontSize: 18,
              height: 1,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _banner(BuildContext context, String title, String? body) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: context.w(16)),
      padding: EdgeInsets.symmetric(
        horizontal: context.w(14),
        vertical: context.h(10),
      ),
      decoration: BoxDecoration(
        color: context.torkk.surface,
        borderRadius: BorderRadius.circular(context.r(14)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.regular.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (body != null)
                  Text(
                    body,
                    style: AppTypography.regular.copyWith(
                      fontSize: 12,
                      color: context.torkk.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            width: context.w(32),
            height: context.w(32),
            decoration: BoxDecoration(
              color: context.adaptiveTint(Color(0xFFFEE2E2)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              color: context.legible(Color(0xFFEF4444)),
              size: context.w(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shortcut(
    BuildContext context,
    IconData icon,
    Color background,
    Color color,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: context.w(110),
        child: Column(
          children: [
            Container(
              width: context.w(56),
              height: context.w(56),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(context.r(16)),
              ),
              child: Icon(icon, color: color, size: context.w(24)),
            ),
            SizedBox(height: context.h(6)),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.regular.copyWith(fontSize: 12, height: 1.25),
            ),
          ],
        ),
      ),
    );
  }

  Widget _redButton(
    BuildContext context,
    String label,
    IconData? icon,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
      child: SizedBox(
        width: double.infinity,
        height: context.h(48),
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            foregroundColor: onColorFor(const Color(0xFFEF4444)),
            backgroundColor: const Color(0xFFEF4444),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.r(14)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white, size: context.w(18)),
                SizedBox(width: context.w(6)),
              ],
              Text(
                label,
                style: AppTypography.bold.copyWith(
                  fontSize: 15,
                  height: 1,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _accentButton(BuildContext context, String label, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.w(20),
        context.h(8),
        context.w(20),
        context.h(16),
      ),
      child: SizedBox(
        width: double.infinity,
        height: context.h(48),
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: profileAccent(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.r(14)),
            ),
          ),
          child: Text(
            label,
            style: AppTypography.bold.copyWith(
              fontSize: 15,
              height: 1,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
