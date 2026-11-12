import 'package:rider_app/common/widgets/sheet_with_sos.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/screens/tickets_screen.dart';

import '../../common/constants/string_constants.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

part 'parcel_flow_screen_parts/dashed_border_painter.dart';
part 'parcel_flow_screen_parts/parcel_otp_boxes.dart';
part 'parcel_flow_screen_parts/parcel_otp_boxes_state.dart';
part 'parcel_flow_screen_parts/person_page.dart';
part 'parcel_flow_screen_parts/route_map.dart';
part 'parcel_flow_screen_sections.dart';

/// Sample parcel trip. No backend yet — each step is local.
enum _Phase {
  request,
  toPickup,
  arrivedPickup,
  verifyIntro,
  pickupOtp,
  checks,
  pickedUp,
  transit,
  arrivedDrop,
  dropOtp,
  proof,
  delivered,
  rate,
}

const _pickup = LatLng(28.5708, 77.3219);
const _drop = LatLng(28.5672, 77.3264);
const _route = [
  LatLng(28.5708, 77.3219),
  LatLng(28.5716, 77.3234),
  LatLng(28.5694, 77.3248),
  LatLng(28.5672, 77.3264),
];

class ParcelFlowScreen extends StatefulWidget {
  const ParcelFlowScreen({super.key});

  @override
  State<ParcelFlowScreen> createState() => _ParcelFlowScreenState();
}

