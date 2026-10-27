part of 'package:rider_app/driver_features/onboarding/screens/application_status_screen.dart';

class _ActionClipboard extends StatelessWidget {
  const _ActionClipboard();

  @override
  Widget build(BuildContext context) {
    final size = context.w(84);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: const _ClipboardPainter(AppColors.error),
          ),
          Positioned(
            right: 0,
            bottom: context.w(2),
            child: Container(
              width: context.w(26),
              height: context.w(26),
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: context.w(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
