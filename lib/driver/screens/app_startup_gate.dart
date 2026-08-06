import 'package:flutter/material.dart';

import '../../common/services/location_consent_service.dart';
import '../../common/widgets/location_consent_screen.dart';
import 'driver_screens.dart';

/// First screen after launch: requires location consent before onboarding/home.
class AppStartupGate extends StatefulWidget {
  const AppStartupGate({super.key});

  @override
  State<AppStartupGate> createState() => _AppStartupGateState();
}

class _AppStartupGateState extends State<AppStartupGate> {
  bool _loading = true;
  bool _consentAccepted = false;

  @override
  void initState() {
    super.initState();
    _loadConsent();
  }

  Future<void> _loadConsent() async {
    final accepted = await LocationConsentService.hasAccepted();
    if (!mounted) return;
    setState(() {
      _consentAccepted = accepted;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_consentAccepted) {
      return LocationConsentScreen(
        onAccepted: () {
          if (!mounted) return;
          setState(() => _consentAccepted = true);
        },
      );
    }

    return const DriverOnboardingScreen();
  }
}
