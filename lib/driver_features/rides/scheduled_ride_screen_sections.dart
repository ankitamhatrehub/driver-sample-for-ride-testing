part of 'package:rider_app/driver_features/rides/scheduled_ride_screen.dart';

extension _ScheduledRideScreenStateSections on _ScheduledRideScreenState {
  Widget _offer(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _Map()),
          Align(
            alignment: Alignment.bottomCenter,
            child: _requestSheet(context, accent),
          ),
        ],
      ),
    );
  }

  Widget _requestSheet(BuildContext context, Color accent) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(28),
          context.w(20),
          0,
        ),
        decoration: BoxDecoration(
          color: context.torkk.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(context.r(32)),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(0, -3),
              blurRadius: 11.1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scheduled ride request',
                        style: AppTypography.bold.copyWith(
                          fontSize: 16,
                          height: 1.2,
                          color: const Color(0xFFF97316),
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        'Tomorrow at 6:30 am',
                        style: AppTypography.regular.copyWith(
                          fontSize: 12,
                          color: AppColors.slate400,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹240',
                  style: AppTypography.bold.copyWith(
                    fontSize: 22,
                    height: 1,
                    color: accent,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.h(12)),
            Row(
              children: [
                Icon(
                  Icons.local_taxi_outlined,
                  color: context.torkk.textSecondary,
                  size: context.w(18),
                ),
                SizedBox(width: context.w(8)),
                Text(
                  'CAB',
                  style: AppTypography.bold.copyWith(
                    fontSize: 14,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.h(12)),
            _personRow(context, 'Rahul', '3 passengers', showActions: true),
            SizedBox(height: context.h(12)),
            _stops(context, 'Sector 18, Noida', 'DLF Mall of India'),
            SizedBox(height: context.h(12)),
            _stats(context),
            SizedBox(height: context.h(14)),
            Row(
              children: [
                Expanded(
                  child: _decline(context, () => Navigator.of(context).pop()),
                ),
                SizedBox(width: context.w(12)),
                Expanded(
                  child: _accept(
                    context,
                    accent,
                    'Accept',
                    () => _go(_Step.ready),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.h(50)),
          ],
        ),
      ),
    );
  }

  Widget _ready(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: context.torkk.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => _go(_Step.offer),
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                children: [
                  SizedBox(
                    height: context.h(180),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ColorFiltered(
                          colorFilter: const ColorFilter.matrix(<double>[
                            1,
                            0,
                            0,
                            0,
                            0,
                            0,
                            1,
                            0,
                            0,
                            0,
                            0,
                            0,
                            1,
                            0,
                            0,
                            1,
                            1,
                            1,
                            0,
                            0,
                          ]),
                          child: Image.asset(
                            AppAssets.celebration,
                            width: context.w(220),
                            fit: BoxFit.contain,
                          ),
                        ),
                        Container(
                          width: context.w(72),
                          height: context.w(72),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.directions_car_filled,
                            color: accent,
                            size: context.w(36),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Be Ready for Pickup',
                    textAlign: TextAlign.center,
                    style: AppTypography.bold.copyWith(
                      fontSize: 20,
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: context.h(8)),
                  Text(
                    'This is a scheduled ride. Please start navigating a few minutes before the pickup timings.',
                    textAlign: TextAlign.center,
                    style: AppTypography.regular.copyWith(
                      fontSize: 13,
                      height: 1.4,
                      color: context.torkk.textSecondary,
                    ),
                  ),
                  SizedBox(height: context.h(20)),
                  Container(
                    padding: EdgeInsets.all(context.w(14)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(context.r(14)),
                      border: Border.all(color: context.torkk.border),
                    ),
                    child: Column(
                      children: [
                        _infoLine(
                          context,
                          Icons.access_time_filled,
                          const Color(0xFFF97316),
                          const Color(0xFFFFF7ED),
                          'Pickup Time',
                          'Tomorrow, 6:30 am',
                        ),
                        SizedBox(height: context.h(12)),
                        _infoLine(
                          context,
                          Icons.location_on,
                          accent,
                          accent.withValues(alpha: 0.1),
                          'Pickup Location',
                          'Noida',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.w(20),
                0,
                context.w(20),
                context.h(16),
              ),
              child: SizedBox(
                width: double.infinity,
                height: context.h(48),
                child: FilledButton(
                  onPressed: () => _go(_Step.trip),
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.r(14)),
                    ),
                  ),
                  child: Text(
                    'Back to Ride',
                    style: AppTypography.bold.copyWith(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onPrimary,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _trip(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _Map()),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  context.w(16),
                  context.h(8),
                  context.w(16),
                  0,
                ),
                child: _locationBar(context, accent),
              ),
            ),
          ),
          if (_showScheduledCard)
            Positioned(
              top: context.h(210),
              left: context.w(16),
              right: context.w(16),
              child: _scheduledCard(context, accent),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SheetWithSos(sheet: Padding(
              padding: EdgeInsets.zero,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  context.w(20),
                  context.h(28),
                  context.w(20),
                  context.h(80),
                ),
                decoration: BoxDecoration(
                  color: context.torkk.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(context.r(32)),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x40000000),
                      offset: Offset(0, -11),
                      blurRadius: 16.8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF16A34A),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: context.w(8)),
                        Text(
                          'Active Ride',
                          style: AppTypography.bold.copyWith(
                            fontSize: 16,
                            height: 1.2,
                            color: const Color(0xFF16A34A),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.h(12)),
                    _personRow(
                      context,
                      'Rahul',
                      '4 passengers',
                      showActions: true,
                    ),
                    SizedBox(height: context.h(12)),
                    _stops(context, 'Sector 18, Noida', 'DLF Mall of India'),
                    SizedBox(height: context.h(14)),
                    Row(
                      children: [
                        Expanded(
                          child: _decline(
                            context,
                            () => Navigator.of(context).pop(),
                            label: 'Cancel',
                          ),
                        ),
                        SizedBox(width: context.w(12)),
                        Expanded(
                          child: _accept(
                            context,
                            accent,
                            'Navigate',
                            () => _go(_Step.ready),
                            icon: Icons.navigation_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),
          if (_showHour) ...[
            const Positioned.fill(child: ColoredBox(color: Color(0x66000000))),
            Center(child: _hourDialog(context, accent)),
          ],
        ],
      ),
    );
  }

  Widget _hourDialog(BuildContext context, Color accent) {
    return AppConfirmCard(
      accent: accent,
      icon: AppDialogBadge(
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFFEA580C),
        background: const Color(0xFFFFF7ED),
        badge: Container(
          width: context.w(22),
          height: context.w(22),
          decoration: const BoxDecoration(
            color: Color(0xFFF59E0B),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications,
            color: Colors.white,
            size: context.w(12),
          ),
        ),
      ),
      title: 'Scheduled Ride in 1 Hour',
      subtitle: 'You have a scheduled ride with Rahul at 8:30 am in 1 hour',
      cancelLabel: 'Notify Later',
      confirmLabel: 'View Details',
      onCancel: _hideHour,
      onConfirm: () => _go(_Step.details),
    );
  }

  Widget _details(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: context.torkk.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.w(8),
                context.h(4),
                context.w(16),
                0,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _go(_Step.trip),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  ),
                  Text(
                    'Ride Details',
                    style: AppTypography.bold.copyWith(
                      fontSize: 20,
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  context.w(20),
                  context.h(8),
                  context.w(20),
                  context.h(20),
                ),
                children: [
                  Container(
                    padding: EdgeInsets.all(context.w(14)),
                    decoration: BoxDecoration(
                      color: context.torkk.surfaceMuted,
                      borderRadius: BorderRadius.circular(context.r(16)),
                      border: Border.all(color: context.torkk.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.directions_car_filled,
                              color: accent,
                              size: context.w(16),
                            ),
                            SizedBox(width: context.w(6)),
                            Text(
                              '#ORD98232',
                              style: AppTypography.bold.copyWith(
                                fontSize: 13,
                                color: accent,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.w(8),
                                vertical: context.h(4),
                              ),
                              decoration: BoxDecoration(
                                color: context.adaptiveTint(
                                  const Color(0xFFFFF7ED),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Scheduled in 1 hour',
                                style: AppTypography.bold.copyWith(
                                  fontSize: 11,
                                  color: context.legible(Color(0xFFF97316)),
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.h(10)),
                        Text(
                          'Ride  •  4 Seater',
                          style: AppTypography.regular.copyWith(
                            fontSize: 13,
                            color: context.torkk.textSecondary,
                          ),
                        ),
                        SizedBox(height: context.h(6)),
                        Text(
                          'Sector 62, Noida   →   DLF Mall of India',
                          style: AppTypography.bold.copyWith(
                            fontSize: 14,
                            height: 1.3,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: context.h(4)),
                        Text(
                          '4.2 km,  18 mins',
                          style: AppTypography.regular.copyWith(
                            fontSize: 12,
                            color: AppColors.slate400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.h(14)),
                  _personRow(
                    context,
                    'Rahul',
                    '4 passengers',
                    showActions: true,
                    likes: 2,
                    dislikes: 1,
                  ),
                  SizedBox(height: context.h(12)),
                  Container(
                    padding: EdgeInsets.all(context.w(12)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(context.r(14)),
                      border: Border.all(color: context.torkk.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF59E0B),
                        ),
                        SizedBox(width: context.w(8)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rate Receiver',
                              style: AppTypography.bold.copyWith(
                                fontSize: 14,
                                height: 1.2,
                              ),
                            ),
                            Text(
                              'Help us maintain a safe and reliable service',
                              style: AppTypography.regular.copyWith(
                                fontSize: 11,
                                color: AppColors.slate400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.w(20),
                0,
                context.w(20),
                context.h(16),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(14),
                  vertical: context.h(12),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.r(14)),
                  gradient: LinearGradient(
                    colors: [accent, const Color(0xFF6366F1)],
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.card_giftcard_rounded,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You earned 200 coins',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Get your reward unlocked!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationBar(BuildContext context, Color accent) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(10),
              vertical: context.h(8),
            ),
            decoration: BoxDecoration(
              color: context.torkk.surface,
              borderRadius: BorderRadius.circular(context.r(14)),
              border: Border.all(color: context.torkk.border),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: accent, size: context.w(18)),
                SizedBox(width: context.w(8)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Location',
                      style: AppTypography.regular.copyWith(
                        fontSize: 11,
                        color: AppColors.slate400,
                        height: 1,
                      ),
                    ),
                    Text(
                      'Noida, UP',
                      style: AppTypography.bold.copyWith(
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: context.w(8)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(12),
            vertical: context.h(10),
          ),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(context.r(14)),
          ),
          child: Row(
            children: [
              Text(
                'Update',
                style: AppTypography.bold.copyWith(
                  fontSize: 13,
                  color: accent,
                  height: 1,
                ),
              ),
              SizedBox(width: context.w(4)),
              Icon(Icons.refresh_rounded, color: accent, size: context.w(16)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _personRow(
    BuildContext context,
    String name,
    String passengers, {
    required bool showActions,
    int likes = 1,
    int dislikes = 2,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: context.w(16),
          backgroundColor: context.adaptiveTint(const Color(0xFFF1F5F9)),
          child: Icon(
            Icons.person,
            size: context.w(16),
            color: AppColors.slate400,
          ),
        ),
        SizedBox(width: context.w(8)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTypography.bold.copyWith(
                  fontSize: 14,
                  height: 1.2,
                  letterSpacing: -0.2,
                ),
              ),
              Row(
                children: [
                  Text(
                    passengers,
                    style: AppTypography.regular.copyWith(
                      fontSize: 11,
                      color: AppColors.slate400,
                    ),
                  ),
                  SizedBox(width: context.w(6)),
                  _thumb(
                    const Color(0xFF2563EB),
                    Icons.thumb_up_alt_rounded,
                    '$likes',
                  ),
                  SizedBox(width: context.w(4)),
                  _thumb(
                    const Color(0xFFEC4899),
                    Icons.thumb_down_alt_rounded,
                    '$dislikes',
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showActions) ...[
          _roundIcon(Icons.chat_bubble_outline_rounded),
          SizedBox(width: context.w(8)),
          _roundIcon(Icons.call_outlined),
        ],
      ],
    );
  }

  Widget _thumb(Color color, IconData icon, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 10),
          const SizedBox(width: 2),
          Text(
            count,
            style: AppTypography.bold.copyWith(
              fontSize: 9,
              color: Colors.white,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIcon(IconData icon) {
    return Container(
      width: context.w(32),
      height: context.w(32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.torkk.border),
      ),
      child: Icon(
        icon,
        size: context.w(16),
        color: context.legible(Color(0xFF2563EB)),
      ),
    );
  }

  Widget _stops(BuildContext context, String pickup, String drop) {
    return Column(
      children: [
        _stop(const Color(0xFF22C55E), 'Pickup', pickup),
        SizedBox(height: context.h(8)),
        _stop(const Color(0xFFEF4444), 'Drop', drop),
      ],
    );
  }

  Widget _stop(Color color, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
        SizedBox(width: context.w(8)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.regular.copyWith(
                fontSize: 11,
                height: 1,
                color: AppColors.slate400,
              ),
            ),
            Text(
              value,
              style: AppTypography.bold.copyWith(
                fontSize: 14,
                height: 1.2,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stats(BuildContext context) {
    return Container(
      height: context.h(64),
      decoration: BoxDecoration(
        color: context.torkk.surfaceMuted,
        borderRadius: BorderRadius.circular(context.r(14)),
      ),
      child: Row(
        children: [
          Expanded(child: _stat('4.2 km', 'Distance')),
          Container(
            width: 1,
            height: context.h(28),
            color: context.adaptiveTint(const Color(0xFFE2E8F0)),
          ),
          Expanded(child: _stat('18 min', 'Est. duration')),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: AppTypography.bold.copyWith(
            fontSize: 15,
            height: 1.2,
            letterSpacing: -0.2,
          ),
        ),
        Text(
          label,
          style: AppTypography.regular.copyWith(
            fontSize: 12,
            color: AppColors.slate400,
          ),
        ),
      ],
    );
  }

  Widget _infoLine(
    BuildContext context,
    IconData icon,
    Color iconColor,
    Color bg,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          width: context.w(32),
          height: context.w(32),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(context.r(8)),
          ),
          child: Icon(icon, color: iconColor, size: context.w(16)),
        ),
        SizedBox(width: context.w(10)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.regular.copyWith(
                fontSize: 11,
                height: 1,
                color: AppColors.slate400,
              ),
            ),
            Text(
              value,
              style: AppTypography.bold.copyWith(
                fontSize: 14,
                height: 1.2,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _decline(
    BuildContext context,
    VoidCallback onTap, {
    String label = 'Decline',
  }) {
    return SizedBox(
      height: context.h(46),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          side: const BorderSide(color: Color(0xFFEF4444)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.r(14)),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bold.copyWith(
            fontSize: 14,
            color: const Color(0xFFEF4444),
            height: 1,
          ),
        ),
      ),
    );
  }

  Widget _accept(
    BuildContext context,
    Color accent,
    String label,
    VoidCallback onTap, {
    IconData? icon,
  }) {
    return SizedBox(
      height: context.h(46),
      child: FilledButton.icon(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.r(14)),
          ),
        ),
        icon: icon == null
            ? const SizedBox.shrink()
            : Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        label: Text(
          label,
          style: AppTypography.bold.copyWith(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onPrimary,
            height: 1,
          ),
        ),
      ),
    );
  }
}
