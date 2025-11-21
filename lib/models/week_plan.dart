import 'day_plan.dart';

class WeekPlan {
  final List<DayPlan> days;

  WeekPlan(this.days);

  // Convert to JSON for saving
  Map<String, dynamic> toJson() {
    return {
      'days': days.map((day) => day.toJson()).toList(),
    };
  }

  // Load from JSON
  factory WeekPlan.fromJson(Map<String, dynamic> json) {
    return WeekPlan(
      (json['days'] as List)
          .map((dayJson) => DayPlan.fromJson(dayJson))
          .toList(),
    );
  }
}
