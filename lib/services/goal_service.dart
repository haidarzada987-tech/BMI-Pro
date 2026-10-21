class GoalService {
  const GoalService();

  double progress({
    required double start,
    required double current,
    required double target,
  }) {
    final total = (target - start).abs();
    if (total == 0) return 1.0;

    final direction = target >= start ? 1.0 : -1.0;
    final movedTowardGoal = (current - start) * direction;
    return (movedTowardGoal / total).clamp(0.0, 1.0);
  }

  double remaining(double current, double target) =>
      (current - target).abs();

  bool reached(double current, double target) =>
      (current - target).abs() <= 0.1;
}
