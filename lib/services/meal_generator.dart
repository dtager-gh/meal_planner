import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/meal.dart';
import '../models/day_plan.dart';
import '../models/week_plan.dart';


      // This makes one meal.
      // availableMeats: list of meats you’re allowed to use
      // allowSalad: true or false, can this meal use salad?
Meal generateMeal({List<String>? availableMeats, bool allowSalad = true}) {

  final random = Random(); //You create a random number generator so you can pick foods randomly.

    //This loads your foods from Hive
  var meats = availableMeats ?? Hive.box<String>('meats').values.toList();
  var veggies = Hive.box<String>('veggies').values.toList();
  var salads = Hive.box<String>('salads').values.toList();

    //If the list of available meats is empty → reload meats so you don’t crash.
  if (meats.isEmpty) meats = Hive.box<String>('meats').values.toList();

    //Pick one random meat.
  String meat = meats[random.nextInt(meats.length)];

    // If salads are allowed → 50/50 chance you use a salad
    // If not allowed → never use salads
  bool useSalad = allowSalad ? random.nextBool() : false;

    //Pick one random salad
  if (useSalad && salads.isNotEmpty) {
    return Meal(meat: meat, sides: [salads[random.nextInt(salads.length)]]);
  }

    // if not using salad Pick a random vegetable.
  String veg1 = veggies[random.nextInt(veggies.length)];

    // Pick a second vegetable.
    // If it accidentally picks the same one twice → pick again.
  String veg2;
  do {
    veg2 = veggies[random.nextInt(veggies.length)];
  } while (veg2 == veg1 && veggies.length > 1);

    //Return the meat + 2 veggies.
  return Meal(meat: meat, sides: [veg1, veg2]);
}



    //Start a randomizer + empty list for the 7 days.
WeekPlan generateWeekPlan() {
  final random = Random();
  List<DayPlan> days = [];


  for (int i = 0; i < 7; i++) {//Loop through each day of the week (7 days).

    bool saladAtLunch = random.nextBool();//Random chance lunch might be a salad meal.

    var availableMeats = Hive.box<String>('meats').values.toList();//Get all meats fresh for todays meals.

// Create lunch
//Remove that meat from the list → ensures dinner doesn’t use the same meat
    Meal lunch = generateMeal(availableMeats: availableMeats, allowSalad: saladAtLunch);
    availableMeats.remove(lunch.meat);


// Dinner uses the remaining meats
// If lunch used salad → dinner does not use salad
// If lunch didn’t use salad → dinner might use salad
    Meal dinner = generateMeal(availableMeats: availableMeats, allowSalad: !saladAtLunch);


    days.add(DayPlan(lunch: lunch, dinner: dinner));//Add the finished day to the week list.
  }


  return WeekPlan(days);//When all 7 days are done, return the full WeekPlan.
}