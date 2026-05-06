class DashboardStats {
  const DashboardStats({
    required this.total,
    required this.pending,
    required this.approved,
    required this.declined,
    this.highPriority = 0,
  });

  final int total;
  final int pending;
  final int approved;
  final int declined;
  final int highPriority;
}
