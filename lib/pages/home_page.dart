import 'package:flutter/material.dart';
import 'meal_plan_page.dart';
import 'edit_food_page.dart';
import '../services/meal_generator.dart';
import 'shopping_list_page.dart';
import '../services/shopping_list.dart';
import '../models/week_plan.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool hasShoppingList = false; // tracks if a plan has been generated
  WeekPlan? currentPlan; // optional, only if you want to store the plan


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

                setState(() {
                  currentPlan = plan;
                  hasShoppingList = true; // enable FAB
                });

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
      // Floating Action Button for Shopping Cart
      floatingActionButton: Stack(
        children: [
          FloatingActionButton(
            onPressed: hasShoppingList
                ? () {
              final shoppingList = generateShoppingList(currentPlan!);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ShoppingListPage(shoppingList: shoppingList),
                ),
              );
            }
                : null,
            tooltip: 'View Shopping List',
            child: const Icon(Icons.shopping_cart),
          ),
          if (hasShoppingList)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '${generateShoppingList(currentPlan!).length}', // number of items
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}