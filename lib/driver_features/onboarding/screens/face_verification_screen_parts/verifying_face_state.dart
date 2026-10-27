part of 'package:rider_app/driver_features/onboarding/screens/face_verification_screen.dart';

class _VerifyingFaceState extends State<_VerifyingFace> with SingleTickerProviderStateMixin {
  static final _labels = [
    AppStrings.photoCaptured,
    AppStrings.analyzingFace,
    AppStrings.checkingLiveness,
    AppStrings.finalizingVerification,
  ];

  int _done = 0;
  Timer? _timer;
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
    _timer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted) return;
      if (_done >= _labels.length) {
        timer.cancel();
        widget.onFinished();
        return;
      }
      setState(() => _done++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _spin.dispose();
    super.dispose();
  }

  _StepState _stateFor(int index) {
    if (index < _done) return _StepState.done;
    if (index == _done) return _StepState.active;
    return _StepState.waiting;
  }

  @override
  Widget build(BuildContext context) {
    final ring = context.w(120);
    return Scaffold(
      backgroundColor: context.torkk.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(context.w(28), context.h(36), context.w(28), context.h(16)),
          child: Column(
            children: [
              SizedBox(
                width: ring,
                height: ring,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    RotationTransition(
                      turns: _spin,
                      child: CustomPaint(
                        size: Size(ring, ring),
                        painter: const _SpinRingPainter(),
                      ),
                    ),
                    CircleAvatar(
                      radius: context.w(46),
                      backgroundColor: context.adaptiveTint(const Color(0xFFF5F3FF)),
                      backgroundImage: widget.selfiePath == null ? null : FileImage(File(widget.selfiePath!)),
                      child: widget.selfiePath == null
                          ? Icon(Icons.person, color: context.legible(AppColors.primary), size: context.w(32))
                          : null,
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.h(24)),
              Text(AppStrings.verifyingYourFace, style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2)),
              SizedBox(height: context.h(6)),
              Text(
                AppStrings.verifyingFaceSubtitle,
                textAlign: TextAlign.center,
                style: AppTypography.regular.copyWith(fontSize: 12, color: context.torkk.textSecondary),
              ),
              SizedBox(height: context.h(28)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < _labels.length; i++)
                        _VerifyStep(
                          label: _labels[i],
                          state: _stateFor(i),
                          last: i == _labels.length - 1,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