class _ParcelFlowScreenState extends State<ParcelFlowScreen> {
  _Phase _phase = _Phase.request;
  int _seconds = 28;
  Timer? _timer;
  int _stars = 5;
  final _pickedTags = <String>{};
  final _otp = TextEditingController();
  final _otpFocus = FocusNode();
  final _comment = TextEditingController();
  String? _photoPath;
  final _checks = [true, true, true];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otp.dispose();
    _otpFocus.dispose();
    _comment.dispose();
    super.dispose();
  }

  void _go(_Phase phase) => setState(() => _phase = phase);

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _Phase.verifyIntro => _verifyIntro(context),
      _Phase.pickupOtp => _otpPage(context, sender: true),
      _Phase.checks => _checksPage(context),
      _Phase.dropOtp => _otpPage(context, sender: false),
      _Phase.proof => _proofPage(context),
      _Phase.delivered => _deliveredPage(context),
      _Phase.rate => _ratePage(context),
      _ => _mapPage(context),
    };
  }

  _Phase get _previousMap => switch (_phase) {
    _Phase.toPickup => _Phase.request,
    _Phase.arrivedPickup => _Phase.toPickup,
    _Phase.pickedUp => _Phase.checks,
    _Phase.transit => _Phase.pickedUp,
    _Phase.arrivedDrop => _Phase.transit,
    _ => _Phase.request,
  };

  Widget _checksPage(BuildContext context) {
    const labels = [
      'Parcel is properly packed',
      'Seal is intact',
      'No visible damage',
    ];
    return _page(
      context,
      title: 'Verify Parcel at Pickup',
      onBack: () => _go(_Phase.pickupOtp),
      bottom: _fillButton(
        context,
        'Confirm Verification',
        () => _go(_Phase.pickedUp),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(12),
          context.w(20),
          context.h(12),
        ),
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: context.h(12)),
            decoration: BoxDecoration(
              color: context.torkk.surfaceMuted,
              borderRadius: BorderRadius.circular(context.r(14)),
              border: Border.all(color: context.torkk.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _mini(
                    Icons.description_outlined,
                    'Parcel type',
                    'Documents',
                  ),
                ),
                Container(
                  width: 1,
                  height: context.h(36),
                  color: context.adaptiveTint(const Color(0xFFE2E8F0)),
                ),
                Expanded(
                  child: _mini(
                    Icons.balance_outlined,
                    'Size / Weight',
                    '1 kg (Small)',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.h(18)),
          Text(
            'Check Parcel Condition',
            style: AppTypography.bold.copyWith(
              fontSize: 14,
              height: 1.2,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: context.h(10)),
          for (var i = 0; i < labels.length; i++)
            GestureDetector(
              onTap: () => setState(() => _checks[i] = !_checks[i]),
              child: Container(
                margin: EdgeInsets.only(bottom: context.h(8)),
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(12),
                  vertical: context.h(12),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.r(12)),
                  border: Border.all(color: context.torkk.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        labels[i],
                        style: AppTypography.regular.copyWith(fontSize: 14),
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: _checks[i]
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFCBD5E1),
                      size: context.w(20),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: context.h(8)),
          Text(
            'Take parcel photo ( if required )',
            style: AppTypography.regular.copyWith(
              fontSize: 13,
              height: 1.2,
              color: context.torkk.textSecondary,
            ),
          ),
          SizedBox(height: context.h(12)),
          Row(
            children: [
              GestureDetector(
                onTap: _pickPhoto,
                child: CustomPaint(
                  painter: const _DashedBorderPainter(
                    color: Color(0xFFCBD5E1),
                    radius: 14,
                  ),
                  child: SizedBox(
                    width: context.w(88),
                    height: context.w(88),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_camera_outlined,
                          color: AppColors.slate400,
                          size: context.w(22),
                        ),
                        SizedBox(height: context.h(6)),
                        Text(
                          _photoPath == null ? 'Add Photo' : 'Added',
                          style: AppTypography.regular.copyWith(
                            fontSize: 12,
                            height: 1,
                            color: context.torkk.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.w(12)),
              Container(
                width: context.w(88),
                height: context.w(88),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E6C8),
                  borderRadius: BorderRadius.circular(context.r(14)),
                ),
                child: Icon(
                  Icons.inventory_2,
                  color: const Color(0xFFC4843A),
                  size: context.w(36),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _commentBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.r(16)),
      borderSide: BorderSide(color: context.torkk.border),
    );
  }

  Widget _ratePage(BuildContext context) {
    const tags = [
      'Polite',
      'On time',
      'Good Communication',
      'Safe ride',
      'Helpful',
    ];
    return _page(
      context,
      title: '',
      onBack: () => _go(_Phase.delivered),
      bottom: Column(
        children: [
          _fillButton(context, 'Submit', () => Navigator.of(context).pop()),
          SizedBox(height: context.h(8)),
          SizedBox(
            width: double.infinity,
            height: context.h(48),
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.r(14)),
                ),
              ),
              child: const Text('Skip'),
            ),
          ),
        ],
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
        children: [
          Center(
            child: CircleAvatar(
              radius: context.w(28),
              backgroundColor: context.adaptiveTint(const Color(0xFFF3E8FF)),
              child: Icon(
                Icons.person,
                color: context.legible(Color(0xFFBA2879)),
              ),
            ),
          ),
          SizedBox(height: context.h(8)),
          Text(
            'Rahul',
            textAlign: TextAlign.center,
            style: AppTypography.bold.copyWith(fontSize: 16),
          ),
          SizedBox(height: context.h(12)),
          Text(
            'How was your Ride?',
            textAlign: TextAlign.center,
            style: AppTypography.bold.copyWith(
              fontSize: 18,
              height: 1.2,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: context.h(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () => setState(() => _stars = i),
                  icon: Icon(
                    Icons.star_rounded,
                    color: i <= _stars
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFE2E8F0),
                    size: context.w(32),
                  ),
                ),
            ],
          ),
          Wrap(
            spacing: context.w(8),
            runSpacing: context.h(8),
            alignment: WrapAlignment.center,
            children: [
              for (final tag in tags)
                GestureDetector(
                  onTap: () => setState(
                    () => _pickedTags.contains(tag)
                        ? _pickedTags.remove(tag)
                        : _pickedTags.add(tag),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.w(12),
                      vertical: context.h(6),
                    ),
                    decoration: BoxDecoration(
                      color: _pickedTags.contains(tag)
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1)
                          : context.adaptiveTint(Color(0xFFF8FAFC)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tag,
                      style: AppTypography.regular.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: context.h(44)),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: context.w(337),
              height: context.h(134),
              child: TextField(
                controller: _comment,
                maxLength: 200,
                expands: true,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                onChanged: (_) => setState(() {}),
                style: AppTypography.regular.copyWith(
                  fontSize: 13,
                  height: 1.4,
                  color: context.torkk.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Add a comment (Optional)',
                  hintStyle: AppTypography.regular.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 16.5 / 11,
                    letterSpacing: 0,
                    color: const Color(0xFF94A3B8),
                  ),
                  filled: true,
                  fillColor: context.torkk.surface,
                  counterText: '',
                  contentPadding: EdgeInsets.all(context.w(12)),
                  border: _commentBorder(context),
                  enabledBorder: _commentBorder(context),
                  focusedBorder: _commentBorder(context),
                  disabledBorder: _commentBorder(context),
                ),
              ),
            ),
          ),
          SizedBox(height: context.h(6)),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_comment.text.length}/200',
              style: AppTypography.regular.copyWith(
                fontSize: 11,
                color: AppColors.slate400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null && mounted) setState(() => _photoPath = file.path);
  }
}
