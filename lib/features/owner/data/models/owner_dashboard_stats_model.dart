import '../../domain/entities/owner_dashboard_stats.dart';

class OwnerDashboardStatsModel {
  final int total;
  final int active;
  final int draft;
  final int views;
  final int favorites;

  const OwnerDashboardStatsModel({
    this.total = 0,
    this.active = 0,
    this.draft = 0,
    this.views = 0,
    this.favorites = 0,
  });

  factory OwnerDashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final listings = json['listings'] as Map<String, dynamic>? ?? json;
    return OwnerDashboardStatsModel(
      total: listings['total'] as int? ?? 0,
      active: listings['active'] as int? ?? 0,
      draft: listings['draft'] as int? ?? 0,
      views: listings['views'] as int? ?? 0,
      favorites: listings['favorites'] as int? ?? 0,
    );
  }

  OwnerDashboardStats toEntity() {
    return OwnerDashboardStats(
      total: total,
      active: active,
      draft: draft,
      views: views,
      favorites: favorites,
    );
  }
}
