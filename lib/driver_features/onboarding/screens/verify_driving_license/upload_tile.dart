part of 'package:rider_app/driver_features/onboarding/screens/verify_driving_license_screen.dart';

class _UploadTile extends StatelessWidget {
  const _UploadTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.imagePath,
    this.reading = false,
  });

  final String label;
  final IconData icon;
  final String? imagePath;
  final bool reading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = context.r(16);
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: const Color(0xFFD8B4FE),
          radius: radius,
        ),
        child: Container(
          height: context.h(148),
          padding: EdgeInsets.symmetric(
            horizontal: context.w(8),
            vertical: context.h(16),
          ),
          decoration: BoxDecoration(
            color: context.adaptiveTint(const Color(0xFFFAF5FF)),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: reading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : imagePath == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: context.legible(AppColors.primary),
                      size: context.w(28),
                    ),
                    SizedBox(height: context.h(10)),
                    Text(
                      label,
                      style: AppTypography.bold.copyWith(
                        color: context.torkk.textPrimary,
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: context.h(2)),
                    Text(
                      AppStrings.tapToUpload,
                      style: AppTypography.regular.copyWith(
                        fontSize: 12,
                        color: context.torkk.textSecondary,
                      ),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(radius - 2),
                  child: Image.file(
                    File(imagePath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
        ),
      ),
    );
  }
}
