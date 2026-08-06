import 'package:flutter/material.dart';
import '../common/theme/theme.dart';
import 'routes/driver_routes.dart';

class DriverApp extends StatelessWidget {
  static final ValueNotifier<bool> isPinkTheme = ValueNotifier<bool>(false);

  const DriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isPinkTheme,
      builder: (context, isPink, _) {
        return MaterialApp(
          title: 'Torkk Driver',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.dark,
          darkTheme: AppTheme.getTheme(isPink: isPink),
          initialRoute: '/',
          routes: DriverRoutes.routes,
        );
      },
    );
  }
}
