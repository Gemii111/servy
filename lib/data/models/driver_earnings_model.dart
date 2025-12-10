/// Driver earnings model
class DriverEarningsModel {
  final double todayEarnings;
  final double weekEarnings;
  final double monthEarnings;
  final double totalEarnings;
  final int todayDeliveries;
  final int weekDeliveries;
  final int monthDeliveries;
  final int totalDeliveries;
  final double averageEarningPerDelivery;
  final List<EarningsDayModel> weeklyEarnings;

  DriverEarningsModel({
    required this.todayEarnings,
    required this.weekEarnings,
    required this.monthEarnings,
    required this.totalEarnings,
    required this.todayDeliveries,
    required this.weekDeliveries,
    required this.monthDeliveries,
    required this.totalDeliveries,
    required this.averageEarningPerDelivery,
    this.weeklyEarnings = const [],
  });

  factory DriverEarningsModel.fromJson(Map<String, dynamic> json) {
    return DriverEarningsModel(
      todayEarnings: (json['today_earnings'] as num).toDouble(),
      weekEarnings: (json['week_earnings'] as num).toDouble(),
      monthEarnings: (json['month_earnings'] as num).toDouble(),
      totalEarnings: (json['total_earnings'] as num).toDouble(),
      todayDeliveries: json['today_deliveries'] as int,
      weekDeliveries: json['week_deliveries'] as int,
      monthDeliveries: json['month_deliveries'] as int,
      totalDeliveries: json['total_deliveries'] as int,
      averageEarningPerDelivery: (json['average_earning_per_delivery'] as num).toDouble(),
      weeklyEarnings: (json['weekly_earnings'] as List<dynamic>?)
              ?.map((e) => EarningsDayModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today_earnings': todayEarnings,
      'week_earnings': weekEarnings,
      'month_earnings': monthEarnings,
      'total_earnings': totalEarnings,
      'today_deliveries': todayDeliveries,
      'week_deliveries': weekDeliveries,
      'month_deliveries': monthDeliveries,
      'total_deliveries': totalDeliveries,
      'average_earning_per_delivery': averageEarningPerDelivery,
      'weekly_earnings': weeklyEarnings.map((e) => e.toJson()).toList(),
    };
  }
}

/// Earnings per day model
class EarningsDayModel {
  final DateTime date;
  final double earnings;
  final int deliveries;

  EarningsDayModel({
    required this.date,
    required this.earnings,
    required this.deliveries,
  });

  factory EarningsDayModel.fromJson(Map<String, dynamic> json) {
    return EarningsDayModel(
      date: DateTime.parse(json['date'] as String),
      earnings: (json['earnings'] as num).toDouble(),
      deliveries: json['deliveries'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'earnings': earnings,
      'deliveries': deliveries,
    };
  }
}

