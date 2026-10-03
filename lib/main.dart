import 'package:flutter/material.dart';
import 'package:rider_app/app/app_bootstrap.dart';
import 'package:rider_app/app/driver_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeRepository = await AppBootstrap.start();
  runApp(DriverApp(themeRepository: themeRepository));
}
