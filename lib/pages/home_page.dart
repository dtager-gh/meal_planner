import 'package:flutter/material.dart';
import 'meal_plan_page.dart';
import 'edit_food_page.dart';
import '../services/meal_generator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meal Planner")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                final plan = generateWeekPlan();   // <-- create real WeekPlan here

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MealPlanPage(plan: plan),
                  ),
                );
              },
              child: const Text("Generate 7-Day Meal Plan"),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (_) => const EditFoodPage(),
                  ),
                );
              },
              child: const Text("Add New Meats / Veggies"),
            ),
          ],
        ),
      ),
    );
  }
}