part of 'package:rider_app/driver_features/onboarding/screens/verify_driving_license_screen.dart';

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({required this.onRetake, this.imagePath});

  final String? imagePath;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: context.h(80),
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.torkk.surfaceMuted,
            borderRadius: BorderRadius.circular(context.r(12)),
            border: Border.all(color: context.torkk.border),
          ),
          child: imagePath == null
              ? Icon(Icons.badge_outlined, color: AppColors.slate300, size: context.w(32))
              : Image.file(File(imagePath!), fit: BoxFit.cover),
        ),
        TextButton.icon(
          onPressed: onRetake,
          icon: Icon(Icons.refresh, size: context.w(16), color: context.legible(AppColors.primary)),
          label: Text(AppStrings.retake, style: AppTypography.regular.copyWith(color: context.legible(AppColors.primary), fontSize: 13)),
        ),
      ],
    );
  }
}
