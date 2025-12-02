import '../models/week_plan.dart';

//The function is named generateShoppingList. It takes a WeekPlan (your whole week's meals).
// It returns a Map where:key = the food item name (String)..value = quantity (int)
Map<String, int> generateShoppingList(WeekPlan week) {

  Map<String, int> items = {}; //This creates an empty shopping list.


  for (var day in week.days) { //This loops through each day of the week.
    for (var meal in [day.lunch, day.dinner]) { //This loops through both meals in the day:

      // If the meat already exists in the list → increase the count by 1
      // If it doesn't exist → add it with a quantity of 1
      items.update(meal.meat, (q) => q + 1, ifAbsent: () => 1);

      //Now it does the same thing for every side item in the meal.
      for (var side in meal.sides) {
        items.update(side, (q) => q + 1, ifAbsent: () => 1);
      }
    }
  }

  //After checking every meal in the entire week, return the final shopping list.
  return items;
}