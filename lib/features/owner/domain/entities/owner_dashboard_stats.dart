import 'package:equatable/equatable.dart';

/// Owner dashboard statistics entity.
/// Traceability: REQ-027, SCR-013, API-036.
class OwnerDashboardStats extends Equatable {
  final int total;
  final int active;
  final int draft;
  final int views;
  final int favorites;

  const OwnerDashboardStats({
    this.total = 0,
    this.active = 0,
    this.draft = 0,
    this.views = 0,
    this.favorites = 0,
  });

  @override
  List<Object?> get props => [total, active, draft, views, favorites];
}
