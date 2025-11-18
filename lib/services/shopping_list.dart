import '../models/week_plan.dart';


Map<String, int> generateShoppingList(WeekPlan week) {
  Map<String, int> items = {};


  for (var day in week.days) {
    for (var meal in [day.lunch, day.dinner]) {
      items.update(meal.meat, (q) => q + 1, ifAbsent: () => 1);


      for (var side in meal.sides) {
        items.update(side, (q) => q + 1, ifAbsent: () => 1);
      }
    }
  }


  return items;
}