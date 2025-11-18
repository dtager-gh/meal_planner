import 'package:flutter/material.dart';
import '../models/week_plan.dart';


class MealPlanPage extends StatelessWidget {
  final WeekPlan plan;
  const MealPlanPage({super.key, required this.plan});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weekly Meal Plan")),
      body: ListView.builder(
        itemCount: plan.days.length,
        itemBuilder: (context, index) {
          final day = plan.days[index];


          return Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Day ${index + 1}", style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text("Lunch: ${day.lunch.meat} with ${day.lunch.sides.join(', ')}"),
                  Text("Dinner: ${day.dinner.meat} with ${day.dinner.sides.join(', ')}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}