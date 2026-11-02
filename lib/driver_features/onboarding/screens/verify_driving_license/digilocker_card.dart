part of 'package:rider_app/driver_features/onboarding/screens/verify_driving_license_screen.dart';

class _DigilockerCard extends StatelessWidget {
  const _DigilockerCard({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(context.w(14)),
        decoration: BoxDecoration(
          color: context.adaptiveTint(const Color(0xFFF6F3FB)),
          borderRadius: BorderRadius.circular(context.r(16)),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.fieldBorder,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: context.w(40),
              height: context.w(40),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_upload_outlined,
                color: Colors.white,
                size: context.w(22),
              ),
            ),
            SizedBox(width: context.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.verifyWithDigilocker,
                    style: AppTypography.bold.copyWith(
                      color: context.torkk.textPrimary,
                      fontSize: 14,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: context.h(4)),
                  Text(
                    AppStrings.verifyWithDigilockerSubtitle,
                    style: AppTypography.regular.copyWith(
                      fontSize: 12,
                      height: 1.3,
                      color: context.torkk.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: context.legible(AppColors.primary),
              size: context.w(20),
            ),
          ],
        ),
      ),
    );
  }
}
