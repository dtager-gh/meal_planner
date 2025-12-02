import 'package:flutter/material.dart';
import '../models/week_plan.dart';
import 'shopping_list_page.dart';
import '../services/shopping_list.dart';



//This page needs a WeekPlan (the generated weekly meals).
// It’s a StatelessWidget because the meal plan never changes on this screen.
class MealPlanPage extends StatelessWidget {
  final WeekPlan plan;
  const MealPlanPage({super.key, required this.plan});


  @override
  Widget build(BuildContext context) {
    //Creates the page with a top app bar that says “Weekly Meal Plan”.
    return Scaffold(
      appBar: AppBar(title: const Text("Weekly Meal Plan")),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Generate shopping list from the current plan
          // → This creates a Map of items and quantities (ex: "Chicken": 3)
          final shoppingList = generateShoppingList(plan);

          // Navigate to ShoppingListPage
          Navigator.push(context,
            MaterialPageRoute(
              builder: (_) => ShoppingListPage(shoppingList: shoppingList ),
            ),
          );
        },
        child: const Icon(Icons.shopping_cart),
      ),

      //ListView.builder creates a scrollable list.
      // It loops through each day in the week.
      body: ListView.builder(
        itemCount: plan.days.length,
        itemBuilder: (context, index) {
          final day = plan.days[index];

          //This creates a nice-looking card
          return Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Day ${index + 1}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Lunch: ${day.lunch.meat} with ${day.lunch.sides.join(', ')}" , style: const TextStyle(fontWeight: FontWeight.bold),),
                  Text("Dinner: ${day.dinner.meat} with ${day.dinner.sides.join(', ')}" , style: const TextStyle(fontWeight: FontWeight.bold),),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}