import 'package:flutter/material.dart';
import '../services/meal_generator.dart';
import 'meal_plan_page.dart';
import 'shopping_list_page.dart';
import 'edit_food_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var plan;


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
                setState(() {
                  plan = generateWeekPlan();
                });
              },
              child: const Text("Generate 7-Day Meal Plan"),
            ),
            const SizedBox(height: 20),
            if (plan != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                    MaterialPageRoute(
                      builder: (_) => MealPlanPage(plan: plan),
                    ),
                  );
                },
                child: const Text("View Meal Plan"),
              ),
            if (plan != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                    MaterialPageRoute(
                      builder: (_) => ShoppingListPage(plan: plan),
                    ),
                  );
                },
                child: const Text("View Shopping List"),
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