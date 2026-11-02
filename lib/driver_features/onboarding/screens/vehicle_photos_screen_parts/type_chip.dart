part of 'package:rider_app/driver_features/onboarding/screens/vehicle_photos_screen.dart';

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(18),
          vertical: context.h(10),
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : context.torkk.surface,
          borderRadius: BorderRadius.circular(context.r(20)),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.fieldBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bold.copyWith(
            fontSize: 13,
            height: 1.2,
            color: selected ? Colors.white : context.torkk.textPrimary,
          ),
        ),
      ),
    );
  }
}
