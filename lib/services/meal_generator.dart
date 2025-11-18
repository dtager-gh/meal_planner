import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/meal.dart';
import '../models/day_plan.dart';
import '../models/week_plan.dart';


Meal generateMeal({List<String>? availableMeats, bool allowSalad = true}) {
  final random = Random();


  var meats = availableMeats ?? Hive.box<String>('meats').values.toList();
  var veggies = Hive.box<String>('veggies').values.toList();
  var salads = Hive.box<String>('salads').values.toList();


  if (meats.isEmpty) meats = Hive.box<String>('meats').values.toList();


  String meat = meats[random.nextInt(meats.length)];


  bool useSalad = allowSalad ? random.nextBool() : false;


  if (useSalad && salads.isNotEmpty) {
    return Meal(meat: meat, sides: [salads[random.nextInt(salads.length)]]);
  }


  String veg1 = veggies[random.nextInt(veggies.length)];
  String veg2;


  do {
    veg2 = veggies[random.nextInt(veggies.length)];
  } while (veg2 == veg1 && veggies.length > 1);


  return Meal(meat: meat, sides: [veg1, veg2]);
}

WeekPlan generateWeekPlan() {
  final random = Random();
  List<DayPlan> days = [];


  for (int i = 0; i < 7; i++) {
    bool saladAtLunch = random.nextBool();


    var availableMeats = Hive.box<String>('meats').values.toList();


// Lunch meal
    Meal lunch = generateMeal(availableMeats: availableMeats, allowSalad: saladAtLunch);
    availableMeats.remove(lunch.meat);


// Dinner meal (cannot use same meat as lunch)
    Meal dinner = generateMeal(availableMeats: availableMeats, allowSalad: !saladAtLunch);


    days.add(DayPlan(lunch: lunch, dinner: dinner));
  }


  return WeekPlan(days);
}