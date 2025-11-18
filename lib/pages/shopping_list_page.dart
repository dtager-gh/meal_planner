import 'package:flutter/material.dart';
import '../services/shopping_list.dart';
import '../models/week_plan.dart';


class ShoppingListPage extends StatelessWidget {
  final WeekPlan plan;
  const ShoppingListPage({super.key, required this.plan});


  @override
  Widget build(BuildContext context) {
    final list = generateShoppingList(plan);


    return Scaffold(
      appBar: AppBar(title: const Text("Shopping List")),
      body: ListView(
        children: list.entries.map((item) {
          return ListTile(
            title: Text(item.key),
            trailing: Text("x${item.value}"),
          );
        }).toList(),
      ),
    );
  }
}