import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class ScratchCardScreen extends StatelessWidget {
  const ScratchCardScreen({
    super.key,
    required this.onBack,
    required this.onReveal,
  });

  final VoidCallback onBack;
  final VoidCallback onReveal;

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Scratch Card',
      onBack: onBack,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.w(28),
          context.h(48),
          context.w(28),
          0,
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onReveal,
                child: Container(
                  width: double.infinity,
                  height: context.h(300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.r(24)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        context.adaptiveTint(Color(0xFFF8FAFF)),
                        context.adaptiveTint(Color(0xFFEDE9FE)),
                      ],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    AppAssets.giftCard,
                    width: context.w(170),
                    height: context.w(170),
                  ),
                ),
              ),
              SizedBox(height: context.h(14)),
              Text(
                'Scratch the card to see your reward',
                textAlign: TextAlign.center,
                style: AppTypography.regular.copyWith(
                  fontSize: 15,
                  color: context.torkk.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
