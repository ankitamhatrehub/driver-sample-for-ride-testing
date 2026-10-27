import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/routes/app_routes.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

TextStyle _inter({
  double? fontSize,
  FontWeight? fontWeight,
  double? height,
  Color? color,
}) => TextStyle(
  fontFamily: AppTypography.fontFamily,
  fontSize: fontSize,
  fontWeight: fontWeight,
  height: height,
  color: color,
);

/// Hero image from `assets/coming_soon/`. The artwork is not bundled in every
/// build, so a missing file shows a neutral icon instead of throwing.
class _HeroImage extends StatelessWidget {
  const _HeroImage(this.name, {required this.height, required this.fallback});

  final String name;
  final double height;
  final IconData fallback;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/coming_soon/$name.png',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => SizedBox(
        height: height,
        child: Icon(
          fallback,
          size: height * 0.5,
          color: context.torkk.textDisabled,
        ),
      ),
    );
  }
}

/// Neighbourhood launch screen shown when the backend says service is unavailable.
/// The other frames in the design are additional pages in the same screen.
class ComingSoonScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onChangeLocation;

  const ComingSoonScreen({super.key, this.onBack, this.onChangeLocation});

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> {
  final PageController _pages = PageController();
  bool _notified = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reopen_to_signup', true);
    await prefs.setBool('is_outside_delhi_ncr', true);
    final notified = prefs.getBool('notify_torkk_launch') ?? false;
    if (!mounted) return;
    setState(() => _notified = notified);
  }

  Future<void> _notify() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notify_torkk_launch', true);
    if (!mounted) return;
    setState(() => _notified = true);
  }

  Future<void> _openInstagram() async {
    final uri = Uri.parse(
      'https://www.instagram.com/torkkapp?mdxt=MTQzdzJtNTE3N2V4dA==',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showBack = widget.onBack != null || Navigator.canPop(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_outside_delhi_ncr', false);
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: context.torkk.background,
        body: SafeArea(
          child: Column(
            children: [
              if (showBack)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: context.torkk.textPrimary,
                        ),
                        onPressed: _handleBack,
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: PageView(
                  controller: _pages,
                  children: [
                    _NeighbourhoodPage(
                      notified: _notified,
                      onNotify: _notify,
                      onInstagram: _openInstagram,
                      onChangeLocation:
                          widget.onChangeLocation ??
                          () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('is_outside_delhi_ncr', false);
                            if (context.mounted) {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                context.go(AppRoutes.login);
                              }
                            }
                          },
                    ),
                    _LaunchPage(onNotify: _notify),
                    _FeaturePage(onNotify: _notify),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeighbourhoodPage extends StatelessWidget {
  final bool notified;
  final VoidCallback onNotify;
  final VoidCallback onInstagram;
  final VoidCallback? onChangeLocation;

  const _NeighbourhoodPage({
    required this.notified,
    required this.onNotify,
    required this.onInstagram,
    this.onChangeLocation,
  });

  @override
  Widget build(BuildContext context) {
    return _Fill(
      children: [
        const SizedBox(height: 16),
        const _GradientLine('Coming Soon'),
        Text(
          'to your',
          textAlign: TextAlign.center,
          style: _inter(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            height: 1.15,
            color: context.legible(AppColors.primary),
          ),
        ),
        const _GradientLine('Neighbourhood'),
        const SizedBox(height: 12),
        Text(
          "We're expanding soon. Be the first to\nknow when Torkk arrives on your area.",
          textAlign: TextAlign.center,
          style: _inter(
            fontSize: 14,
            height: 1.45,
            color: const Color(0xFF8B909C),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        const _ServiceChips(),
        const Spacer(),
        _HeroImage(
          'scooter_hero',
          height: 195,
          fallback: Icons.two_wheeler_rounded,
        ),
        const Spacer(),
        _NotifyButton(
          label: notified
              ? "You're on the list"
              : 'Notify me when Torkk launches',
          icon: notified ? Icons.check_rounded : Icons.notifications_rounded,
          onPressed: notified ? null : onNotify,
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: onInstagram,
          child: Text(
            'Get Updates on Instagram',
            style: _inter(
              color: context.legible(const Color(0xFF2D57C7)),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        if (onChangeLocation != null)
          TextButton.icon(
            onPressed: onChangeLocation,
            icon: Icon(
              Icons.edit_location_alt_outlined,
              size: 18,
              color: context.legible(const Color(0xFF6B21A8)),
            ),
            label: Text(
              'Change or Enter Location',
              style: _inter(
                color: context.legible(const Color(0xFF6B21A8)),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _LaunchPage extends StatelessWidget {
  final VoidCallback onNotify;
  const _LaunchPage({required this.onNotify});

  @override
  Widget build(BuildContext context) {
    return _Fill(
      children: [
        const SizedBox(height: 12),
        _HeroImage(
          'gift_box',
          height: 190,
          fallback: Icons.card_giftcard_rounded,
        ),
        const SizedBox(height: 18),
        const _GradientLine('Coming Soon', size: 34),
        const Spacer(),
        _HeroImage(
          'share_hero',
          height: 180,
          fallback: Icons.ios_share_rounded,
        ),
        const Spacer(),
        _NotifyButton(
          label: 'Notify Me',
          icon: Icons.notifications_rounded,
          onPressed: onNotify,
        ),
        const SizedBox(height: 10),
        Text(
          'Be the first to know when it is live.',
          style: _inter(
            color: const Color(0xFF8B909C),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _FeaturePage extends StatelessWidget {
  final VoidCallback onNotify;
  const _FeaturePage({required this.onNotify});

  @override
  Widget build(BuildContext context) {
    return _Fill(
      children: [
        const SizedBox(height: 8),
        _HeroImage(
          'gift_box',
          height: 168,
          fallback: Icons.card_giftcard_rounded,
        ),
        const SizedBox(height: 8),
        Text(
          'New Feature',
          textAlign: TextAlign.center,
          style: _inter(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.15,
            color: context.legible(AppColors.primary),
          ),
        ),
        const _GradientLine('Coming Soon', size: 30),
        const SizedBox(height: 8),
        Text(
          "We're working on something exciting to\nbring a better experience.",
          textAlign: TextAlign.center,
          style: _inter(
            fontSize: 14,
            height: 1.4,
            color: const Color(0xFF8B909C),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        const _FeatureCard(),
        const Spacer(),
        _NotifyButton(
          label: 'Notify Me',
          icon: Icons.notifications_rounded,
          onPressed: onNotify,
        ),
        const SizedBox(height: 10),
        const Text(
          'Be the first to know when it is live.',
          style: TextStyle(
            color: Color(0xFF8B909C),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ServiceChips extends StatelessWidget {
  const _ServiceChips();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _Chip(icon: Icons.inventory_2_outlined, label: 'Parcel'),
        Container(
          width: 1,
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          color: context.themed(
            light: const Color(0xFFE4E0EA),
            dark: context.torkk.border,
          ),
        ),
        const _Chip(icon: Icons.directions_car_filled_outlined, label: 'Ride'),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: context.torkk.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: context.themed(
            light: const Color(0xFFE6E1EE),
            dark: context.torkk.border,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1A1030),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: context.themed(
              light: const Color(0xFF5C6570),
              dark: context.torkk.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: context.torkk.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.torkk.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.themed(
            light: const Color(0xFFE7E4EF),
            dark: context.torkk.border,
          ),
        ),
      ),
      child: Column(
        children: [
          _FeatureRow(
            icon: Icons.monetization_on_rounded,
            iconColor: Color(0xFFF5B400),
            iconBackground: Color(0xFFFFF4D8),
            label: 'More Earning Opportunities',
          ),
          Divider(
            height: 1,
            color: context.themed(
              light: const Color(0xFFEDEAF2),
              dark: context.torkk.divider,
            ),
          ),
          _FeatureRow(
            icon: Icons.card_giftcard_rounded,
            iconColor: Color(0xFF7A3EAF),
            iconBackground: Color(0xFFF4EEFF),
            label: 'Exciting New Features',
          ),
          Divider(
            height: 1,
            color: context.themed(
              light: const Color(0xFFEDEAF2),
              dark: context.torkk.divider,
            ),
          ),
          _FeatureRow(
            icon: Icons.bookmark_rounded,
            iconColor: Color(0xFF7A3EAF),
            iconBackground: Color(0xFFF4EEFF),
            label: 'Better Experience',
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;

  const _FeatureRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.adaptiveTint(iconBackground),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: context.legible(iconColor), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: context.torkk.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientLine extends StatelessWidget {
  final String text;
  final double size;
  const _GradientLine(this.text, {this.size = 32});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment(0.96, 0.28),
        end: Alignment(-0.96, -0.28),
        stops: [0.0, 0.3942, 1.0],
        colors: [Color(0xFFBA2879), Color(0xFF61217E), Color(0xFF0F3FBF)],
      ).createShader(bounds),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: _inter(
          fontSize: size,
          fontWeight: FontWeight.w800,
          height: 1.15,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _NotifyButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const _NotifyButton({
    required this.label,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final fill = context.torkk.actionFill(AppColors.primary);
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: fill,
          disabledBackgroundColor: fill,
          foregroundColor: onColorFor(fill),
          disabledForegroundColor: onColorFor(fill),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fill extends StatelessWidget {
  final List<Widget> children;
  const _Fill({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: Column(children: children),
              ),
            ),
          ),
        );
      },
    );
  }
}
