import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/unified_button.dart';

class ScratchWonScreen extends StatelessWidget {
  const ScratchWonScreen({super.key, required this.onBack, required this.onClaim});

  final VoidCallback onBack;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: context.w(8), top: context.h(8)),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Spacer(),
                  SizedBox(
                    height: context.h(220),
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
                          child: Image.asset(
                            AppAssets.celebration,
                            width: context.w(300),
                            fit: BoxFit.contain,
                          ),
                        ),
                        Image.asset(
                          AppAssets.rewardCoins,
                          width: context.w(140),
                          height: context.w(140),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'You won',
                    textAlign: TextAlign.center,
                    style: AppTypography.bold.copyWith(fontSize: 18, height: 1.2, letterSpacing: -0.3),
                  ),
                  SizedBox(height: context.h(4)),
                  Text(
                    '50 Coins',
                    textAlign: TextAlign.center,
                    style: AppTypography.bold.copyWith(fontSize: 28, height: 1.15, letterSpacing: -0.4),
                  ),
                  SizedBox(height: context.h(8)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(48)),
                    child: Text(
                      'Great job ! Your reward has been credited to your Account.',
                      textAlign: TextAlign.center,
                      style: AppTypography.regular.copyWith(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.slate500,
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(context.w(20), context.h(8), context.w(20), context.h(16)),
              child: UnifiedButton(label: 'Claim', onPressed: onClaim),
            ),
          ],
        ),
      ),
    );
  }
}
