import 'dart:async';

import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/onboarding_info_banner.dart';

class ConnectingDigilockerScreen extends StatelessWidget {
  final VoidCallback onBack;
  final bool ticking;
  final VoidCallback? onTickingFinished;

  const ConnectingDigilockerScreen({
    super.key,
    required this.onBack,
    this.ticking = false,
    this.onTickingFinished,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      AppStrings.connectingDigilocker,
      AppStrings.awaitingAuthentication,
      AppStrings.fetchingDocuments,
      AppStrings.verifyingDocuments,
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(context.w(24), context.h(8), context.w(24), context.h(16)),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!ticking) ...[
                      SizedBox(
                        width: context.w(56),
                        height: context.w(56),
                        child: const CircularProgressIndicator(
                          strokeWidth: 4,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: context.h(24)),
                      Text(
                        AppStrings.connectingDigilockerSubtitle,
                        textAlign: TextAlign.center,
                        style: AppTypography.regular.copyWith(
                          color: AppColors.secondaryTextColor,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: context.h(28)),
                    ],
                    Center(
                      child: ticking
                          ? _TickSequence(onFinished: onTickingFinished ?? () {})
                          : IntrinsicWidth(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(steps.length, (index) {
                                  return _ConnectStep(
                                    label: steps[index],
                                    active: index == 0,
                                    showLine: index != steps.length - 1,
                                  );
                                }),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              OnboardingInfoBanner(message: AppStrings.digilockerWaitHint),
            ],
          ),
        ),
      ),
    );
  }
}

class _TickSequence extends StatefulWidget {
  const _TickSequence({required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<_TickSequence> createState() => _TickSequenceState();
}

class _TickSequenceState extends State<_TickSequence> {
  static final _steps = [
    AppStrings.awaitingAuthentication,
    AppStrings.fetchingDocuments,
    AppStrings.verifyingDocuments,
  ];

  int _done = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted) return;
      if (_done >= _steps.length) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_steps.length, (index) {
          return _ConnectStep(
            label: _steps[index],
            done: index < _done,
            showLine: index != _steps.length - 1,
          );
        }),
      ),
    );
  }
}

class _ConnectStep extends StatelessWidget {
  const _ConnectStep({
    required this.label,
    this.active = false,
    this.done = false,
    required this.showLine,
  });

  final String label;
  final bool active;
  final bool done;
  final bool showLine;

  static const Color _active = Color(0xFF5B21B6);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          child: Column(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? AppColors.green600
                      : active
                      ? _active
                      : Colors.white,
                  border: done || active ? null : Border.all(color: AppColors.slate300, width: 1.5),
                ),
                child: done
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : active
                    ? const Icon(Icons.cloud_upload, color: Colors.white, size: 12)
                    : null,
              ),
              if (showLine)
                Container(
                  width: 2,
                  height: context.h(28),
                  color: done
                      ? AppColors.green600
                      : active
                      ? _active
                      : AppColors.slate200,
                ),
            ],
          ),
        ),
        SizedBox(width: context.w(12)),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            label,
            style: done || active
                ? AppTypography.bold.copyWith(fontSize: 16, height: 1.2, color: AppColors.textPrimary)
                : AppTypography.regular.copyWith(fontSize: 14, color: AppColors.secondaryTextColor),
          ),
        ),
      ],
    );
  }
}
