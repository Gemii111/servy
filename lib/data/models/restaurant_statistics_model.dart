/// Restaurant statistics model
class RestaurantStatisticsModel {
  final int todayOrders;
  final double todayRevenue;
  final int pendingOrders;
  final int activeOrders;
  final double averageOrderValue;
  final int weeklyOrders;
  final double weeklyRevenue;
  final int monthlyOrders;
  final double monthlyRevenue;

  RestaurantStatisticsModel({
    required this.todayOrders,
    required this.todayRevenue,
    required this.pendingOrders,
    required this.activeOrders,
    required this.averageOrderValue,
    required this.weeklyOrders,
    required this.weeklyRevenue,
    required this.monthlyOrders,
    required this.monthlyRevenue,
  });

  factory RestaurantStatisticsModel.fromJson(Map<String, dynamic> json) {
    return RestaurantStatisticsModel(
      todayOrders: json['today_orders'] as int,
      todayRevenue: (json['today_revenue'] as num).toDouble(),
      pendingOrders: json['pending_orders'] as int,
      activeOrders: json['active_orders'] as int,
      averageOrderValue: (json['average_order_value'] as num).toDouble(),
      weeklyOrders: json['weekly_orders'] as int,
      weeklyRevenue: (json['weekly_revenue'] as num).toDouble(),
      monthlyOrders: json['monthly_orders'] as int,
      monthlyRevenue: (json['monthly_revenue'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today_orders': todayOrders,
      'today_revenue': todayRevenue,
      'pending_orders': pendingOrders,
      'active_orders': activeOrders,
      'average_order_value': averageOrderValue,
      'weekly_orders': weeklyOrders,
      'weekly_revenue': weeklyRevenue,
      'monthly_orders': monthlyOrders,
      'monthly_revenue': monthlyRevenue,
    };
  }
}

