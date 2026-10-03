/// Typed data model for driver earnings summary.
///
/// Encapsulates daily, weekly, monthly, and total earnings,
/// along with completed trips count and recent trip history.
class EarningsModel {
  final double todayEarnings;
  final double weekEarnings;
  final double monthEarnings;
  final double totalEarnings;
  final int completedTrips;
  final double onlineHours;
  final List<dynamic> recentTrips;
  final Map<String, double> dailyEarnings;

  const EarningsModel({
    this.todayEarnings = 0.0,
    this.weekEarnings = 0.0,
    this.monthEarnings = 0.0,
    this.totalEarnings = 0.0,
    this.completedTrips = 0,
    this.onlineHours = 0.0,
    this.recentTrips = const [],
    this.dailyEarnings = const {
      'Su': 0.0,
      'Mo': 0.0,
      'Tu': 0.0,
      'We': 0.0,
      'Th': 0.0,
      'Fr': 0.0,
      'Sa': 0.0,
    },
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    final rawRecent = json['recent_trips'];
    final trips = rawRecent is List ? rawRecent : <dynamic>[];

    // Compute weekly breakdown from recent trips if available
    final weekMap = <String, double>{
      'Su': 0.0,
      'Mo': 0.0,
      'Tu': 0.0,
      'We': 0.0,
      'Th': 0.0,
      'Fr': 0.0,
      'Sa': 0.0,
    };

    const days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

    for (final trip in trips) {
      if (trip is! Map) continue;
      final amount = (trip['earnings'] ??
              trip['driver_earnings'] ??
              trip['fare'] ??
              trip['amount'] as num?)
          ?.toDouble() ??
          0.0;
      final dateStr = trip['created_at']?.toString() ??
          trip['date']?.toString() ??
          '';
      if (dateStr.isNotEmpty) {
        final dt = DateTime.tryParse(dateStr);
        if (dt != null) {
          final dayKey = days[dt.weekday % 7];
          weekMap[dayKey] = (weekMap[dayKey] ?? 0.0) + amount;
        }
      }
    }

    final todayAmt = (json['today_earnings'] as num?)?.toDouble() ?? 0.0;
    final todayKey = days[DateTime.now().weekday % 7];
    if (todayAmt > 0 && (weekMap[todayKey] ?? 0) == 0) {
      weekMap[todayKey] = todayAmt;
    }

    return EarningsModel(
      todayEarnings: todayAmt,
      weekEarnings: (json['week_earnings'] as num?)?.toDouble() ?? 0.0,
      monthEarnings: (json['month_earnings'] as num?)?.toDouble() ?? 0.0,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      completedTrips: (json['completed_trips'] as num?)?.toInt() ??
          (json['trips_count'] as num?)?.toInt() ??
          0,
      onlineHours: (json['online_hours'] as num?)?.toDouble() ?? 0.0,
      recentTrips: trips,
      dailyEarnings: weekMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today_earnings': todayEarnings,
      'week_earnings': weekEarnings,
      'month_earnings': monthEarnings,
      'total_earnings': totalEarnings,
      'completed_trips': completedTrips,
      'online_hours': onlineHours,
      'recent_trips': recentTrips,
    };
  }

  EarningsModel copyWith({
    double? todayEarnings,
    double? weekEarnings,
    double? monthEarnings,
    double? totalEarnings,
    int? completedTrips,
    double? onlineHours,
    List<dynamic>? recentTrips,
    Map<String, double>? dailyEarnings,
  }) {
    return EarningsModel(
      todayEarnings: todayEarnings ?? this.todayEarnings,
      weekEarnings: weekEarnings ?? this.weekEarnings,
      monthEarnings: monthEarnings ?? this.monthEarnings,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      completedTrips: completedTrips ?? this.completedTrips,
      onlineHours: onlineHours ?? this.onlineHours,
      recentTrips: recentTrips ?? this.recentTrips,
      dailyEarnings: dailyEarnings ?? this.dailyEarnings,
    );
  }
}
