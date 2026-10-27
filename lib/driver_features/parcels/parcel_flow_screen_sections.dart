part of 'package:rider_app/driver_features/parcels/parcel_flow_screen.dart';

extension _ParcelFlowScreenStateSections on _ParcelFlowScreenState {
  Widget _mapPage(BuildContext context) {
    final clock =
        '${(_seconds ~/ 60).toString().padLeft(2, '0')}:${(_seconds % 60).toString().padLeft(2, '0')}';
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _RouteMap()),
          if (_phase == _Phase.request)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: context.h(150),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [context.adaptiveTint(Color(0xF2FFFFFF)), context.adaptiveTint(Color(0x00FFFFFF))],
                  ),
                ),
              ),
            ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  context.w(12),
                  context.h(4),
                  context.w(16),
                  0,
                ),
                child: _phase == _Phase.request
                    ? _greeting(context)
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: _backButton(() => _go(_previousMap)),
                      ),
              ),
            ),
          ),
          if (_phase == _Phase.request)
            Positioned(
              top: context.h(120),
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: context.w(56),
                  height: context.w(56),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    clock,
                    style: AppTypography.bold.copyWith(
                      fontSize: 12,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          if (_phase == _Phase.arrivedPickup || _phase == _Phase.arrivedDrop)
            Positioned(
              top: context.h(110),
              left: context.w(16),
              right: context.w(80),
              child: _banner(
                'You\'ve arrived',
                'Please wait for the customer.',
              ),
            ),
          if (_phase == _Phase.pickedUp)
            Positioned(
              top: context.h(110),
              left: context.w(16),
              right: context.w(80),
              child: _banner(
                'Parcel Picked up',
                'Successfully received from sender',
              ),
            ),
          Positioned(
            right: context.w(16),
            bottom: context.h(switch (_phase) {
              _Phase.request => 430,
              _Phase.toPickup ||
              _Phase.arrivedPickup ||
              _Phase.pickedUp ||
              _Phase.transit ||
              _Phase.arrivedDrop => 380,
              _ => 250,
            }),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SosScreen()),
              ),
              child: Container(
                width: context.w(56),
                height: context.w(56),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  'SOS',
                  style: AppTypography.bold.copyWith(
                    fontSize: 13,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: switch (_phase) {
              _Phase.request => _parcelRequestCard(context),
              _Phase.toPickup => _headingSheet(
                context,
                title: 'Heading to Pickup',
                chip: '2 mins away',
                action: 'Navigate',
                actionIcon: Icons.navigation_rounded,
                onAction: () => _go(_Phase.arrivedPickup),
              ),
              _Phase.arrivedPickup => _headingSheet(
                context,
                title: 'Arrived at pickup',
                action: 'Verify Pickup',
                onAction: () => _go(_Phase.verifyIntro),
              ),
              _Phase.pickedUp => _headingSheet(
                context,
                title: 'Arrived at Pickup',
                placeLabel: 'DROP',
                place: 'Sector 62, Noida',
                dropStop: true,
                action: 'Navigate',
                actionIcon: Icons.navigation_rounded,
                onAction: () => _go(_Phase.transit),
              ),
              _Phase.transit => _headingSheet(
                context,
                title: 'Parcel in Transit',
                role: 'Receiver',
                person: 'Amit',
                sender: false,
                placeLabel: 'Pickup',
                place: 'Sector 18, Noida',
                secondLabel: 'Drop',
                secondPlace: 'DLF Mall of India',
                action: 'Navigate',
                actionIcon: Icons.navigation_rounded,
                onAction: () => _go(_Phase.arrivedDrop),
              ),
              _Phase.arrivedDrop => _headingSheet(
                context,
                title: 'Arrived at Delivery',
                role: 'Receiver',
                person: 'Amit',
                sender: false,
                placeLabel: 'DROP',
                place: 'Sector 62, Noida',
                dropStop: true,
                action: 'Verify Delivery',
                onAction: () => _go(_Phase.dropOtp),
              ),
              _ => _sheet(context),
            },
          ),
        ],
      ),
    );
  }

  Widget _greeting(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning,',
                style: AppTypography.regular.copyWith(
                  fontSize: 13,
                  color: context.torkk.textSecondary,
                ),
              ),
              Text(
                'Rahul Sharma',
                style: AppTypography.bold.copyWith(
                  fontSize: 18,
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.notifications_none_rounded,
          color: context.torkk.textPrimary,
          size: context.w(22),
        ),
        SizedBox(width: context.w(10)),
        CircleAvatar(
          radius: context.w(16),
          backgroundColor: accent,
          child: Icon(Icons.person, color: Theme.of(context).colorScheme.onPrimary, size: context.w(18)),
        ),
      ],
    );
  }

  Widget _sheet(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        context.w(16),
        context.h(16),
        context.w(16),
        context.h(20),
      ),
      decoration: BoxDecoration(
        color: context.torkk.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.r(24)),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: const SizedBox.shrink(),
    );
  }

  Widget _parcelRequestCard(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: EdgeInsets.only(left: context.w(7)),
      child: Container(
        width: context.w(378),
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
              children: [
                Expanded(
                  child: Text(
                    AppStrings.parcelRequest,
                    style: AppTypography.bold.copyWith(
                      fontSize: 18,
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
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
            SizedBox(height: context.h(14)),
            Container(
              width: context.w(338),
              height: context.h(58),
              padding: EdgeInsets.fromLTRB(
                context.w(12),
                context.h(10),
                context.w(12),
                context.h(10),
              ),
              decoration: BoxDecoration(
                color: context.torkk.surfaceMuted.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(context.r(12)),
                border: Border.all(color: const Color(0xB2F1F5F9)),
              ),
              child: Row(
                children: [
                  Container(
                    width: context.w(32),
                    height: context.w(32),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(context.r(8)),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: accent,
                      size: context.w(18),
                    ),
                  ),
                  SizedBox(width: context.w(10)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.parcelType,
                        style: AppTypography.regular.copyWith(
                          fontSize: 11,
                          color: AppColors.slate400,
                          letterSpacing: 0.4,
                        ),
                      ),
                      Text(
                        'Documents • 1 kg (Small)',
                        style: AppTypography.bold.copyWith(
                          fontSize: 14,
                          height: 1.2,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: context.h(14)),
            SizedBox(
              width: context.w(338),
              height: context.h(44),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _personTap(context, 'Sender', 'Rahul Mehta', true),
                  _personTap(context, 'Receiver', 'Amit Verma', false),
                ],
              ),
            ),
            _parcelRoute(context),
            SizedBox(height: context.h(14)),
            Container(
              width: context.w(338),
              height: context.h(61),
              padding: EdgeInsets.fromLTRB(
                context.w(12),
                context.h(10),
                context.w(12),
                context.h(10),
              ),
              decoration: BoxDecoration(
                color: context.torkk.surfaceMuted.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(context.r(12)),
                border: Border.all(color: const Color(0xB2F1F5F9)),
              ),
              child: Row(
                children: [
                  Expanded(child: _parcelStat('4.2 km', 'Distance')),
                  SizedBox(width: context.w(10)),
                  Container(
                    width: 1,
                    height: context.h(28),
                    color: context.adaptiveTint(const Color(0xFFE2E8F0)),
                  ),
                  SizedBox(width: context.w(10)),
                  Expanded(child: _parcelStat('18 min', 'Est. duration')),
                ],
              ),
            ),
            SizedBox(height: context.h(24)),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: context.h(52),
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(
                          color: Color(0xFFEF4444),
                          width: 1.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.r(16)),
                        ),
                      ),
                      child: Text(
                        AppStrings.decline,
                        style: AppTypography.bold.copyWith(
                          fontSize: 16,
                          color: const Color(0xFFEF4444),
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: context.w(12)),
                Expanded(
                  child: SizedBox(
                    height: context.h(52),
                    child: FilledButton(
                      onPressed: () => _go(_Phase.toPickup),
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.r(16)),
                        ),
                      ),
                      child: Text(
                        AppStrings.accept,
                        style: AppTypography.bold.copyWith(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onPrimary,
                          height: 1,
                        ),
                      ),
                    ),
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

  Widget _parcelRoute(BuildContext context) {
    return SizedBox(
      width: context.w(338),
      height: context.h(118),
      child: Padding(
        padding: EdgeInsets.only(top: context.h(30), bottom: context.h(14)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: context.w(24),
              child: Column(
                children: [
                  Container(
                    width: context.w(10),
                    height: context.w(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: context.h(36),
                    color: context.adaptiveTint(const Color(0xFFE2E8F0)),
                  ),
                  Container(
                    width: context.w(10),
                    height: context.w(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.pickup,
                    style: AppTypography.regular.copyWith(
                      fontSize: 12,
                      height: 1,
                      color: AppColors.slate400,
                    ),
                  ),
                  Text(
                    'Sector 18, Noida',
                    style: AppTypography.bold.copyWith(
                      fontSize: 14,
                      height: 1,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: context.h(16)),
                  Text(
                    AppStrings.drop,
                    style: AppTypography.regular.copyWith(
                      fontSize: 12,
                      height: 1,
                      color: AppColors.slate400,
                    ),
                  ),
                  Text(
                    'DLF Mall of India',
                    style: AppTypography.bold.copyWith(
                      fontSize: 14,
                      height: 1,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _parcelStat(String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: AppTypography.bold.copyWith(
            fontSize: 16,
            height: 1,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: context.h(2)),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.regular.copyWith(
            fontSize: 12,
            height: 1,
            color: AppColors.slate400,
          ),
        ),
      ],
    );
  }

  Widget _headingSheet(
    BuildContext context, {
    required String title,
    String chip = '',
    String role = 'Sender',
    String person = 'Rahul',
    bool sender = true,
    String placeLabel = 'PICKUP',
    String place = 'Sector 62, Noida',
    bool dropStop = false,
    String? secondLabel,
    String? secondPlace,
    required String action,
    IconData? actionIcon,
    required VoidCallback onAction,
  }) {
    const success = Color(0xFF1A995B);
    const dropColor = Color(0xFFEF4444);
    return Padding(
      padding: EdgeInsets.only(left: context.w(8)),
      child: Container(
        width: context.w(378),
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
                  height: context.h(28),
                  padding: EdgeInsets.fromLTRB(
                    context.w(8),
                    context.h(6),
                    context.w(8),
                    context.h(6),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x121A995B),
                    borderRadius: BorderRadius.circular(context.r(7)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: context.w(8),
                        height: context.w(8),
                        decoration: const BoxDecoration(
                          color: success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: context.w(10)),
                      Text(
                        title,
                        style: AppTypography.bold.copyWith(
                          fontSize: 12,
                          height: 16 / 12,
                          letterSpacing: 0,
                          color: success,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (chip.isNotEmpty)
                  Container(
                    height: context.h(28),
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: context.w(10)),
                    decoration: BoxDecoration(
                      color: context.adaptiveTint(const Color(0xFFEFF6FF)),
                      borderRadius: BorderRadius.circular(context.r(8)),
                    ),
                    child: Text(
                      chip,
                      style: AppTypography.bold.copyWith(
                        fontSize: 12,
                        height: 16 / 12,
                        letterSpacing: 0,
                        color: context.legible(Color(0xFF2563EB)),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: context.h(18)),
            SizedBox(
              width: context.w(338),
              height: context.h(42),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: context.w(16),
                    backgroundColor: context.adaptiveTint(const Color(0xFFF1F5F9)),
                    child: Icon(
                      Icons.person,
                      size: context.w(18),
                      color: AppColors.slate400,
                    ),
                  ),
                  SizedBox(width: context.w(10)),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openPerson(context, sender: sender),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            role,
                            style: AppTypography.regular.copyWith(
                              fontSize: 11,
                              height: 1,
                              color: AppColors.slate400,
                            ),
                          ),
                          Text(
                            person,
                            style: AppTypography.bold.copyWith(
                              fontSize: 14,
                              height: 1,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _outlineIcon(
                    const Color(0xFF2563EB),
                    Icons.chat_bubble_outline_rounded,
                  ),
                  SizedBox(width: context.w(8)),
                  _outlineIcon(const Color(0xFF2563EB), Icons.call_outlined),
                ],
              ),
            ),
            SizedBox(height: context.h(18)),
            _sheetStop(
              context,
              dropStop ? dropColor : success,
              placeLabel,
              place,
            ),
            if (secondLabel != null && secondPlace != null) ...[
              SizedBox(height: context.h(12)),
              _sheetStop(context, dropColor, secondLabel, secondPlace),
            ],
            SizedBox(height: context.h(50)),
            Row(
              children: [
                Expanded(
                  child: _outlineButton(
                    context,
                    'Cancel',
                    () => _cancel(context),
                  ),
                ),
                SizedBox(width: context.w(12)),
                Expanded(
                  child: _fillButton(
                    context,
                    action,
                    onAction,
                    icon: actionIcon,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetStop(
    BuildContext context,
    Color color,
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: context.w(8),
              height: context.w(8),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: context.w(8)),
            Text(
              label,
              style: AppTypography.regular.copyWith(
                fontSize: 11,
                height: 1,
                color: AppColors.slate400,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: context.w(16)),
          child: Text(
            value,
            style: AppTypography.bold.copyWith(
              fontSize: 15,
              height: 1.2,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _outlineIcon(Color color, IconData icon) {
    return Container(
      width: context.w(36),
      height: context.w(36),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.torkk.border),
      ),
      child: Icon(icon, color: color, size: context.w(16)),
    );
  }

  Widget _verifyIntro(BuildContext context) {
    return _page(
      context,
      title: 'Verify Parcel at Pickup',
      showTitle: false,
      onBack: () => _go(_Phase.arrivedPickup),
      bottom: _fillButton(context, 'Continue', () => _go(_Phase.pickupOtp)),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(16),
        ),
        children: [
          Center(child: _scanFrame(context)),
          SizedBox(height: context.h(22)),
          Text(
            'Verify Parcel at Pickup',
            textAlign: TextAlign.center,
            style: AppTypography.bold.copyWith(
              fontSize: 18,
              height: 1.2,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: context.h(6)),
          Text(
            'Check the parcel and confirm\nbefore starting delivery.',
            textAlign: TextAlign.center,
            style: AppTypography.regular.copyWith(
              fontSize: 13,
              height: 1.4,
              color: context.torkk.textSecondary,
            ),
          ),
          SizedBox(height: context.h(22)),
          _infoCard(context, [
            GestureDetector(
              onTap: () => _openPerson(context, sender: true),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: context.w(18),
                    backgroundColor: context.adaptiveTint(const Color(0xFFF1F5F9)),
                    child: Icon(
                      Icons.person,
                      color: AppColors.slate400,
                      size: context.w(18),
                    ),
                  ),
                  SizedBox(width: context.w(10)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sender',
                        style: AppTypography.regular.copyWith(
                          fontSize: 11,
                          height: 1,
                          color: AppColors.slate400,
                        ),
                      ),
                      SizedBox(height: context.h(2)),
                      Text(
                        'Rahul Mehta',
                        style: AppTypography.bold.copyWith(
                          fontSize: 14,
                          height: 1.2,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: context.h(16)),
            _verifyRoute(context),
          ]),
          SizedBox(height: context.h(18)),
          _checkNote(context, 'Identity confirmed'),
          _checkNote(context, 'Account secured'),
          _checkNote(context, 'You can now complete your onboarding'),
        ],
      ),
    );
  }

  Widget _scanFrame(BuildContext context) {
    final frame = context.w(132);
    return SizedBox(
      width: frame,
      height: frame,
      child: Stack(
        children: [
          _scanCorner(context, top: true, left: true),
          _scanCorner(context, top: true, left: false),
          _scanCorner(context, top: false, left: true),
          _scanCorner(context, top: false, left: false),
          Center(
            child: Icon(
              Icons.inventory_2,
              size: context.w(52),
              color: const Color(0xFFE0A15A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scanCorner(
    BuildContext context, {
    required bool top,
    required bool left,
  }) {
    const color = Color(0xFF3DB7E4);
    final side = context.w(28);
    return Positioned(
      top: top ? 0 : null,
      bottom: top ? null : 0,
      left: left ? 0 : null,
      right: left ? null : 0,
      child: Container(
        width: side,
        height: side,
        decoration: BoxDecoration(
          border: Border(
            top: top
                ? const BorderSide(color: color, width: 3)
                : BorderSide.none,
            bottom: top
                ? BorderSide.none
                : const BorderSide(color: color, width: 3),
            left: left
                ? const BorderSide(color: color, width: 3)
                : BorderSide.none,
            right: left
                ? BorderSide.none
                : const BorderSide(color: color, width: 3),
          ),
        ),
      ),
    );
  }

  Widget _verifyRoute(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            SizedBox(height: context.h(4)),
            Container(
              width: context.w(10),
              height: context.w(10),
              decoration: const BoxDecoration(
                color: Color(0xFF22C55E),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: context.h(36),
              color: context.adaptiveTint(const Color(0xFFE2E8F0)),
            ),
            Container(
              width: context.w(10),
              height: context.w(10),
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        SizedBox(width: context.w(10)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pickup',
                style: AppTypography.regular.copyWith(
                  fontSize: 12,
                  height: 1,
                  color: AppColors.slate400,
                ),
              ),
              Text(
                'Sector 18, Noida',
                style: AppTypography.bold.copyWith(
                  fontSize: 14,
                  height: 1.2,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: context.h(14)),
              Text(
                'Drop',
                style: AppTypography.regular.copyWith(
                  fontSize: 12,
                  height: 1,
                  color: AppColors.slate400,
                ),
              ),
              Text(
                'DLF Mall of India',
                style: AppTypography.bold.copyWith(
                  fontSize: 14,
                  height: 1.2,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _otpPage(BuildContext context, {required bool sender}) {
    return _page(
      context,
      title: sender ? 'Verify Parcel at Pickup' : 'Verify Parcel at Delivery',
      onBack: () => _go(sender ? _Phase.verifyIntro : _Phase.arrivedDrop),
      child: Padding(
        padding: EdgeInsets.fromLTRB(context.w(24), context.h(18), context.w(24), 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter 4-digit OTP',
              style: AppTypography.bold.copyWith(fontSize: 24, height: 1.2),
            ),
            SizedBox(height: context.h(8)),
            Text(
              sender ? 'Ask the Sender for their 4-digit OTP.' : 'Ask the Receiver for their 4-digit OTP.',
              style: AppTypography.regular.copyWith(fontSize: 14.5, color: context.torkk.textSecondary),
            ),
            SizedBox(height: context.h(28)),
            _ParcelOtpBoxes(controller: _otp, focusNode: _otpFocus, length: 4),
            SizedBox(height: context.h(28)),
            _fillButton(context, 'Continue', () {
              if (_otp.text.length != 4) return;
              _otp.clear();
              _go(sender ? _Phase.checks : _Phase.proof);
            }),
          ],
        ),
      ),
    );
  }

  Widget _proofPage(BuildContext context) {
    return _page(
      context,
      title: 'Proof of Delivery',
      onBack: () => _go(_Phase.dropOtp),
      bottom: _fillButton(
        context,
        'Confirm Delivery',
        () => _go(_Phase.delivered),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(8),
          context.w(20),
          context.h(12),
        ),
        children: [
          Text(
            'Capture proof to complete delivery.',
            style: AppTypography.regular.copyWith(
              fontSize: 13,
              color: context.torkk.textSecondary,
            ),
          ),
          SizedBox(height: context.h(12)),
          Container(
            padding: EdgeInsets.all(context.w(12)),
            decoration: BoxDecoration(
              color: context.torkk.surface,
              borderRadius: BorderRadius.circular(context.r(16)),
              border: Border.all(color: context.torkk.border),
            ),
            child: Column(
              children: [
                _proofPhoto(context),
                SizedBox(height: context.h(12)),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: context.h(48),
                        child: OutlinedButton.icon(
                          onPressed: _pickPhoto,
                          icon: Icon(Icons.photo_camera_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
                          label: Text(
                            'Retake',
                            style: AppTypography.bold.copyWith(fontSize: 14, height: 1, color: Theme.of(context).colorScheme.primary),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: context.torkk.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(12))),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: context.w(10)),
                    SizedBox(
                      width: context.w(48),
                      height: context.h(48),
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: BorderSide(color: context.torkk.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(12))),
                        ),
                        child: Icon(Icons.more_horiz, color: context.torkk.textSecondary, size: context.w(20)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: context.h(12)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.h(10)),
            decoration: BoxDecoration(
              color: context.torkk.surfaceMuted,
              borderRadius: BorderRadius.circular(context.r(14)),
              border: Border.all(color: context.torkk.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: context.w(18),
                  backgroundColor: context.adaptiveTint(const Color(0xFFE2E8F0)),
                  child: Icon(Icons.person, color: AppColors.slate400, size: context.w(18)),
                ),
                SizedBox(width: context.w(10)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Receiver', style: AppTypography.regular.copyWith(fontSize: 11, height: 1, color: AppColors.slate400)),
                    SizedBox(height: context.h(2)),
                    Text('Amit', style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2, letterSpacing: -0.2)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _proofPhoto(BuildContext context) {
    return Container(
      height: context.h(180),
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(12)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF6B23C), Color(0xFFE8871A)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            child: Container(width: context.w(28), color: const Color(0x33B45309)),
          ),
          Container(
            width: context.w(168),
            padding: EdgeInsets.fromLTRB(context.w(10), context.h(10), context.w(10), context.h(8)),
            decoration: BoxDecoration(
              color: context.torkk.surface,
              borderRadius: BorderRadius.circular(context.r(4)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: context.h(28),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < 22; i++)
                        Expanded(
                          flex: i.isEven ? 1 : 2,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 0.6),
                            height: i % 3 == 0 ? context.h(28) : context.h(22),
                            color: Colors.black,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: context.h(4)),
                Text(
                  'PKG-8923-8891-TRK',
                  style: AppTypography.regular.copyWith(fontSize: 8, height: 1, letterSpacing: 0.2),
                ),
                SizedBox(height: context.h(6)),
                Container(height: 1, color: context.adaptiveTint(const Color(0xFFE2E8F0))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliveredPage(BuildContext context) {
    return _page(
      context,
      title: '',
      onBack: () => _go(_Phase.proof),
      bottom: Column(
        children: [
          _fillButton(context, 'Done', () => _go(_Phase.rate)),
          SizedBox(height: context.h(8)),
          SizedBox(
            width: double.infinity,
            height: context.h(48),
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const IssueCategoryScreen()),
              ),
              icon: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 18),
              label: Text(
                'Report an Issue',
                style: AppTypography.bold.copyWith(fontSize: 14, height: 1, color: const Color(0xFFEF4444)),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: context.torkk.surface,
                side: const BorderSide(color: Color(0xFFEF4444)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(16))),
              ),
            ),
          ),
        ],
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
        children: [
          SizedBox(
            height: context.h(230),
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ColorFiltered(
                  colorFilter: const ColorFilter.matrix(<double>[
                    1, 0, 0, 0, 0,
                    0, 1, 0, 0, 0,
                    0, 0, 1, 0, 0,
                    1, 1, 1, 0, 0,
                  ]),
                  child: Image.asset(AppAssets.celebration, width: context.w(340), fit: BoxFit.contain),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 36),
                    SizedBox(height: context.h(8)),
                    Container(
                      width: context.w(72),
                      height: context.w(72),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: context.torkk.surfaceMuted, shape: BoxShape.circle),
                      child: Icon(Icons.inventory_2_rounded, color: const Color(0xFFE8A15A), size: context.w(36)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            'Parcel Delivered',
            textAlign: TextAlign.center,
            style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2, letterSpacing: -0.3),
          ),
          SizedBox(height: context.h(4)),
          Text(
            'Successfully delivered to',
            textAlign: TextAlign.center,
            style: AppTypography.regular.copyWith(fontSize: 13, height: 1.3, color: context.torkk.textSecondary),
          ),
          Text(
            'Amit Verma',
            textAlign: TextAlign.center,
            style: AppTypography.bold.copyWith(fontSize: 14, height: 1.3, letterSpacing: -0.2),
          ),
          SizedBox(height: context.h(16)),
          _moneyRow(context, Icons.receipt_long_outlined, const Color(0xFFFFF7ED), const Color(0xFFF97316), 'Ride Fare', '₹ 285'),
          SizedBox(height: context.h(8)),
          _moneyRow(context, Icons.account_balance_wallet_outlined, const Color(0xFFEFF6FF), const Color(0xFF3B82F6), 'Payment', 'Paid Cash'),
          SizedBox(height: context.h(12)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(14),
              vertical: context.h(12),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.r(14)),
              gradient: LinearGradient(
                colors: [Color(0xFF0F3FBF),Color(0xFF61217E),Color(0xFFBA2879)],
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.card_giftcard_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You earned 200 coins',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Get your reward unlocked!',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _cancel(BuildContext context) {
    var reason = 0;
    const reasons = [
      "Customer isn't at pickup location",
      'Customer asked me to cancel',
      'Wrong pickup location',
      'Safety concern',
      'Vehicle issue',
      'Other',
    ];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.torkk.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.r(20)),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                context.w(20),
                context.h(12),
                context.w(20),
                context.h(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Text(
                    'Cancel Parcel ?',
                    style: AppTypography.bold.copyWith(
                      fontSize: 18,
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    "Tell us why you're cancelling.",
                    style: AppTypography.regular.copyWith(
                      fontSize: 13,
                      color: context.torkk.textSecondary,
                    ),
                  ),
                  SizedBox(height: context.h(12)),
                  Text(
                    'Cancellation Reason?',
                    style: AppTypography.bold.copyWith(fontSize: 14),
                  ),
                  for (var i = 0; i < reasons.length; i++)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        reasons[i],
                        style: AppTypography.regular.copyWith(fontSize: 14),
                      ),
                      trailing: Icon(
                        reason == i
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: reason == i
                            ? Theme.of(context).colorScheme.primary
                            : AppColors.slate400,
                      ),
                      onTap: () => setSheet(() => reason = i),
                    ),
                  _fillButton(context, 'Cancel Parcel', () {
                    Navigator.pop(sheetContext);
                    _go(_Phase.request);
                  }),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: Text(
                        "No, Don't cancel",
                        style: AppTypography.bold.copyWith(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openPerson(BuildContext context, {required bool sender}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => _PersonPage(sender: sender)),
    );
  }

  Widget _personTap(
    BuildContext context,
    String role,
    String name,
    bool sender,
  ) {
    return GestureDetector(
      onTap: () => _openPerson(context, sender: sender),
      child: Container(
        width: context.w(169),
        height: context.h(44),
        padding: EdgeInsets.all(context.w(8)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.r(12)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: context.w(14),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    role,
                    style: AppTypography.regular.copyWith(
                      fontSize: 11,
                      height: 1,
                      color: AppColors.slate400,
                    ),
                  ),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bold.copyWith(
                      fontSize: 13,
                      height: 1,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _banner(String title, String body) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.torkk.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8)],
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bold.copyWith(fontSize: 13, height: 1.2),
                ),
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
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.w(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _checkNote(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.h(4)),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 18),
          SizedBox(width: context.w(8)),
          Text(text, style: AppTypography.regular.copyWith(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _mini(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(12)),
      child: Row(
        children: [
          Container(
            width: context.w(32),
            height: context.w(32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.adaptiveTint(const Color(0xFFEDE9FE)),
              borderRadius: BorderRadius.circular(context.r(8)),
            ),
            child: Icon(
              icon,
              color: context.legible(Color(0xFF7C3AED)),
              size: context.w(16),
            ),
          ),
          SizedBox(width: context.w(8)),
          Expanded(
            child: Column(
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
                SizedBox(height: context.h(2)),
                Text(
                  value,
                  style: AppTypography.bold.copyWith(
                    fontSize: 13,
                    height: 1.2,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _moneyRow(BuildContext context, IconData icon, Color iconBg, Color iconColor, String label, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.h(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(36),
            height: context.w(36),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(context.r(10))),
            child: Icon(icon, color: iconColor, size: context.w(18)),
          ),
          SizedBox(width: context.w(10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.regular.copyWith(fontSize: 12, height: 1, color: AppColors.slate400)),
              SizedBox(height: context.h(4)),
              Text(value, style: AppTypography.bold.copyWith(fontSize: 14, height: 1.2, letterSpacing: -0.2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _page(
    BuildContext context, {
    required String title,
    required VoidCallback onBack,
    required Widget child,
    Widget? bottom,
    bool showTitle = true,
  }) {
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
                  _backButton(onBack),
                  if (showTitle)
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.bold.copyWith(
                          fontSize: 18,
                          height: 1.2,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(child: child),
            if (bottom != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.w(20),
                  0,
                  context.w(20),
                  context.h(12),
                ),
                child: bottom,
              ),
          ],
        ),
      ),
    );
  }

  Widget _backButton(VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        Icons.arrow_back_ios_new,
        size: 18,
        color: context.torkk.textPrimary,
      ),
    );
  }

  // Widget _fillButton(
  //   BuildContext context,
  //   String label,
  //   VoidCallback onTap, {
  //   IconData? icon,
  // }) {
  //   return Padding(
  //     padding: EdgeInsets.fromLTRB(context.w(0), 0, 0, 0),
  //     child: SizedBox(
  //       width: double.infinity,
  //       height: context.h(48),
  //       child: FilledButton.icon(
  //         onPressed: onTap,
  //         style: FilledButton.styleFrom(
  //           backgroundColor: Theme.of(context).colorScheme.primary,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(context.r(14)),
  //           ),
  //         ),
  //         icon: icon == null
  //             ? const SizedBox.shrink()
  //             : Icon(icon, color: Colors.white, size: 16),
  //         label: Text(
  //           label,
  //           style: AppTypography.bold.copyWith(
  //             fontSize: 15,
  //             height: 1,
  //             color: Colors.white,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _fillButton(
      BuildContext context,
      String label,
      VoidCallback onTap, {
        IconData? icon,
      }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(context.w(0), 0, 0, 0),
      child: SizedBox(
        width: double.infinity,
        height: context.h(48),
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.r(14)),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTypography.bold.copyWith(
                  fontSize: 15,
                  height: 1,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              if (icon != null) ...[
                SizedBox(width: context.w(8)),
                Icon(icon, color: Theme.of(context).colorScheme.onPrimary, size: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _outlineButton(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) {
    return SizedBox(
      height: context.h(48),
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
            fontSize: 15,
            height: 1,
            color: const Color(0xFFEF4444),
          ),
        ),
      ),
    );
  }
}
