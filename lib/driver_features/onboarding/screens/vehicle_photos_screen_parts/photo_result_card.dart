part of 'package:rider_app/driver_features/onboarding/screens/vehicle_photos_screen.dart';

class _PhotoResultCard extends StatelessWidget {
  const _PhotoResultCard({
    required this.label,
    required this.failed,
    this.onRetake,
  });

  final String label;
  final bool failed;
  final VoidCallback? onRetake;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(8)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                failed ? Icons.error : Icons.check_circle,
                size: context.w(14),
                color: failed
                    ? context.legible(AppColors.error)
                    : AppColors.green600,
              ),
              SizedBox(width: context.w(4)),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bold.copyWith(fontSize: 11, height: 1.2),
                ),
              ),
            ],
          ),
          Text(
            failed
                ? AppStrings.verificationFailedLabel
                : AppStrings.kycVerified,
            style: AppTypography.regular.copyWith(
              fontSize: 10,
              color: failed
                  ? context.legible(AppColors.error)
                  : AppColors.green600,
            ),
          ),
          SizedBox(height: context.h(6)),
          ClipRRect(
            borderRadius: BorderRadius.circular(context.r(8)),
            child: Image.asset(
              AppAssets.cab,
              height: context.h(72),
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          if (onRetake != null) ...[
            SizedBox(height: context.h(6)),
            GestureDetector(
              onTap: onRetake,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.refresh,
                    size: context.w(14),
                    color: context.legible(AppColors.primary),
                  ),
                  SizedBox(width: context.w(4)),
                  Text(
                    AppStrings.retake,
                    style: AppTypography.regular.copyWith(
                      fontSize: 12,
                      color: context.legible(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
