import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rider_app/service/driver_api_service.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

// --- DRIVER PERFORMANCE SCREEN ---
class DriverPerformanceScreen extends StatefulWidget {
  const DriverPerformanceScreen({super.key});

  @override
  State<DriverPerformanceScreen> createState() =>
      _DriverPerformanceScreenState();
}

class _DriverPerformanceScreenState extends State<DriverPerformanceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  double _acceptanceRate = 0.95;
  double _cancellationRate = 0.02;
  double _completionRate = 0.98;
  double _driverRating = 5.0;
  double _performanceScore = 95.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
    _fetchLivePerformanceData();
  }

  Future<void> _fetchLivePerformanceData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString('user_phone') ?? '';
      if (phone.isNotEmpty) {
        final profile = await DriverApiService.fetchProfile(phone);
        if (mounted) {
          setState(() {
            if (profile['rating'] != null) {
              _driverRating = (profile['rating'] as num).toDouble();
            }
            if (profile['acceptance_rate'] != null) {
              _acceptanceRate = (profile['acceptance_rate'] as num).toDouble();
            }
            if (profile['cancellation_rate'] != null) {
              _cancellationRate = (profile['cancellation_rate'] as num)
                  .toDouble();
            }
            if (profile['completion_rate'] != null) {
              _completionRate = (profile['completion_rate'] as num).toDouble();
            }
            _performanceScore = (_driverRating / 5.0) * 100.0;
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required double percentage,
    required IconData icon,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.torkk.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.torkk.border),
            boxShadow: [
              BoxShadow(
                color: context.themed(light: Colors.black12, dark: context.torkk.textSecondary),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: context.torkk.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: percentage * _animation.value,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF4F46E5);
    return Scaffold(
      backgroundColor: context.torkk.surfaceMuted,
      appBar: AppBar(
        title: const Text(
          'Performance Metrics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: context.torkk.background,
        foregroundColor: context.themed(light: Colors.black, dark: context.torkk.textSecondary),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Circular Score Card
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    color: context.torkk.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: context.torkk.border),
                    boxShadow: [
                      BoxShadow(
                        color: context.themed(light: Colors.black12, dark: context.torkk.textSecondary),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value:
                                  (_performanceScore / 100) * _animation.value,
                              strokeWidth: 10,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                primaryColor,
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    (_performanceScore * _animation.value)
                                        .toStringAsFixed(0),
                                    style: TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w900,
                                      color: primaryColor,
                                    ),
                                  ),
                                  Text(
                                    'Overall Score',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: context.torkk.textSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Excellent Standing',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: context.torkk.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Keep up the high service standards to earn extra bonuses!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.torkk.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // Performance metrics breakdown
            _buildMetricTile(
              label: 'Acceptance Rate',
              value: '${(_acceptanceRate * 100).toStringAsFixed(0)}%',
              percentage: _acceptanceRate,
              icon: Icons.check_circle_outline_rounded,
              color: Colors.teal,
            ),
            _buildMetricTile(
              label: 'Cancellation Rate',
              value: '${(_cancellationRate * 100).toStringAsFixed(1)}%',
              percentage: _cancellationRate,
              icon: Icons.cancel_outlined,
              color: Colors.red,
            ),
            _buildMetricTile(
              label: 'Completion Rate',
              value: '${(_completionRate * 100).toStringAsFixed(1)}%',
              percentage: _completionRate,
              icon: Icons.task_alt_rounded,
              color: Colors.blue,
            ),
            _buildMetricTile(
              label: 'Driver Rating',
              value: '$_driverRating / 5.0',
              percentage: _driverRating / 5.0,
              icon: Icons.star_outline_rounded,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}
