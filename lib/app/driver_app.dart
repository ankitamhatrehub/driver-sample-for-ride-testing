import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rider_app/app/theme/theme_bloc.dart';
import 'package:rider_app/app/theme/theme_event.dart';
import 'package:rider_app/app/theme/theme_repository.dart';
import 'package:rider_app/app/theme/theme_state.dart';
import 'package:rider_app/common/routes/app_router.dart';
import 'package:rider_app/common/theme/theme.dart';
import 'package:rider_app/driver_features/onboarding/onboarding_session.dart';

class DriverApp extends StatelessWidget {
  const DriverApp({super.key, required this.themeRepository});

  final ThemeRepository themeRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = ThemeBloc(themeRepository);
        OnboardingSession.instance.publishAccent = (isPink) {
          bloc.add(AccentChanged(isPink: isPink));
        };
        return bloc;
      },
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Torkk Driver',
            debugShowCheckedModeBanner: false,
            themeMode: state.themeMode,
            theme: AppTheme.getTheme(isPink: state.isPink, isDark: false),
            darkTheme: AppTheme.getTheme(isPink: state.isPink, isDark: true),
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
